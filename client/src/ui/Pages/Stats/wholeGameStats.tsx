import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GameEntityCounter } from "../../../generated/graphql";
import { useDojo } from "../../../hooks/useDojo";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";

import { useComponentValue, useEntityQuery } from '@latticexyz/react';
import { getComponentValueStrict, HasValue } from "@latticexyz/recs";
import { useOutpostAmountData } from "../../Hooks/outpostsAmountData";

export const WholeGameDataStats: React.FC = () => {

    const {
        networkLayer: {
            network: { clientComponents, contractComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const gameEntityCounter = useComponentValue(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

    const outpostAmountData = useOutpostAmountData();

    return (
        <div style={{ height: "75%", width: "90%", marginLeft: "5%", display: "flex", gap: "5%", justifyContent: "space-between", color: "white"}}>
            <div style={{ flex: "1", height: "100%", backgroundColor: "#6865654f", padding: "1% 2%", display: "flex", gap: "1%", justifyContent: "flex-start", alignItems: "center", flexDirection: "column", border:"1px solid var(--borderColour)", boxSizing:"border-box" }}>
                <h2 className="test-h2 no-margin" style={{ fontFamily: "Zelda" }}>OUTPOSTS</h2>
                <div style={{ height: "25%", width: "100%" }} className="center-via-flex">
                    <img src="assets/Outpost_Icons/White_Outpost.png" style={{ height: "100%", aspectRatio: "1/1" }} />
                </div>
                <div style={{height: "fit-content", width: "100%" }}>
                    <h3 className="test-h3">Total Outposts: {gameEntityCounter!.outpost_count}</h3>
                    <h3 className="test-h3">Dead Outposts: {outpostAmountData.outpostDeadQuery.length}</h3>
                    <h3 className="test-h3">Alive Outposts: {outpostAmountData.outpostsLeftNumber}</h3>
                    <h3 className="test-h3">In Trades: Coming soon!!</h3>
                </div>
            </div>
            <div style={{flex: "1", height: "100%", backgroundColor: "#6865654f", padding: "1% 2%", display: "flex", gap: "1%", justifyContent: "flex-start", alignItems: "center", flexDirection: "column",border:"1px solid var(--borderColour)", boxSizing:"border-box"  }}>
                <h2 className="test-h2 no-margin" style={{ fontFamily: "Zelda" }}>TRADES</h2>
                <div style={{height: "25%", width: "100%" }} className="center-via-flex">
                    <img src="Navbar_icons/TRADES.png" style={{ height: "100%", aspectRatio: "1/1" }} />
                </div>
                <div style={{height: "fit-content", width: "100%" }}>
                    <h3 className="test-h3">Total Trades: {gameEntityCounter!.trade_count}</h3>
                    <h3 className="test-h3">Sold: WIP</h3>
                    <h3 className="test-h3">Active: WIP</h3>
                    <h3 className="test-h3">Revoked: WIP</h3>
                </div>
            </div>
            <div style={{flex: "1", height: "100%", backgroundColor: "#6865654f", padding: "1% 2%", display: "flex", gap: "1%", justifyContent: "flex-start", alignItems: "center", flexDirection: "column",border:"1px solid var(--borderColour)", boxSizing:"border-box"  }}>
                <h2 className="test-h2 no-margin" style={{ fontFamily: "Zelda" }}>REINFORCEMENTS</h2>
                <div style={{height: "25%", width: "100%" }} className="center-via-flex">
                    <img src="Icons/reinforcements_logo.png" style={{ height: "100%", aspectRatio: "1/1" }} />
                </div>
                <div style={{height: "fit-content", width: "100%" }}>
                    <h3 className="test-h3">Reinforcements in Game: {gameEntityCounter!.reinforcement_count + gameEntityCounter!.remain_life_count}</h3>
                    <h3 className="test-h3">Reinforcements in Wallets: {gameEntityCounter!.reinforcement_count}</h3>
                    <h3 className="test-h3">Reinforcements in Outposts: {gameEntityCounter!.remain_life_count}</h3>
                    <h3 className="test-h3">Reinforcements in Trades: WIP</h3>
                </div>
            </div>
        </div>
    )
}











// <div style={{ gridRow: "1/2", gridColumn: "1/2", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
//                 <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">total Outposts {GameEntityCounter!.outpost_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex"> Alive {GameEntityCounter!.outpost_count - outpostDeadQuery.length}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex"> Dead {outpostDeadQuery.length}</h2>
//             </div>

//             <div style={{ gridRow: "1/2", gridColumn: "2/3", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
//                 <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Total Trades {GameEntityCounter!.trade_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">Sold</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">Revoked</h2>
//                 {/* query system goes in both */}
//             </div>

//             <div style={{ gridRow: "2/3", gridColumn: "1/2", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
//                 <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Total Available Reinforcements {GameEntityCounter!.reinforcement_count + GameEntityCounter!.remain_life_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">In outposts {GameEntityCounter!.reinforcement_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">In Wallets {GameEntityCounter!.remain_life_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "2/3" }} className="center-via-flex">In Trades </h2>
//                 {/* query system goes here */}
//             </div>

//             <div style={{ gridRow: "2/3", gridColumn: "2/3", height: "100%", width: "100%", display: "grid", gridTemplateRows: "1fr 1fr", gridTemplateColumns: "1fr 1fr 1fr" }}>
//                 <h2 style={{ gridRow: "1/2", gridColumn: "1/4" }} className="center-via-flex">Users {}</h2>
//                 {/* query here */}
//                 <h2 style={{ gridRow: "2/3", gridColumn: "1/2" }} className="center-via-flex">score {GameEntityCounter!.score_count}</h2>
//                 <h2 style={{ gridRow: "2/3", gridColumn: "3/4" }} className="center-via-flex">Jackpot {}</h2>
//                 {/* game data here */}
//             </div>