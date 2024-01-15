//libs
import { ClickWrapper } from "../../clickWrapper"
import { MenuState } from "../gamePhaseManager";
import React, { useEffect, useState } from "react"
import { Checkbox, Grid, Switch, TextField, Tooltip, colors } from "@mui/material";
//styles
import "./TradesPageStyles.css"


//elements/components
import PageTitleElement, { ImagesPosition } from "../../Elements/pageTitleElement"
// import Dropdown from 'react-dropdown';
import 'react-dropdown/style.css';
import { ReinforcementCountElement } from "../../Elements/reinfrocementBalanceElement";
import { SellReinforcementTradeWindow } from "./sellReinforcementsWindow";
import { ReinforcementTradeWindow } from "./reinforcementsTradeWindow";
//pages


// this is all a mess

/*notes
 this will be a query system but it wont be a query of the saved components instead it will be straight from the graphql return as its done in beer baroon, this is 
 to save on a little of space 

 this whle page is a mess
*/




enum ShopState {
    OUTPOST,
    REINFORCES,
    SELL_REINF,
    SELL_POST,
}

interface TradesPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const TradesPage: React.FC<TradesPageProps> = ({ setMenuState }) => {

    const [shopState, setShopState] = useState<ShopState>(ShopState.REINFORCES);

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="game-page-container" >

            <img className="page-img brightness-down" src="./Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />

            {shopState === ShopState.REINFORCES && <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"TRADES"} rightPicture={"Icons/close_icon.png"} rightImageFunction={() => { closePage() }} htmlContentsRight={<ReinforcementCountElement style={{ marginRight: "10%" }} />} styleContainerRight={{ display: "flex", justifyContent: "flex-end", alignItems: "center" }} />}
            {shopState === ShopState.SELL_REINF && <PageTitleElement imagePosition={ImagesPosition.LEFT} name={"TRADES"} leftPicture={"Icons/left-arrow.png"} leftImageFunction={() => { setShopState(ShopState.REINFORCES) }} htmlContentsRight={<ReinforcementCountElement style={{ marginRight: "10%" }} />} styleContainerRight={{ display: "flex", justifyContent: "flex-end", alignItems: "center" }} />}

            {shopState === ShopState.OUTPOST && <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"TRADES"} rightPicture={"Icons/close_icon.png"} rightImageFunction={() => { closePage() }} />}
            {shopState === ShopState.SELL_POST && <PageTitleElement imagePosition={ImagesPosition.LEFT} name={"TRADES"} leftPicture={"Icons/left-arrow.png"} leftImageFunction={() => { setShopState(ShopState.OUTPOST) }} />}

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                {/* <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style invert-colors " style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div> */}
                <div style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <Tooltip title="COMING SOON!!!">
                        <div className="global-button-style invert-colors " style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda" }}> <h2 className="test-h2 no-margin">OUTPOSTS</h2></div>
                    </Tooltip>
                </div>

                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES && shopState !== ShopState.SELL_REINF ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style invert-colors " style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda" }}> <h2 className="test-h2 no-margin">REINFORCEMENTS</h2></div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "7%", position: "relative" }} ></div>

            <ClickWrapper style={{ width: "100%", height: "50%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
                {/* {shopState === ShopState.OUTPOST && <OutpostTradeWindow />} */}
                {shopState === ShopState.REINFORCES && <ReinforcementTradeWindow />}
                {shopState === ShopState.SELL_REINF && <SellReinforcementTradeWindow />}
                {/* {shopState === ShopState.SELL_POST && <OutpostTradeWindow />} */}
            </ClickWrapper>

            <div style={{ width: "100%", height: "10%", position: "relative" }}></div>
            <div style={{ width: "100%", height: "8%", position: "relative", display: "flex", justifyContent: "center", alignItems: "center" }}>
                <div style={{ height: "100%", width: "9%" }}></div>
                <div style={{ height: "100%", width: "82%" }}></div>
            </div>

            {shopState === ShopState.REINFORCES && <div className="global-button-style invert-colors " style={{ display: "inline-block", padding: "5px 10px", fontSize: "1vw" }} onClick={() => { setShopState(ShopState.SELL_REINF) }}>Sell Reinforcements</div>}
            {shopState === ShopState.OUTPOST && <div className="global-button-style invert-colors " style={{ display: "inline-block", padding: "5px 10px", fontSize: "1vw" }} onClick={() => { setShopState(ShopState.SELL_POST) }}>Sell Outposts</div>}

        </div>
    )
}













