import { SetupNetworkResult } from "./setupNetwork";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys, getEvents, setComponentsFromEvents } from "@dojoengine/utils";
import { Has, getComponentValueStrict, runQuery, setComponent, updateComponent } from "@latticexyz/recs";

import { CreateGameProps, CreateRevenantProps, ConfirmEventOutpost, CreateEventProps, PurchaseReinforcementProps, ReinforceOutpostProps, RevokeTradeReinf, PurchaseTradeReinf, ClaimScoreRewards, CreateTradeForReinf, ModifyTradeReinf } from "./types/index"

import { toast } from 'react-toastify';
import { GAME_CONFIG_ID } from "../utils/settingsConstants";
import { getTileIndex } from "../phaser/constants";
import { turnBigIntToAddress } from "../utils";

//HERE HCANGE ALL THE NOTIS TO THE RIGHT LAYOUT

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { execute, contractComponents, clientComponents, call }: SetupNetworkResult,
    {
        GameEntityCounter,

        Outpost,
        ClientGameData,
        ClientOutpostData
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
            try {
                const tx = await execute(account, "revenant_actions", "create", [game_id, count]);
                const receipt = await account.waitForTransaction(
                    tx.transaction_hash,
                    { retryInterval: 100 }
                )

                setComponentsFromEvents(contractComponents,
                    getEvents(receipt)
                );

                notify('Revenant Created!', receipt);

                console.log(receipt)
            } catch (e) {

                console.log(e);
                // notify('Failed to create revenant');
            }
            finally {
                const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));
                console.error("this is where the game ent gets fetchs", gameEntityCounter)
                for (let index = 0; index < Number(count); index++) {
                    
                    const entitiesAtTileIndex = Array.from(runQuery([Has(contractComponents.Outpost)]));
                    console.log(entitiesAtTileIndex)

                    console.log(getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]))

                    console.log(BigInt(game_id));
                    console.log(Number(count));
                    console.log(BigInt(gameEntityCounter.outpost_count - index));

                    const outpostData: any = getComponentValueStrict(Outpost, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]));
                    console.log("THIS IS WHERE THE ISSUES IS", outpostData)
                    let owned = false;

                    if (turnBigIntToAddress(outpostData.owner) === account.address) {
                        owned = true;
                    }

                    setComponent(ClientOutpostData, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]),
                        {
                            id: Number(outpostData.entity_id),
                            owned: owned,
                            event_effected: false,
                            selected: false,
                            visible: false
                        }
                    )
                    setComponent(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]),
                        {
                            tile_index: getTileIndex(outpostData.x, outpostData.y)
                        }
                    )
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
    }

    const get_current_reinforcement_price = async (game_id: number, count: number) => {
        try {
            const tx: any = await call("revenant_actions", "get_current_price", [game_id, count]);
            // console.error(`THIS IS FOR THE CURRENT PRICE OF THE REINFORCEMENTS ${tx.result[0]}`)
            return tx.result[0]
        } catch (e) {
            console.log(e)
        }
    }

    const purchase_reinforcement = async ({ account, game_id, count }: PurchaseReinforcementProps) => {

        try {
            const tx = await execute(account, "revenant_actions", "purchase_reinforcement", [game_id, count]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

        } catch (e) {
            console.log(e)
        }

    };

    const reinforce_outpost = async ({ account, game_id, count, outpost_id }: ReinforceOutpostProps) => {

        console.error("for the reinforce ", outpost_id, " ", count, " ", game_id);

        try {
            const tx = await execute(account, "revenant_actions", "reinforce_outpost", [game_id, count, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Reinforced Outpost', true)
        } catch (e) {
            console.log(e)

        }
    };

    const create_trade_reinf = async ({ account, game_id, count, price }: CreateTradeForReinf) => {

        try {
            const tx = await execute(account, "trade_actions", "create", [game_id, count, price]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`Created trade`, true)
        } catch (e) {
            console.log(e)
            notify(`Failed to create trade`, false)
        }
    };

    const revoke_trade_reinf = async ({ account, game_id, trade_id }: RevokeTradeReinf) => {

        try {
            const tx = await execute(account, "trade_actions", "revoke", [game_id, trade_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`Revoked Trade ${trade_id}`, true)
        } catch (e) {
            console.log(e)
            notify(`Failed to revoke trade ${trade_id}`, false)
        }
        finally {

        }
    };

    const purchase_trade_reinf = async ({ account, game_id, trade_id }: PurchaseTradeReinf) => {

        try {
            const tx = await execute(account, "trade_actions", "purchase", [game_id, trade_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`purchased Trade ${trade_id}`, receipt)
        } catch (e) {
            console.log(e)
            notify(`Failed to revoke trade ${trade_id}`, false)
        }
    };

    const modify_trade_reinf = async ({ account, game_id, trade_id, new_price }: ModifyTradeReinf) => {

        try {
            const tx = await execute(account, "trade_actions", "modify_price", [game_id, trade_id, new_price]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`Change Trade ${trade_id} price to ${Number(new_price)}`, receipt)
        } catch (e) {
            console.log(e)
        }
    };

    const create_event = async ({ account, game_id }: CreateEventProps) => {

        const clientGameData = getClientGameData(ClientGameData);
        const newAmountOfTxs = clientGameData.transaction_count + 1

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
                updateComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
                    state: 2,
                    message: "Creating an Event got rejected \nReason: " + rejectReason,
                    txHash: tx.transaction_hash.toString(),
                })
            }
            else {
                updateComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
                    state: 3,
                    message: "Event was created succesfully",
                    txHash: tx.transaction_hash.toString(),
                })
            }

        } catch (e) {
            console.log(e)
            updateComponent(clientComponents.ClientTransaction, getEntityIdFromKeys([BigInt(newAmountOfTxs)]), {
                state: 4,
                message: "A major error was received when creating an Event",
                txHash: "",
            })
        }
    };

    const confirm_event_outpost = async ({ account, game_id, event_id, outpost_id }: ConfirmEventOutpost) => {

        let savedTx:any;

        try {
            const tx = await execute(account, "world_event_actions", "destroy_outpost", [game_id, event_id, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            savedTx = receipt;

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Confirmed the event', receipt)
        } catch (e) {
            console.log(e)
            // notify('Failed to confirm event', false)
        }
        finally {
            // might need to fetch back becuase if the tx gets rejected it will still change the colour, altouhg not a massive problem as the loader should set it back but still not good
            //HERE

            if (savedTx.execution_status !== 'REVERTED'){

                updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(game_id), BigInt(outpost_id)]), {
                    event_effected: false
                })
            }

        }
    };

    const claim_endgame_rewards = async ({ account, game_id }: ClaimScoreRewards) => {

        try {
            const tx = await execute(account, "revenant_actions", "claim_endgame_rewards", [game_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`claiming jackpot welldone!!!`, true)
        } catch (e) {
            console.log(e)
            notify(`Failed to create trade`, false)
        }
    };

    const claim_score_rewards = async ({ account, game_id }: ClaimScoreRewards) => {

        try {
            const tx = await execute(account, "revenant_actions", "claim_score_rewards", [game_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`claiming score contribution!!!`, true)
        } catch (e) {
            console.log(e)
            notify(`Failed to create trade`, false)
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

function getClientGameData(ClientGameData: any): any {
    const clientGameData = getComponentValueStrict(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    return clientGameData;
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