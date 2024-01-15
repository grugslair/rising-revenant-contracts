import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GameEntityCounter } from "../../../generated/graphql";
import { useDojo } from "../../../hooks/useDojo";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";

import { useComponentValue, useEntityQuery } from '@latticexyz/react';
import { getComponentValueStrict, HasValue } from "@latticexyz/recs";

export const WholeGameDataStats: React.FC = () => {

    const {
        networkLayer: {
            network: { clientComponents, contractComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const GameEntityCounter = useComponentValue(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));
    const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);

    return (
        <div style={{ height: "90%", width: "95%", marginLeft: "2.5%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr", color:"white" }}>
            <div style={{ gridRow: "1/2", gridColumn: "1/2", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
                <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">total Outposts {GameEntityCounter!.outpost_count}</h2>  
                <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex"> Alive {GameEntityCounter!.outpost_count - outpostDeadQuery.length}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex"> Dead {outpostDeadQuery.length}</h2>
            </div>

            <div style={{ gridRow: "1/2", gridColumn: "2/3", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
                <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Total Trades {GameEntityCounter!.trade_count}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">Sold</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">Revoked</h2>
                {/* query system goes in both */}
            </div>

            <div style={{ gridRow: "2/3", gridColumn: "1/2", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
                <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Total Available Reinforcements {GameEntityCounter!.reinforcement_count + GameEntityCounter!.remain_life_count}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">In outposts {GameEntityCounter!.reinforcement_count}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">In Wallets {GameEntityCounter!.remain_life_count}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "2/3" }} className="center-via-flex">In Trades </h2>
                {/* query system goes here */}
            </div>

            <div style={{ gridRow: "2/3", gridColumn: "2/3", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
                <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Users {}</h2>
                {/* query here */}
                <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">score {GameEntityCounter!.score_count}</h2>
                <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">Jackpot {}</h2>
                {/* game data here */}
            </div>
        </div>
    )
}

