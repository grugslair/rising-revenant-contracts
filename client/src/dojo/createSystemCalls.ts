import { SetupNetworkResult } from "./setupNetwork";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys, getEvents, setComponentsFromEvents } from "@dojoengine/utils";
import { getComponentValueStrict, setComponent, updateComponent } from "@latticexyz/recs";

import { CreateGameProps, CreateRevenantProps, ConfirmEventOutpost, CreateEventProps, PurchaseReinforcementProps, ReinforceOutpostProps, RevokeTradeReinf, PurchaseTradeReinf, ClaimScoreRewards, CreateTradeForReinf, ModifyTradeReinf } from "./types/index"

import { toast } from 'react-toastify';
import { GAME_CONFIG_ID } from "../utils/settingsConstants";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { execute, contractComponents, clientComponents, call }: SetupNetworkResult,
    {
        GameEntityCounter,
        ClientGameData,
    }: ClientComponents
) {

    const notify = (message: string, transaction: any) => {
        if (transaction.execution_status == 'REVERTED') {

            const rejectReason = extractErrorReason(transaction.revert_reason);

            toast("❌ " + rejectReason, {
                position: "top-left",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "dark",
            });
        }
        else {
            toast("✅ " + message, {
                position: "top-left",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "dark",
            });
        }
    }

    const updateClientTransaction = (entityId, state, message, txHash) => {
        updateComponent(clientComponents.ClientTransaction, entityId, {
            state,
            message,
            txHash,
        });
    };

    function getClientGameData(): any {
        const clientGameData = getComponentValueStrict(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
        return clientGameData;
    }


    //TO DELETE
    const create_game = async ({ account, preparation_phase_interval, event_interval, erc_addr, reward_pool_addr, revenant_init_price, max_amount_of_revenants }: CreateGameProps) => {

        try {
            const tx = await execute(account, "game_actions", "create", [preparation_phase_interval, event_interval, erc_addr, reward_pool_addr, revenant_init_price, max_amount_of_revenants]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            // setComponentsFromEvents(contractComponents,
            //     getEvents(receipt)
            // );
            console.log(receipt)

            notify('Game Created!', receipt)
        } catch (e) {
            console.log(e)
            notify(`Error creating game ${e}`, false)
        }
    };

    const create_revenant = async ({ account, game_id, count }: CreateRevenantProps) => {
        {
            const clientGameData = getClientGameData();
            const newAmountOfTxs = clientGameData.transaction_count + 1
            const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

            setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
                state: 1,
                message: "trying to summon revenants",
                txHash: ""
            });

            updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

            try {
                const tx = await execute(account, "revenant_actions", "create", [game_id, count]);
                const receipt: any = await account.waitForTransaction(
                    tx.transaction_hash,
                    { retryInterval: 100 }
                )

                setComponentsFromEvents(contractComponents,
                    getEvents(receipt)
                );

                notify('Revenants are being summoned!', receipt);

                if (receipt.execution_status! == 'REVERTED') {
                    const rejectReason = extractErrorReason(receipt.revert_reason);
                    updateClientTransaction(txNotiEntId, 2, "Summoning a Revenant got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
                } else {
                    updateClientTransaction(txNotiEntId, 3, "Summoning a Revenant was succesful", tx.transaction_hash.toString());
                }
            } catch (e) {
                console.log(e);
                updateClientTransaction(txNotiEntId, 4, "A major error was received when summoning an Revenant", "");
            }
            finally {
                const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));

                for (let index = 0; index < Number(count); index++) {
                    const entityId = getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]);
                    
                    setComponent(clientComponents.ClientOutpostData, entityId, {
                        id: gameEntityCounter.outpost_count - index,
                        owned: true,
                        event_effected: false,
                        selected: false,
                        visible: false,
                    });
                }
            }
        }
    };

    //TO SWAP FOR THE REAL LIB
    const get_current_block = async () => {
        try {
            const tx: any = await call("game_actions", "get_current_block", []);
            return hexToDecimal(tx.result[0]);

            // return 90;
        } catch (e) {
            console.log(e)
        }
    };

    const get_current_reinforcement_price = async (game_id: number, count: number) => {
        try {
            const tx: any = await call("revenant_actions", "get_current_price", [game_id, count]);
            // console.error(`THIS IS FOR THE CURRENT PRICE OF THE REINFORCEMENTS ${tx.result[0]}`)
            return tx.result[0]
        } catch (e) {
            console.log(e)
        }
    };

    const purchase_reinforcement = async ({ account, game_id, count }: PurchaseReinforcementProps) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to purchase reinforcements",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "revenant_actions", "purchase_reinforcement", [game_id, count]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Purchasing Reinforcements', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Purchasing Reinforcements got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Succesfully Purchased Reinforcements", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when Purchasing Reinforcements", "");
        }
    };

    const reinforce_outpost = async ({ account, game_id, count, outpost_id }: ReinforceOutpostProps) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to reinforce an outpost",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "revenant_actions", "reinforce_outpost", [game_id, count, outpost_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Reinforcing your Outpost...', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Reinforcing an outpost call got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Succesfully Reinforced your Outpost", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when reinforcing an Outpost", "");
        }
    };

    const create_trade_reinf = async ({ account, game_id, count, price }: CreateTradeForReinf) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to create a reinforcement trade",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "trade_actions", "create", [game_id, count, price]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Creating Reinforcement Trades', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Creating a Reinforcement trade got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Reinforcement Trade was created succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when creating a reinforcement trade", "");
        }
    };

    const revoke_trade_reinf = async ({ account, game_id, trade_id }: RevokeTradeReinf) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to revoke a reinforcement trade",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "trade_actions", "revoke", [game_id, trade_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Creating Reinforcement Trades', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Revoking a Reinforcement trade got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Reinforcement Trade was revoked succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when revoking a reinforcement trade", "");
        }
    };

    const purchase_trade_reinf = async ({ account, game_id, trade_id }: PurchaseTradeReinf) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1;
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, txNotiEntId, {
            state: 1,
            message: "trying to revoke a reinforcement trade",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs });

        try {
            const tx = await execute(account, "trade_actions", "purchase", [game_id, trade_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Purchased a Reinforcement Trade!', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "buying a reinforcement Trade got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "reinforcement Trade was bought succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when buying a reinforcement Trade", "");
        }
    };

    const modify_trade_reinf = async ({ account, game_id, trade_id, new_price }: ModifyTradeReinf) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, txNotiEntId, {
            state: 1,
            message: "trying to modify a reinforcement trade",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "trade_actions", "modify_price", [game_id, trade_id, new_price]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Reinforcement Trade modified succesfully!', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Modifing a Reinforcement Trade got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Reinforcement Trade modified succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when Modifing a Reinforcement Trade", "");
        }
    };

    const create_event = async ({ account, game_id }: CreateEventProps) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to create event",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "world_event_actions", "create", [game_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('World Event Created!', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Creating an Event got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Event was created succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when creating an Event", "");
        }
    };

    const confirm_event_outpost = async ({ account, game_id, event_id, outpost_id }: ConfirmEventOutpost) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, txNotiEntId, {
            state: 1,
            message: "trying to claim the jackpot",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "world_event_actions", "destroy_outpost", [game_id, event_id, outpost_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Confirmed an Event on an Outpost', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Confirming an event got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Event confirmed succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when conferming an Event", "");
        }
    };

    const claim_endgame_rewards = async ({ account, game_id }: ClaimScoreRewards) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, txNotiEntId, {
            state: 1,
            message: "trying to create event",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "revenant_actions", "claim_endgame_rewards", [game_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Claiming Jackpot, WELLDONE!', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Claiming jackpot got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Jackpot was claimed succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when claiming a jackpot", "");
        }
    };

    const claim_score_rewards = async ({ account, game_id }: ClaimScoreRewards) => {

        const clientGameData = getClientGameData();
        const newAmountOfTxs = clientGameData.transaction_count + 1
        const txNotiEntId = getEntityIdFromKeys([BigInt(newAmountOfTxs)]);

        setComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
            state: 1,
            message: "trying to create event",
            txHash: ""
        });

        updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { transaction_count: newAmountOfTxs })

        try {
            const tx = await execute(account, "revenant_actions", "claim_score_rewards", [game_id]);
            const receipt: any = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Claiming your contribution score!', receipt);

            if (receipt.execution_status! == 'REVERTED') {
                const rejectReason = extractErrorReason(receipt.revert_reason);
                updateClientTransaction(txNotiEntId, 2, "Claiming your contribution got rejected \nReason: " + rejectReason, tx.transaction_hash.toString());
            } else {
                updateClientTransaction(txNotiEntId, 3, "Contribution was claimed succesfully", tx.transaction_hash.toString());
            }

        } catch (e) {
            console.log(e)
            updateClientTransaction(txNotiEntId, 4, "A major error was received when Claiming your contribution", "");
        }
    };

    return {
        create_game,
        create_revenant,
        purchase_reinforcement,
        reinforce_outpost,
        create_event,
        confirm_event_outpost,

        create_trade_reinf,
        revoke_trade_reinf,
        purchase_trade_reinf,
        modify_trade_reinf,

        claim_score_rewards,
        claim_endgame_rewards,

        get_current_block,
        get_current_reinforcement_price
    };
}


function hexToDecimal(hexString: string): number {
    const decimalResult: number = parseInt(hexString, 16);
    return decimalResult;
}

function extractErrorReason(errorMessage: string): string {
    const startDelimiter = "('";
    const endDelimiter = "')";

    const startIndex = errorMessage.indexOf(startDelimiter);
    const endIndex = errorMessage.indexOf(endDelimiter, startIndex + startDelimiter.length);

    if (startIndex !== -1 && endIndex !== -1) {
        const reason = errorMessage.substring(startIndex + startDelimiter.length, endIndex);
        return reason;
    } else {
        return "Error reason not found";
    }
}