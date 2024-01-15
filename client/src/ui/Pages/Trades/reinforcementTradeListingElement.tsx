
import { useState } from "react";
import { useDojo } from "../../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";
import { ModifyTradeReinf, PurchaseTradeReinf, RevokeTradeReinf } from "../../../dojo/types";
import { InputNumber, Tooltip } from "antd";
import { hexToNumber, truncateString } from "../../../utils";
import { ClickWrapper } from "../../clickWrapper";
import { Box } from "@mui/material";

import { Trade, TradeEdge, World__Entity } from "../../../generated/graphql";
import { Maybe } from "graphql/jsutils/Maybe";

import { getComponentValueStrict } from '@latticexyz/recs';

// export const DumbReinforcementListingElement: React.FC<{ type: number }> = ({ type }) => {
//     return (
//         <ClickWrapper className="reinforcement-sale-element-container ">
//             <div style={{ gridColumn: "1/11", whiteSpace: "nowrap", display: "flex", flexDirection: "row", fontSize: "1.1vw" }}>
//                 <div style={{ flex: "0.7", display: "flex", alignItems: "center", justifyContent: "flex-start", padding: "0px 1%" }}>
//                     Maker: {truncateString("0x7231897387126387di1h17ney1", 5)}
//                 </div>
//                 <div style={{ flex: "1", display: "flex", alignItems: "center", justifyContent: "center" }}>
//                     <img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {20}
//                 </div>
//                 <div style={{ flex: "0.6", display: "flex", alignItems: "center", justifyContent: "flex-end", padding: "0px 1%" }}>
//                     {type === 3 ? <Tooltip title="Click to change price"><div className="pointer">Price: ${22} LORDS</div></Tooltip> : <div>Price: ${22} LORDS</div>}
//                 </div>
//             </div>

//             {/* we need to add the change price thing */}
//             {type === 1 && <div className="reinf-grid-buy-button center-via-flex" style={{ filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</div>}
//             {type === 2 && <div className="reinf-grid-buy-button center-via-flex pointer" >BUY NOW</div>}
//             {type === 3 && <div className="reinf-grid-buy-button center-via-flex pointer" >REVOKE</div>}

//         </ClickWrapper >
//     );
// };


export const ReinforcementListingElement = ({ trade, showOwn, showOthers }: { trade: Maybe<World__Entity> | undefined, showOwn:boolean | undefined, showOthers:boolean | undefined }) => {
    const trade_model = trade?.models?.find((m) => m?.__typename == 'Trade') as Trade;

    const [numberValue, setNumberValue] = useState<number | null>(1);

    const {
        account: { account },
        networkLayer: {
            network: { clientComponents },
            systemCalls: { revoke_trade_reinf, purchase_trade_reinf, modify_trade_reinf }
        },
    } = useDojo();

    const clientGameDate = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const revokeTrade = () => {
        const revokeTradeProp: RevokeTradeReinf = {
            account: account,
            game_id: clientGameDate.current_game_id,
            trade_id: trade_model?.entity_id,
        }

        revoke_trade_reinf(revokeTradeProp);
    }

    const modifyTrade = () => {
        const revokeTradeProp: ModifyTradeReinf = {
            account: account,
            game_id: clientGameDate.current_game_id,
            trade_id: trade_model?.entity_id,
            new_price: numberValue!
        }

        modify_trade_reinf(revokeTradeProp);
    }

    const buyTrade = () => {
        const buyTradeProp: PurchaseTradeReinf = {
            account: account,
            game_id: clientGameDate.current_game_id,
            trade_id: trade_model?.entity_id
        }

        purchase_trade_reinf(buyTradeProp)
    }

    if (trade_model?.status !== 1) {
        return (<></>)
    }
    if (!showOwn && account.address === trade_model?.seller)
    {   
        return (<></>)
    }
    if (!showOthers && account.address !== trade_model?.seller)
    {
        return (<></>)
    }

    return (
        <ClickWrapper className="reinforcement-sale-element-container ">
            <div style={{ gridColumn: "1/11", whiteSpace: "nowrap", display: "flex", flexDirection: "row", fontSize: "1.8rem" }}>
                <div style={{ flex: "0.55", display: "flex", alignItems: "center", justifyContent: "flex-start", padding: "0px 1%" }}>
                       <h3 className="test-h3">Maker: {account.address === trade_model?.seller ? "You" : truncateString(trade_model?.seller, 5)}</h3>
                </div>
                <div style={{ flex: "1", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <h3 className="test-h3"><img src="Icons/reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {trade_model?.count}</h3>
                </div>
                <div style={{ flex: "0.75", display: "flex", alignItems: "center", justifyContent: "flex-end", padding: "0px 1%" }}>
                    {account.address === trade_model?.seller ?

                        <Tooltip title={
                            //HERE this is to still change
                            <Box component={"span"} p={1} width={200} height={200} >
                                <h2 style={{ textAlign: "center", marginTop: "1px" }}>Change Price</h2>
                                    <InputNumber min={1} max={50} value={numberValue} onChange={setNumberValue} style={{ width: "50%", height: "45%", fontSize: "1.3cqw", marginLeft: "25%" }} />
                                <div className="global-button-style invert-colors " style={{ margin: "5px 0px", fontSize: "1cqw", padding: "5px 10px" }} onClick={modifyTrade}>Confirm</div>
                            </Box>}>
                            <h3 className="pointer test-h3" >Price: ${Number(BigInt(trade_model?.price))} LORDS</h3>
                        </Tooltip>
                        :
                        <h3 className="test-h3">Price: ${hexToNumber(trade_model?.price)} LORDS</h3>}
                </div>
            </div>

            {clientGameDate.guest ? <div className="reinf-grid-buy-button center-via-flex" style={{ filter: "brightness(70%) grayscale(70%)" }}>  <h2 className="test-h2">BUY NOW</h2></div> :
                <>
                    {account.address === trade_model?.seller ? <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => revokeTrade()} ><h2 className="test-h2">REVOKE</h2></div> : <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => buyTrade()}><h2 className="test-h2">BUY NOW</h2></div>}
                </>}

        </ClickWrapper >
    );
};