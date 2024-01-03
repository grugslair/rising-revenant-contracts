//libs
import { ClickWrapper } from "../../clickWrapper"
import { MenuState } from "../gamePhaseManager";
import React, { useEffect, useState } from "react"
import { Checkbox, Grid, Switch, TextField, Tooltip, colors } from "@mui/material";
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
import { fetchAllTrades, hexToNumber, truncateString } from "../../../utils";
import { CreateTradeFor1Reinf, PurchaseTradeReinf, RevokeTradeReinf } from "../../../dojo/types";
import { GAME_CONFIG_ID, MAP_HEIGHT } from "../../../utils/settingsConstants";
import { Trade, TradeEdge, World__Entity } from "../../../generated/graphql";
import { Maybe } from "graphql/jsutils/Maybe";

// import Dropdown from 'react-dropdown';
import 'react-dropdown/style.css';
import { ReinforcementCountElement } from "../../Elements/reinfrocementBalanceElement";
import CounterElement from "../../Elements/counterElement";
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

            {shopState === ShopState.SELL_POST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { setShopState(ShopState.OUTPOST) }} ></PageTitleElement>}
            {shopState === ShopState.OUTPOST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} ></PageTitleElement>}
            {shopState === ShopState.REINFORCES && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} right_html_element={<ReinforcementCountElement />}></PageTitleElement>}
            {shopState === ShopState.SELL_REINF && <PageTitleElement name={"TRADES"} rightPicture={"Icons/Symbols/left_arrow.svg"} closeFunction={() => { setShopState(ShopState.REINFORCES) }} right_html_element={<ReinforcementCountElement />} picStyle={{ padding: "5%" }} />}

            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                {/* <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div> */}
                <div style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <Tooltip title="COMING SOON!!!">
                        <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                    </Tooltip>
                </div>

                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES && shopState !== ShopState.SELL_REINF ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > REINFORCEMENTS</div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "7%", position: "relative" }} ></div>

            <ClickWrapper style={{ width: "100%", height: "50%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
                {shopState === ShopState.OUTPOST && <OutpostTradeWindow />}
                {shopState === ShopState.REINFORCES && <ReinforcementTradeWindow />}
                {shopState === ShopState.SELL_REINF && <CreateReinforcementTradeWindow />}
                {shopState === ShopState.SELL_POST && <OutpostTradeWindow />}
            </ClickWrapper>

            <div style={{ width: "100%", height: "10%", position: "relative" }}></div>
            <div style={{ width: "100%", height: "8%", position: "relative", display: "flex", justifyContent: "center", alignItems: "center" }}>
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




interface ItemListingProp {
    guest: number
    entityData: any
    game_id: number
}

// this should take the trade id 
const OutpostListingElement: React.FC<ItemListingProp> = ({ guest, entityData, game_id }) => {

    const [shieldsAmount, setShieldsAmount] = useState<number>(5);
    //get the data of the outpost and trade

    return (
        <div className="outpost-sale-element-container">
            <div className="outpost-grid-pic">
                <img src="test_out_pp.png" className="test-embed" alt="" style={{ width: "100%", height: "100%" }} />
            </div>

            <div className="outpost-grid-shield center-via-flex">
                <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: "2px", width: "100%", height: "50%" }}>
                    {Array.from({ length: 5 }, (_, index) => (
                        index < shieldsAmount ? (
                            <img key={index} src="SHIELD.png" alt={`Shield ${index + 1}`} style={{ width: "100%", height: "100%" }} />
                        ) : (
                            <div key={index} style={{ width: "100%", height: "100%" }} />
                        )
                    ))}
                </div>
            </div>

            <div className="outpost-grid-id outpost-flex-layout "># 74</div>
            <div className="outpost-grid-reinf-amount outpost-flex-layout ">Reinforcement: 54</div>
            <div className="outpost-grid-owner outpost-flex-layout" >Owner: 0x636...13</div>
            <div className="outpost-grid-show outpost-flex-layout ">
                <h3 style={{ backgroundColor: "#2F2F2F", padding: "3px 5px" }}>Show on map</h3>
            </div>
            <div className="outpost-grid-cost outpost-flex-layout ">Price: $57 LORDS</div>
            <div className="outpost-grid-buy-button center-via-flex">
                {guest ? (<h3 style={{ fontWeight: "100", fontFamily: "Zelda", color: "black", filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</h3>) : (<h3 style={{ fontWeight: "100", fontFamily: "Zelda", color: "black" }}>BUY NOW</h3>)}
            </div>
        </div>
    )
}


const ReinforcementListingElement = ({ trade }: { trade: Maybe<World__Entity> | undefined }) => {
    const trade_model = trade?.models?.find((m) => m?.__typename == 'Trade') as Trade;

    const {
        account: { account },
        networkLayer: {
            network: { clientComponents },
            systemCalls: { revoke_trade_reinf, purchase_trade_reinf }
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

    const buyTrade = () => {
        const buyTradeProp: PurchaseTradeReinf = {
            account: account,
            game_id: clientGameDate.current_game_id,
            trade_id: trade_model?.entity_id,
            revenant_id: 1
        }

        purchase_trade_reinf(buyTradeProp)
    }

    if (trade_model?.status !== 1) {
        return (<></>)
    }

    return (

        <ClickWrapper className="reinforcement-sale-element-container ">
            <div style={{ gridColumn: "1/11", whiteSpace: "nowrap", display: "flex", flexDirection: "row", fontSize: "1.8rem" }}>
                <div style={{ flex: "0.55", display: "flex", alignItems: "center", justifyContent: "flex-start", padding: "0px 1%" }}>
                    Maker: {account.address === trade_model?.seller ? "You" : truncateString(trade_model?.seller, 5)}
                </div>
                <div style={{ flex: "1", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {trade_model?.count}
                </div>
                <div style={{ flex: "0.75", display: "flex", alignItems: "center", justifyContent: "flex-end", padding: "0px 1%" }}>
                    {account.address === trade_model?.seller ? <Tooltip title="Click to change price"><div className="pointer">Price: ${Number(BigInt(trade_model?.price))} LORDS</div></Tooltip> : <div>Price: ${hexToNumber(trade_model?.price)} LORDS</div>}
                </div>
            </div>

            {/* we need to add the change price thing */}
            {clientGameDate.guest ? <div className="reinf-grid-buy-button center-via-flex" style={{ filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</div> :
                <>
                    {account.address === trade_model?.seller ? <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => revokeTrade()} >REVOKE</div> : <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => buyTrade()}>BUY NOW</div>}
                </>}


        </ClickWrapper >
    );
};





// https://github.com/cartridge-gg/beer-baron/blob/main/client/src/ui/modules/TradeTable.tsx

// use this somewhere
// const interval = setInterval(() => {
//     view_beer_price({ game_id, item_id: beerType })
//         .then(price => setPrice(price))
//         .catch(error => console.error('Error fetching hop price:', error));
// }, 5000);

//both of these windows need to be redone and put into different files maybe into a folder in the pages

// const DumbReinforcementListing: React.FC<{ type: number }> = ({ type }) => {
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








const OutpostTradeWindow: React.FC = () => {


    return (
        <>

        </>
    )
}

// on  the price change just click the price wiht a tooltip



enum SortingMethods {
    NONE,
    COST,
    REINF,
    LOCATION,
    OUT_ID,
    SELLER_ADDR,
};

const sortingOutpost = [
    {
        value: 'None',
        label: SortingMethods.NONE,
    },
    {
        value: 'price',
        label: SortingMethods.COST,
    },
    {
        value: 'Location',
        label: SortingMethods.LOCATION,
    },
    {
        value: 'Reinforcement Amount',
        label: SortingMethods.REINF,
    },
    {
        value: 'Outpost IDs',
        label: SortingMethods.OUT_ID,
    },
    {
        value: 'Specific Sellers',
        label: SortingMethods.SELLER_ADDR,
    },
];

const items = [
    {
        label: 'None',
        key: "1",
    },
    {
        label: 'Price',
        key: "2",
    },
    {
        label: 'Reinforcement Amount',
        key: "3",
    },
    // {
    //     label: 'Specific Sellers',
    //     key: "4",
    // },
];





// THIS ALL NEEDS TO BE BROKEN DOWN INTO COMPONENTS BY EACHOTHER OTHERWISE THIS BECOMES A MESS
const ReinforcementTradeWindow: React.FC = () => {

    const [refresh, setRefresh] = useState<boolean>(false);
    const [tradeList, setTradeList] = useState<any | undefined[]>([]);

    const [showOthersTrades, setShowOthersTrades] = useState<boolean>();   // checkboxes
    const [invertTrade, setInvertTrade] = useState<boolean>();
    const [showYourTrades, setShowYourTrades] = useState<boolean>();

    const [minValue, setMinValue] = useState<number | null>(1);
    const [maxValue, setMaxValue] = useState<number | null>(2);
    const [stringOfAddresses, setStringOfAddresses] = useState<string>("");

    const [selectedSortingMethod, setSelectedSortingMethod] = useState<string>("1");

    //MAKE THE RIUNEF ADDRESS THINGTHE FULL THIGN SO WE CAN JUST QUERY THE WHOLE THING

    const {
        networkLayer: {
            network: { clientComponents, graphSdk }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {

        const trades = async () => {
            const tradesModels = await fetchAllTrades(graphSdk, clientGameData.current_game_id, 1);
            return setTradeList(tradesModels?.edges);
        };
        trades();

    }, [refresh])


    useEffect(() => {

       console.error(tradeList)

    }, [tradeList])

    useEffect(() => {
        console.error(selectedSortingMethod)
        // console.error(items.find(item => item.key === selectedSortingMethod)?.label )
    }, [selectedSortingMethod])

    const onClick = ({ key }) => {
        setSelectedSortingMethod(key);
        setMinValue(1);
        setMaxValue(2);
    };

    const createGraphQlRequestGTELTE = async ( nameOfVar: string) => {
        // Extract the GraphQL structure at the specified index
        if (maxValue! <= minValue!) {return;}

        const selectedStructure = graphqlStructureForReinforcements[0];
        
        let graphqlRequest = "";

        const orderDirection = invertTrade ? 'DESC' : 'ASC';

        graphqlRequest = selectedStructure
            .replace('DIR', orderDirection)
            .replace('FIELD_NAME', nameOfVar.toUpperCase())
            .replace('NUM_DATA', "25")
            .replace('GAME_ID', clientGameData.current_game_id.toString())
            .replace('LTE_VAR', nameOfVar+"LTE")
            .replace('MAX_VAL', (nameOfVar === "price" ? '"'+maxValue!.toString()+'"' :  maxValue!.toString()))
            .replace('GTE_VAR', nameOfVar+"GTE")
            .replace('MIN_VAL', (nameOfVar === "price" ? '"'+minValue!.toString()+'"' :  minValue!.toString()));
       
        const endpoint = import.meta.env.VITE_PUBLIC_TORII; 

        try {
            const data: any = await request(endpoint, graphqlRequest);
            setTradeList(data.tradeModels?.edges)

        } catch (error) {
            console.error('Error executing GraphQL query:', error);
            throw error;
        }
    };



    //issue
    const fetchSpecificUsers = async () => {

        const arrOfAddresses = extractAddresses(stringOfAddresses);
        
        for (let index = 0; index < arrOfAddresses.length; index++) {
            const element = arrOfAddresses[index];
            


        }
    }

    const extractAddresses = (inputString) => {
        const addresses = inputString.split('/').filter(address => {
            return address;
        });
    
        return addresses;
    };

    return (
        <>
            <div style={{ height: "100%", width: "9%" }}></div>
            <div style={{ backgroundColor: "#2F2F2F", height: "100%", width: "20%", border: "5px solid var(--borderColour)", boxSizing: "border-box", color: "white", borderRadius: "3px" }}>

                <div style={{ height: "15%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", flexDirection: "row", padding: "0px 5%", boxSizing: "border-box" }}>
                    <div style={{ height: "100%", width: "40%", display: "flex", justifyContent: "flex-start", alignItems: "center", fontSize: "1vw" }}>Sort Method</div>
                    {/* this si for the drop down menu that actually appears */}
                    <Dropdown
                        menu={{
                            items,
                            onClick,
                        }}
                        placement="bottom"
                    >
                        {/* the drop down is for the menu that comes out */}
                        <a onClick={(e) => e.preventDefault()} className="pointer" style={{ backgroundColor: "#D0D0D0", width: "60%", height: "80%", display: "flex", justifyContent: "flex-start", alignItems: "center", borderRadius: "4px", color: "black", padding: "1% 2%", boxSizing: "border-box", fontWeight: "100", fontFamily: "OL" }}>
                            <Space style={{ width: "100%", fontSize: "1rem", }}>
                                {items.find(item => item.key === selectedSortingMethod.toString())?.label || 'None'}
                            </Space>
                        </a>
                    </Dropdown>
                </div>

                <div style={{ height: "65%", width: "100%", padding: "2% 2%", boxSizing: "border-box", display: "flex", justifyContent: "flex-start", alignItems: "center", flexDirection: "column" }}>

                    {selectedSortingMethod === "1" && <div style={{ height: "100%", width: "100%" }} className="center-via-flex">
                        <div className="global-button-style" style={{ fontSize: "1rem", padding: "5px 10px" }} onClick={() => setRefresh(!refresh)}>Refresh latest trades</div>
                    </div>}

                    {selectedSortingMethod === "2" && <div style={{ display: "grid", gridTemplateRows: "repeat(5,1fr)", gridTemplateColumns: "repeat(2,1fr)", height: "100%", width: "100%", fontWeight: "100", fontFamily: "OL" }}>
                        <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                            <h1 style={{ fontSize: "1.2vw", textAlign: "center" }}>Set Cost Range</h1>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h1 style={{ textAlign: "center", fontSize: "1.3rem" }}>Min</h1>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h1 style={{ textAlign: "center", fontSize: "1.3rem" }}>Max</h1>
                        </div>
                        <div style={{ gridRow: "3/4", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-start", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber  min={1} max={maxValue!} value={minValue} onChange={setMinValue}  placeholder="Min price" style={{ backgroundColor: "white", height: "70%",  width:"100%", fontSize: "1rem" }} />
                        </div>
                        {/* stringMode step="0.0001" */}
                        <div style={{ gridRow: "3/4", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-start", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber min={minValue!} max={1000} value={maxValue} onChange={setMaxValue} placeholder="Max price" style={{ backgroundColor: "white", height: "70%", width:"100%",fontSize: "1rem" }} />
                        </div>

                        <div style={{ gridRow: "5/6", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                            <div className="global-button-style" style={{ fontSize: "1rem", padding: "5px 10px" }} onClick={() => {createGraphQlRequestGTELTE("price");    } }>Refresh</div>
                        </div>

                    </div>}

                    {selectedSortingMethod === "3" && <div style={{ display: "grid", gridTemplateRows: "repeat(5,1fr)", gridTemplateColumns: "repeat(2,1fr)", height: "100%", width: "100%", fontWeight: "100", fontFamily: "OL" }}>
                        <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                            <h1 style={{ fontSize: "1.5rem", textAlign: "center" }}>Set Reinforcement Range</h1>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h1 style={{ textAlign: "center", fontSize: "1.3rem" }}>Min</h1>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h1 style={{ textAlign: "center", fontSize: "1.3rem" }}>Max</h1>
                        </div>
                        <div style={{ gridRow: "3/4", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-start", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber  min={1} max={maxValue!} value={minValue} onChange={setMinValue} precision={0} placeholder="Min Reinforcement" style={{ backgroundColor: "white", height: "70%",  width:"100%", fontSize: "1rem" }} />
                        </div>
                        <div style={{ gridRow: "3/4", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-start", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber min={minValue!} max={20} value={maxValue} onChange={setMaxValue} precision={0} placeholder="Max Reinforcement" style={{ backgroundColor: "white", height: "70%", width:"100%",fontSize: "1rem" }} />
                        </div>

                        <div style={{ gridRow: "5/6", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                            <div className="global-button-style" style={{ fontSize: "1rem", padding: "5px 10px" }} onClick={() => {createGraphQlRequestGTELTE("count");    } }>Refresh</div>
                        </div>

                    </div>}

                    {selectedSortingMethod === "4" &&
                        <div style={{ display: "grid", gridTemplateRows: "repeat(5,1fr)", gridTemplateColumns: "repeat(2,1fr)", height: "100%", width: "100%", fontWeight: "100", fontFamily: "OL" }}>
                            <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                                <h1 style={{ fontSize: "1.5rem", textAlign: "center" }}>Look for Specific Seller</h1>
                            </div>
                            <div style={{ gridRow: "2/5", gridColumn: "1/3", width: "100%", height: "100%" }}>
                                <Input.TextArea placeholder="Input the whole address you want to follow. for multiple addresses use slash `/` " onChange={(e) => setStringOfAddresses(e.target.value)} autoSize style={{ fontSize: "0.6vw", height: "100%" }} />
                            </div>

                            <div style={{ gridRow: "5/6", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                                <div className="global-button-style" style={{ fontSize: "1rem", padding: "5px 10px" }} onClick={() => fetchSpecificUsers()}>Refresh</div>
                            </div>
                        </div>
                    }

                </div>

                <div style={{ height: "20%", width: "100%", display: "flex", justifyContent: "space-around", alignItems: "flex-start", flexDirection: "column", color: "white", padding: "5px 10px", boxSizing: "border-box" }}>
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={showYourTrades} onChange={() => setShowYourTrades(!showYourTrades)} />} label={"Show your trades"} />
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={showOthersTrades} onChange={() => setShowOthersTrades(!showOthersTrades)} />} label={"Show other people trades"} />
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={invertTrade} onChange={() => setInvertTrade(!invertTrade)} />} label={"Invert order"} />
                </div>

            </div>
            <div style={{ height: "100%", width: "2%" }}></div>
            <div style={{ height: "100%", width: "60%", overflowY: "auto" }}>
                {tradeList.map((trade: TradeEdge, index: number) => {
                    return <ReinforcementListingElement trade={trade.node?.entity} key={index} />;
                })}

            </div>
            <div style={{ height: "100%", width: "9%" }}></div>
        </>
    );
}











const CreateReinforcementTradeWindow: React.FC = () => {

    const [numberValue, setNumberValue] = useState<number | null>(1);
    const [amountToSell, setAmountToSell] = useState<number>(0);

    // const handleNumberChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    //     const input = event.target.value;
    //     if (!isNaN(Number(input)) || input === '') {
    //         setNumberValue(input);
    //     }
    // };

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents },
            systemCalls: { create_trade_reinf }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]))
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]))

    useEffect(() => {

        if (playerInfo === undefined) { return; }

        if (amountToSell < 0) {
            setAmountToSell(0)
            return;
        }

        if (amountToSell > playerInfo.reinforcement_count) {
            setAmountToSell(playerInfo.reinforcement_count);
        }

    }, [account, playerInfo, amountToSell])

    const confirmCreationOfOrder = async () => {

        const createTradeProp: CreateTradeFor1Reinf = {
            account: account,
            game_id: clientGameData.current_game_id,
            count: amountToSell,
            price: numberValue!,
        };

        await create_trade_reinf(createTradeProp);
    };

    //HERE THE NUMBER IS CUT OFF A BIT AT THE TOP AND PROB SHOULD NOT BE FREELY GOING UP LIKE THIS NEEDS A CLAMP

    return (
        <>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ height: "100%", width: "40%" }}>
                <img src="./assets/Page_Bg/REINFORCEMENT_PAGE_BG.png" style={{ height: "100%", width: "100%" }}></img>
            </div>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ height: "100%", width: "20%", display: "flex", flexDirection: "column", color: "white" }}>

                <div style={{ flex: "1", display: "flex", justifyContent: "flex-start", flexDirection: "column" }}>
                    <h2 style={{ fontSize: "1.7vw", margin: "0px", whiteSpace: "nowrap", height: "50%" }}>Sell Reinforcements</h2>
                    <CounterElement value={amountToSell} setValue={setAmountToSell} containerStyleAddition={{ maxWidth: "75%", height: "40%", marginBottom: "9%" }} additionalButtonStyleAdd={{ width: "15%" }} textAddtionalStyle={{ fontSize: "2vw" }} />
                </div>

                <div style={{ flex: "1", display: "flex", justifyContent: "center", flexDirection: "column" }}>
                    <h2 style={{ fontSize: "1.7vw", margin: "0px", whiteSpace: "nowrap", height: "50%" }}>Set Price</h2>
                    <ConfigProvider
                        theme={{
                            token: {
                                colorText: "white"
                            },
                        }}>
                        <InputNumber min={1} max={20} value={numberValue} onChange={setNumberValue} style={{ backgroundColor: "#131313", color: "white", borderColor: "#2D2D2D", width: "60%", height: "45%", fontSize: "1.5rem" }} />
                    </ConfigProvider>
                </div>

                <div style={{ flex: "1", display: "flex", justifyContent: "flex-end", flexDirection: "column", alignContent: "flex-end" }}>
                    <h3 style={{ margin: "0px", whiteSpace: "nowrap", height: "20%" }}>Current Trades available: X</h3>
                    <div className="global-button-style" style={{ padding: "5px 10px", maxWidth: "fit-content", margin: "0px", fontSize: "1.2vw" }} onClick={confirmCreationOfOrder}>Confirm</div>
                </div>

            </div>

            <div style={{ height: "100%", width: "20%" }}></div>
        </>
    )
}



