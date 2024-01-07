//libs
import { ClickWrapper } from "../../clickWrapper"
import { MenuState } from "../gamePhaseManager";
import React, { useEffect, useState } from "react"
import { Box, Checkbox, Grid, Switch, TextField, Tooltip, colors } from "@mui/material";
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select, { SelectChangeEvent } from '@mui/material/Select';
import Slider from '@mui/material/Slider';
import { getComponentValueStrict, HasValue, Has } from '@latticexyz/recs';
import { useEntityQuery, useComponentValue } from '@latticexyz/react';
import { request } from 'graphql-request';

import FormControlLabel from '@mui/material/FormControlLabel';
import { Dropdown, Space, Typography, Input, InputNumber, ConfigProvider } from "antd";


//styles
import "./TradesPageStyles.css"


//elements/components
import PageTitleElement from "../../Elements/pageTitleElement"

import { useDojo } from "../../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { fetchAllTrades, getCount, hexToNumber, truncateString } from "../../../utils";
import { CreateTradeForReinf, ModifyTradeReinf, PurchaseTradeReinf, RevokeTradeReinf } from "../../../dojo/types";
import { GAME_CONFIG_ID, MAP_HEIGHT } from "../../../utils/settingsConstants";
import { Trade, TradeEdge, World__Entity } from "../../../generated/graphql";
import { Maybe } from "graphql/jsutils/Maybe";

import 'react-dropdown/style.css';
import { ReinforcementCountElement } from "../../Elements/reinfrocementBalanceElement";
import CounterElement from "../../Elements/counterElement";
import { LordsBalanceElement } from "../../Elements/playerLordsBalance";
import { SellReinforcementTradeWindow } from "./sellReinforcementsWindow";
import { ReinforcementTradeWindow } from "./reinforcementsTradeWindow";
import { OutpostTradeWindow } from "./outpostTradeWindow";
import { OutpostSellingWindow } from "./outpostSellingWindow";
//pages


// this is all a mess

/*notes
 this will be a query system but it wont be a query of the saved components instead it will be straight from the graphql return as its done in beer baroon, this is 
 to save on a little of space 

 this whle page is a mess
*/




const graphqlStructureForReinforcements = [
    `
    query {
        tradeModels(
          where: { 
            game_id: GAME_ID,
            status:1,
            LTE_VAR:MAX_VAL,
            GTE_VAR:MIN_VAL
          }
          first: NUM_DATA
          order: { direction: DIR, field: FIELD_NAME }
        ) {
          edges {
            node {
              entity {
                keys
                models {
                  __typename
                  ... on Trade {
                    game_id
                    entity_id
                    seller
                    price
                    count
                    buyer
                    status
                  }
                }
              }
            }
          }
        }
      }
      
    `
    ,
    `
  query {
    tradeModels(
      where: { 
        game_id: GAME_ID,
        status:1,
        sellet: SELLER
      }
    ) {
      edges {
        node {
          entity {
            keys
            models {
              __typename
              ... on Trade {
                game_id
                entity_id
                seller
                price
                count
                buyer
                status
              }
            }
          }
        }
      }
    }
  }
  `
]

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

            <img className="page-img brightness-down" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />

            {shopState === ShopState.SELL_POST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { setShopState(ShopState.OUTPOST) }}  />}
            {shopState === ShopState.OUTPOST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }}  />}
            {shopState === ShopState.REINFORCES && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }}  />}
            {shopState === ShopState.SELL_REINF && <PageTitleElement name={"TRADES"} rightPicture={"Icons/Symbols/left_arrow.svg"} closeFunction={() => { setShopState(ShopState.REINFORCES) }} picStyle={{ padding: "5%" }}  />}

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                {/* <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div> */}
                <div style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <Tooltip title="COMING SOON!!!">
                        <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda" }}> <h2 className="test-h2 no-margin">OUTPOSTS</h2></div>
                    </Tooltip>
                </div>

                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES && shopState !== ShopState.SELL_REINF ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda" }}> <h2 className="test-h2 no-margin">REINFORCEMENTS</h2></div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "7%", position: "relative" }} ></div>

            <ClickWrapper style={{ width: "100%", height: "50%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
                {shopState === ShopState.OUTPOST && <OutpostTradeWindow />}
                {shopState === ShopState.REINFORCES && <ReinforcementTradeWindow />}
                {shopState === ShopState.SELL_REINF && <SellReinforcementTradeWindow />}
                {shopState === ShopState.SELL_POST && <OutpostSellingWindow />}
            </ClickWrapper>

            <div style={{ width: "100%", height: "10%", position: "relative" }}></div>
            <div style={{ width: "100%", height: "8%", position: "relative", display: "flex", justifyContent: "center", alignItems: "center"}}>
                <div style={{ height: "100%", width: "9%" }}></div>
                <div style={{ height: "100%", width: "82%" }}>

                    {shopState === ShopState.REINFORCES && <div className="global-button-style" style={{ display: "inline-block", padding: "5px 10px", fontSize: "1vw" }} onClick={() => { setShopState(ShopState.SELL_REINF) }}>Sell Reinforcements</div>}
                    {shopState === ShopState.OUTPOST && <div className="global-button-style" style={{ display: "inline-block", padding: "5px 10px", fontSize: "1vw" }} onClick={() => { setShopState(ShopState.SELL_POST) }}>Sell Outposts</div>}

                </div>
                <div style={{ height: "100%", width: "9%" }}></div>
            </div>

        </div>
    )
}









// https://github.com/cartridge-gg/beer-baron/blob/main/client/src/ui/modules/TradeTable.tsx

// use this somewhere
// const interval = setInterval(() => {
//     view_beer_price({ game_id, item_id: beerType })
//         .then(price => setPrice(price))
//         .catch(error => console.error('Error fetching hop price:', error));
// }, 5000);





