import { SetupNetworkResult } from "./setupNetwork";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys, getEvents,  setComponentsFromEvents} from "@dojoengine/utils";
import {  getComponentValueStrict } from "@latticexyz/recs";

import { CreateGameProps, CreateRevenantProps, ConfirmEventOutpost, CreateEventProps, PurchaseReinforcementProps, ReinforceOutpostProps, CreateTradeForReinf, RevokeTradeReinf, PurchaseTradeReinf, ClaimScoreRewards, ModifyTradeReinf } from "./types/index"

import { toast } from 'react-toastify';
import { setClientOutpostComponent } from "../utils";
import { GAME_CONFIG_ID } from "../utils/settingsConstants";

//HERE

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { execute, contractComponents, clientComponents, call }: SetupNetworkResult,
    {
        GameEntityCounter,
        Outpost,
        ClientGameData
    }: ClientComponents
) {

    //HERE SHOULD BE DONE need to fix the notify to actually change if it fails or not
    // as right now it doesnt detect if it gets rejected only if the transaciton fails
    
    const notify = (message: string, transaction: any) => 
    {
        if (transaction.execution_status == 'REVERTED'){
            toast("❌ " + transaction.revert_reason, {
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
        else{
            toast("✅ " +  message, {
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
    const create_game = async ({ account, preparation_phase_interval, event_interval, erc_addr, reward_pool_addr,revenant_init_price , max_amount_of_revenants}: CreateGameProps) => {

        try {
            const tx = await execute(account, "game_actions", "create", [preparation_phase_interval, event_interval, erc_addr, reward_pool_addr,revenant_init_price, max_amount_of_revenants]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            // setComponentsFromEvents(contractComponents,
            //     getEvents(receipt)
            // );

            notify('Game Created!',receipt)
        } catch (e) {
            console.log(e)
            notify(`Error creating game ${e}`, false)
        }
    };

    const create_revenant = async ({ account, game_id, count }: CreateRevenantProps) => {

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
        } catch (e) {

            console.log(e);
            notify('Failed to create revenant', false);
        }
        finally
        {
            const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));

            for (let index = 0; index < Number(count); index++) {

                const outpostData = getComponentValueStrict(Outpost, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count - index)]));
                const clientGameData = getComponentValueStrict(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    
                let owned = false;
    
                if (outpostData.owner === account.address) {
                    owned = true;
                }
    
                setClientOutpostComponent( Number(outpostData.entity_id), owned, false, false, false, clientComponents, contractComponents, clientGameData.current_game_id) 
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

    const get_current_reinforcement_price = async (game_id:number, count:number) => {
        try {
            const tx: any = await call("revenant_actions", "get_current_price", [game_id,count]);
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
            const tx = await execute(account, "revenant_actions", "reinforce_outpost", [game_id,count, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Reinforced Outpost', receipt)
        } catch (e) {
            console.log(e)
            
        }
    };

    const create_trade_reinf = async ({ account, game_id,count, price }: CreateTradeForReinf) => {

        try {
            const tx = await execute(account, "trade_actions", "create", [game_id, count, price]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`Created trade`, receipt)
        } catch (e) {
            console.log(e)
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

            notify(`Revoked Trade ${trade_id}`, receipt)
        } catch (e) {
            console.log(e)
        }
        finally
        {

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

    const purchase_trade_reinf = async ({ account, game_id ,trade_id }: PurchaseTradeReinf) => {

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
        }
    };

    const create_event = async ({ account, game_id }: CreateEventProps) => {
        
        try {
            const tx = await execute(account, "world_event_actions", "create", [game_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('World Event Created!', receipt);

        } catch (e) {
            console.log(e)
        }
    };

    const confirm_event_outpost = async ({ account, game_id, event_id, outpost_id }: ConfirmEventOutpost) => {

        try {
            const tx = await execute(account, "world_event_actions", "destroy_outpost", [game_id, event_id, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Confirmed the event', receipt)
        } catch (e) {
            console.log(e)
        }
        finally
        {
            const outpostData = getComponentValueStrict(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(game_id), BigInt(outpost_id)]));

            setClientOutpostComponent( Number(outpost_id), outpostData.owned, false, outpostData.selected, outpostData.visible, clientComponents, contractComponents, Number(game_id)) 
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

            notify(`Claiming jackpot well done!!!`, receipt)
        } catch (e) {
            console.log(e)
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

            notify(`Claiming score contribution!!!`, receipt)
        } catch (e) {
            console.log(e)
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