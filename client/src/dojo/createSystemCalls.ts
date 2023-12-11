import { SetupNetworkResult } from "./setupNetwork";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys, getEvents,  setComponentsFromEvents} from "@dojoengine/utils";
import {  getComponentValueStrict } from "@latticexyz/recs";

import { CreateGameProps, CreateRevenantProps, ConfirmEventOutpost, CreateEventProps, PurchaseReinforcementProps, ReinforceOutpostProps, CreateTradeFor1Reinf, RevokeTradeFor1Reinf } from "./types/index"

import { toast } from 'react-toastify';
import { setClientOutpostComponent } from "../utils";
import { GAME_CONFIG } from "../phaser/constants";
import { uint256 } from "starknet";

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
    // THIS SHOULD ALSO HAVE A LINK


    const notify = (message: string, succeeded: boolean) => 
    {
        if (!succeeded){
            toast("❌ " + message, {
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
    const create_game = async ({ account, preparation_phase_interval, event_interval, erc_addr, revenant_init_price }: CreateGameProps) => {

        try {
            const tx = await execute(account, "game_actions", "create", [preparation_phase_interval, event_interval, erc_addr,revenant_init_price]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            // setComponentsFromEvents(contractComponents,
            //     getEvents(receipt)
            // );

            console.log(receipt)

            notify('Game Created!',true)
        } catch (e) {
            console.log(e)
            notify(`Error creating game ${e}`, false)
        }
    };

    const create_revenant = async ({ account, game_id }: CreateRevenantProps) => {

        try {
            const tx = await execute(account, "revenant_actions", "create", [game_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Revenant Created!', true);
        } catch (e) {

            console.log(e);
            notify('Failed to create revenant', false);
        }
        finally
        {
            const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));
            const outpostData = getComponentValueStrict(Outpost, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count)]));
            const clientGameData = getComponentValueStrict(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

            let owned = false;

            if (outpostData.owner === account.address) {
                owned = true;
            }

            setClientOutpostComponent( Number(outpostData.entity_id), owned, false, false, false, clientComponents, contractComponents, clientGameData.current_game_id) 
        }
    };

    //TO SWAP
    const view_block_count = async () => {
        try {
            const tx: any = await call("game_actions", "get_current_block", []);
            return hexToDecimal(tx.result[0])
            // return 90;
        } catch (e) {
            console.log(e)
        }
    }

    const get_current_reinforcement_price = async (game_id:number) => {
        try {

            const tx: any = await call("revenant_actions", "get_current_price", [game_id]);
            console.error(`THIS IS FOR THE CURRENT PRICE OF THE REINFORCEMENTS ${tx.result[0]}`)

            return tx.result[0]
        } catch (e) {
            console.log(e)
        }
    }

    const purchase_reinforcement = async ({ account, game_id, count }: PurchaseReinforcementProps) => {

        // this version has the optimistic rendering to it, TALK WITH DEISGNER HERE

        // const reinforcementId = uuid();
        // const balanceKey =  getEntityIdFromKeys([BigInt(game_id), BigInt(account.address)]);

        // const reinforecementBalance = getComponentValue(PlayerInfo, balanceKey)

        // Player.addOverride(reinforcementId, {
        //     entity:  balanceKey,
        //     value: {
        //         reinforcement_count: reinforecementBalance?.reinforcement_count,
        //     }
        // })

        try {
            const tx = await execute(account, "revenant_actions", "purchase_reinforcement", [game_id, count]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            // notify(`Purchased ${count} reinforcements`);
        } catch (e) {
            console.log(e)
            // PlayerInfo.removeOverride(reinforcementId);
        }
        finally
        {
            // PlayerInfo.removeOverride(reinforcementId);
        }

      
    };

    const reinforce_outpost = async ({ account, game_id, outpost_id }: ReinforceOutpostProps) => {
        
        //AGAIN OPTIMISTIC RENDERING CAN BE ADDED HERE

        try {
            const tx = await execute(account, "revenant_actions", "reinforce_outpost", [game_id, outpost_id]);
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
            notify("Failed to reinforce outpost", false)
        }
        finally
        {

        }
    };



    const create_trade_1_reinf = async ({ account, game_id, price }: CreateTradeFor1Reinf) => {

        try {
            const tx = await execute(account, "trade_actions", "create", [game_id, price]);
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
        finally
        {

        }
    };

    const revoke_trade_1_reinf = async ({ account, game_id, trade_id }: RevokeTradeFor1Reinf) => {

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
        finally
        {

        }
    };

    //TO DELETE OR NOT?!?!?
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

            notify('World Event Created!', true);

        } catch (e) {
            console.log(e)
        }
    };


    const confirm_event_outpost = async ({ account, game_id, event_id, outpost_id }: ConfirmEventOutpost) => {

        console.error(`${game_id} is the game id\n ${event_id} event id\n ${outpost_id} outpost id\n`);

        try {
            const tx = await execute(account, "world_event_actions", "destroy_outpost", [game_id, event_id, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Confirmed the event', true)
        } catch (e) {
            console.log(e)
            notify('Failed to confirm event', false)
        }
        finally
        {
            const outpostData = getComponentValueStrict(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(game_id), BigInt(outpost_id)]));

            setClientOutpostComponent( Number(outpost_id), outpostData.owned, false, outpostData.selected, outpostData.visible, clientComponents, contractComponents, Number(game_id)) 
        }
    };

    return {
        create_game,
        create_revenant,
        purchase_reinforcement,
        reinforce_outpost,
        create_event,
        confirm_event_outpost,

        create_trade_1_reinf,
        revoke_trade_1_reinf,

        view_block_count,
        get_current_reinforcement_price
    };
}

function hexToDecimal(hexString: string): number {
    const decimalResult: number = parseInt(hexString, 16);
    return decimalResult;
}