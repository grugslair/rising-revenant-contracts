import { SetupNetworkResult } from "./setupNetwork";
import { ClientComponents } from "./createClientComponents";
import { getEntityIdFromKeys, getEvents,  setComponentsFromEvents} from "@dojoengine/utils";
import {  getComponentValueStrict } from "@latticexyz/recs";



import { CreateGameProps, CreateRevenantProps, ConfirmEventOutpost, CreateEventProps, PurchaseReinforcementProps, ReinforceOutpostProps } from "./types/index"

import { toast } from 'react-toastify';

import { setOutpostClientComponent } from "./testCalls";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
    { execute, contractComponents, clientComponents, call }: SetupNetworkResult,
    {
        GameEntityCounter,
        
        Outpost
    }: ClientComponents
) {

    const notify = (message: string) => toast(message, {
        position: "top-left",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
    });

    const create_game = async ({ account, preparation_phase_interval, event_interval, erc_addr }: CreateGameProps) => {

        try {
            const tx = await execute(account, "game_actions", "create", [preparation_phase_interval, event_interval, erc_addr]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )
            // setComponentsFromEvents(contractComponents,
            //     getEvents(receipt)
            // );
            console.log(receipt)

            notify('Game Created!')
        } catch (e) {
            console.log(e)
            notify(`Error creating game ${e}`)
        }
    };

    const create_revenant = async ({ account, game_id, name }: CreateRevenantProps) => {

        try {
            const tx = await execute(account, "revenant_actions", "create", [game_id, name]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Revenant Created!');
        } catch (e) {
            console.log(e)

            notify('Failed to create revenant');
        }
        finally
        {
            const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));
            const outpostData = getComponentValueStrict(Outpost, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.outpost_count)]));

            console.log(gameEntityCounter)

            let owned = false;

            if (outpostData.owner === account.address) {
                owned = true;
            }

            setOutpostClientComponent(gameEntityCounter.outpost_count,owned,false,false,false,clientComponents);
        }
    };

    const view_block_count = async () => {
        try {
            const tx: any = await call("game_actions", "get_current_block", []);
            // console.log(tx.result[0])
            return hexToDecimal(tx.result[0])
            // return 90;
        } catch (e) {
            console.log(e)
        }
    }

    const purchase_reinforcement = async ({ account, game_id, count }: PurchaseReinforcementProps) => {

        // const reinforcementId = uuid();
        // const balanceKey =  getEntityIdFromKeys([BigInt(game_id), BigInt(account.address)]);

        // const reinforecementBalance = getComponentValue(PlayerInfo, balanceKey)

        // PlayerInfo.addOverride(reinforcementId, {
        //     entity:  balanceKey,
        //     value: {
        //         reinforcement_count: reinforecementBalance?.reinforcement_count,
        //     }
        // })

        // try {
        //     const tx = await execute(account, "revenant_actions", "purchase_reinforcement", [game_id, count]);
        //     const receipt = await account.waitForTransaction(
        //         tx.transaction_hash,
        //         { retryInterval: 100 }
        //     )

        //     setComponentsFromEvents(contractComponents,
        //         getEvents(receipt)
        //     );

        //     notify(`Purchased ${count} reinforcements`);
        // } catch (e) {
        //     console.log(e)
        //     PlayerInfo.removeOverride(reinforcementId);
        // }
        // finally
        // {
        //     PlayerInfo.removeOverride(reinforcementId);
        // }

        try {
            const tx = await execute(account, "revenant_actions", "claim", [game_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify(`Purchased ${count} reinforcements`);
        } catch (e) {
            console.log(e)
        }
      
    };

    const reinforce_outpost = async ({ account, game_id, outpost_id }: ReinforceOutpostProps) => {
        
    
        try {
            const tx = await execute(account, "revenant_actions", "reinforce_outpost", [game_id, outpost_id]);
            const receipt = await account.waitForTransaction(
                tx.transaction_hash,
                { retryInterval: 100 }
            )

            setComponentsFromEvents(contractComponents,
                getEvents(receipt)
            );

            notify('Reinforced Outpost')
        } catch (e) {
            console.log(e)
            notify("Failed to reinforce outpost")
        }
        finally
        {
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

            notify('World Event Created!');

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

            notify('Confirmed the event')
        } catch (e) {
            console.log(e)
            notify('Failed to confirm event')
        }
        finally
        {

        }
    };

    return {

        create_game,
        create_revenant,
        purchase_reinforcement,
        reinforce_outpost,
        create_event,
        confirm_event_outpost,
        view_block_count
    };
}

function hexToDecimal(hexString: string): number {
    const decimalResult: number = parseInt(hexString, 16);
    return decimalResult;
}