//libs
import { ClickWrapper } from "../clickWrapper"
import { MenuState } from "./gamePhaseManager";
import React, { useEffect, useState } from "react"
import { Checkbox, Grid, Switch, TextField, Tooltip, colors } from "@mui/material";
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select, { SelectChangeEvent } from '@mui/material/Select';
import Box from '@mui/material/Box';
import Slider from '@mui/material/Slider';
import { getComponentValueStrict, HasValue, Has } from '@latticexyz/recs';
import { useEntityQuery, useComponentValue } from '@latticexyz/react';

import FormControlLabel from '@mui/material/FormControlLabel';


//styles
import "./PagesStyles/TradesPageStyles.css"


//elements/components
import PageTitleElement from "../Elements/pageTitleElement"

import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { fetchAllTrades, truncateString } from "../../utils";
import { CreateTradeFor1Reinf, PurchaseTradeReinf, RevokeTradeReinf } from "../../dojo/types";
import { GAME_CONFIG_ID, MAP_HEIGHT } from "../../utils/settingsConstants";
import { Trade, TradeEdge, World__Entity } from "../../generated/graphql";
import { Maybe } from "graphql/jsutils/Maybe";

import Dropdown from 'react-dropdown';
import 'react-dropdown/style.css';
import { ReinforcementCountElement } from "../Elements/reinfrocementBalanceElement";
import CounterElement from "../Elements/counterElement";
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

            <img className="page-img brightness-down" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />

            {shopState === ShopState.SELL_POST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { setShopState(ShopState.OUTPOST) }} ></PageTitleElement>}
            {shopState === ShopState.OUTPOST && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} ></PageTitleElement>}
            {shopState === ShopState.REINFORCES && <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} right_html_element={<ReinforcementCountElement />}></PageTitleElement>}
            {shopState === ShopState.SELL_REINF && <PageTitleElement name={"TRADES"} rightPicture={"Icons/Symbols/left_arrow.svg"} closeFunction={() => { setShopState(ShopState.REINFORCES) }} right_html_element={<ReinforcementCountElement />} picStyle={{ padding: "5%" }} />}

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

            <ClickWrapper style={{ width: "100%", height: "55%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
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
                    {shopState === ShopState.OUTPOST && <div className="global-button-style" style={{ display: "inline-block", padding: "5px 10px", fontSize: "1vw" }} onClick={() => { setShopState(ShopState.SELL_REINF) }}>Sell Reinforcements</div>}

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


// const ReinforcementListingElement = ({ trade }: { trade: Maybe<World__Entity> | undefined }) => {
//     const trade_model = trade?.models?.find((m) => m?.__typename == 'Trade') as Trade;

//     const {
//         account: { account },
//         networkLayer: {
//             network: { clientComponents },
//             systemCalls: { revoke_trade_reinf, purchase_trade_reinf }
//         },
//     } = useDojo();

//     const clientGameDate = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

//     const revokeTrade = () => {
//         const revokeTradeProp: RevokeTradeReinf = {
//             account: account,
//             game_id: clientGameDate.current_game_id,
//             trade_id: trade_model?.entity_id,
//         }

//         revoke_trade_reinf(revokeTradeProp);
//     }

//     const buyTrade = () => {
//         const buyTradeProp: PurchaseTradeReinf = {
//             account: account,
//             game_id: clientGameDate.current_game_id,
//             trade_id: trade_model?.entity_id,
//             revenant_id: 1
//         }

//         purchase_trade_reinf(buyTradeProp)
//     }

//     if (trade_model?.status !== 1) {
//         return (<></>)
//     }

//     return (
//         <ClickWrapper className="reinforcement-sale-element-container ">
//             <div className="reinf-grid-wallet center-via-flex">Maker: {truncateString(trade_model?.seller, 5)}</div>
//             <div className="reinf-grid-reinf-amount center-via-flex"><img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {trade_model?.count}</div>
//             <div className="reinf-grid-cost center-via-flex">Price: ${trade_model?.price} LORDS</div>
//             {clientGameDate.guest ? (<div className="reinf-grid-buy-button center-via-flex" style={{ filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</div>) :
//                 (
//                     <>
//                         {account.address === trade_model.seller ? <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => revokeTrade()} >REVOKE</div> : <div className="reinf-grid-buy-button center-via-flex pointer" onClick={() => buyTrade()}>BUY NOW</div>}
//                     </>
//                 )
//             }
//         </ClickWrapper >
//     );
// };





// https://github.com/cartridge-gg/beer-baron/blob/main/client/src/ui/modules/TradeTable.tsx

// use this somewhere
// const interval = setInterval(() => {
//     view_beer_price({ game_id, item_id: beerType })
//         .then(price => setPrice(price))
//         .catch(error => console.error('Error fetching hop price:', error));
// }, 5000);

//both of these windows need to be redone and put into different files maybe into a folder in the pages

const DumbReinforcementListing: React.FC<{ type: number }> = ({ type }) => {
    return (
        <ClickWrapper className="reinforcement-sale-element-container ">
            <div style={{ gridColumn: "1/11", whiteSpace: "nowrap", display: "flex", flexDirection: "row", fontSize: "1.1vw" }}>
                <div style={{ flex: "0.7", display: "flex", alignItems: "center", justifyContent: "flex-start", padding: "0px 1%" }}>
                    Maker: {truncateString("0x7231897387126387di1h17ney1", 5)}
                </div>
                <div style={{ flex: "1", display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {20}
                </div>
                <div style={{ flex: "0.6", display: "flex", alignItems: "center", justifyContent: "flex-end", padding: "0px 1%" }}>
                    {type === 3 ? <Tooltip title="Click to change price"><div className="pointer">Price: ${22} LORDS</div></Tooltip> : <div>Price: ${22} LORDS</div>}
                </div>
            </div>

            {/* we need to add the change price thing */}
            {type === 1 && <div className="reinf-grid-buy-button center-via-flex" style={{ filter: "brightness(70%) grayscale(70%)" }}>BUY NOW</div>}
            {type === 2 && <div className="reinf-grid-buy-button center-via-flex pointer" >BUY NOW</div>}
            {type === 3 && <div className="reinf-grid-buy-button center-via-flex pointer" >REVOKE</div>}

        </ClickWrapper >
    );
};








const OutpostTradeWindow: React.FC = () => {

    const [outpostSortingState, setOutpostSortingState] = useState<string>("none");

    const [showOwnTrades, setShowOwnTrades] = useState<boolean>(false);
    const [showOthersTrades, setShowOthersTrades] = useState<boolean>(false);
    const [order, setOrder] = useState<number>(0);

    const [sliderValue, setSliderValue] = useState(0);

    const [idInputValue, setIdInputValue] = useState<string>('');

    const [xInputValue, setXInputValue] = useState<number>(1000);
    const [yInputValue, setYInputValue] = useState<number>(1000);

    const [multiValue, setMultiValue] = useState<number[]>([0, 20]);

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    const handleMultiValueChange = (event: Event, newValue: number | number[]) => {
        setMultiValue(newValue as number[]);
    };

    const handleEnterPress = () => {
        const numbersArray = idInputValue.split('/');

        const filteredNumbers = numbersArray
            .filter(item => /^[0-9]+$/.test(item))
            .map(Number);

        const uniqueNumbers = Array.from(new Set(filteredNumbers));

        console.log(uniqueNumbers);
    };

    const handleOutpostSortChange = (event: SelectChangeEvent) => {
        setOutpostSortingState(event.target.value);
    };

    useEffect(() => {
    }, [showOthersTrades])

    useEffect(() => {
    }, [showOwnTrades])

    useEffect(() => {

        if (xInputValue < 0) {
            setXInputValue(0);
        }

        if (yInputValue < 0) {
            setYInputValue(0);
        }

    }, [xInputValue, yInputValue])

    return (
        <>
            <div style={{ backgroundColor: "grey", height: "100%", width: "25%", display: "grid", gridTemplateRows: "repeat(8, 1fr", padding: "2% 3%", boxSizing: "border-box" }}>
                <div style={{ gridRow: "1/2" }}>
                    <FormControl fullWidth>
                        <InputLabel id="demo-simple-select-label">Sort Method</InputLabel>
                        <Select
                            labelId="demo-simple-select-label"
                            id="demo-simple-select"
                            value={outpostSortingState}
                            label="Age"
                            onChange={handleOutpostSortChange}>

                            <MenuItem value={"none"}>None</MenuItem>
                            <MenuItem value={"reinf"}>Reinforcement</MenuItem>
                            <MenuItem value={"pos"}>Position</MenuItem>
                            <MenuItem value={"cost"}>Cost</MenuItem>
                            <MenuItem value={"id"}>Id</MenuItem>

                        </Select>
                    </FormControl>
                </div>
                <div style={{ gridRow: "2/7", display: "flex", flexDirection: "column", justifyContent: "flex-start", alignItems: "center" }}>

                    {outpostSortingState === "reinf" && (<>

                        <Slider
                            getAriaLabel={() => 'Reinf range'}
                            value={multiValue}
                            onChange={handleMultiValueChange}
                            valueLabelDisplay="auto"
                            max={20}
                            min={1}
                        />
                        <h2>min {multiValue[0]}</h2>
                        <h2>max {multiValue[1]}</h2>

                    </>)}

                    {/* ------------------------------------ */}


                    {outpostSortingState === "pos" && (<>
                        <h2>set the middle pos of the desired outpost</h2>

                        <input
                            type="number"
                            className="grid-searchbox-custom-input"
                            style={{ height: "10%" }}
                            value={xInputValue}
                            onChange={(e) => setXInputValue(Number(e.target.value))}
                            placeholder="X value"
                        />

                        <input
                            type="number"
                            className="grid-searchbox-custom-input"
                            style={{ height: "10%" }}
                            value={yInputValue}
                            onChange={(e) => setYInputValue(Number(e.target.value))}
                            placeholder="Y value"
                        />

                        <div style={{ display: 'flex', alignItems: 'center', padding: "5px 10px", width: "90%", boxSizing: "border-box" }}>
                            <span style={{ color: 'blue', marginRight: '10px' }}>Slider Value: {sliderValue}</span>
                            <Slider style={{ color: 'blue' }} value={sliderValue} onChange={(event, newValue) => setSliderValue(newValue as number)} defaultValue={50} aria-label="Default" valueLabelDisplay="auto" max={MAP_HEIGHT} min={0} />
                        </div>

                    </>)}


                    {/* ------------------------------------ */}


                    {outpostSortingState === "cost" && (<>

                        <Slider
                            getAriaLabel={() => 'Cost'}
                            value={multiValue}
                            onChange={handleMultiValueChange}
                            valueLabelDisplay="auto"
                            max={9999}
                            min={1}
                        />
                        <h2>min {multiValue[0]}</h2>
                        <h2>max {multiValue[1]}</h2>
                    </>)}


                    {/* ------------------------------------ */}


                    {outpostSortingState === "id" && (<>
                        <h2>To look for specific set of currently listed Outpost</h2>

                        <h2>To look for multiple IDs use / to split the text. eg. 23/34/65</h2>

                        <input
                            type="text"
                            className="grid-searchbox-custom-input"
                            value={idInputValue}
                            onChange={(e) => setIdInputValue(e.target.value)}
                            onKeyDown={(e) => e.key === 'Enter' && handleEnterPress()}
                            placeholder="Search by Id"
                        />

                    </>)}

                </div>

                <div style={{ gridRow: "7/8", display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "column" }}>
                    <div style={{ flex: "1", width: "100%" }} className="center-via-flex">
                        <FormControlLabel control={<Switch style={{ color: 'grey' }} checked={showOthersTrades} onChange={() => setShowOthersTrades(!showOthersTrades)} />} label={"show others trades"} />
                    </div>
                    <div style={{ flex: "1", width: "100%" }} className="center-via-flex">
                        <FormControlLabel control={<Switch style={{ color: 'grey' }} checked={showOwnTrades} onChange={() => setShowOwnTrades(!showOwnTrades)} />} label={"show own trades"} />
                    </div>

                    <div style={{ flex: "1", width: "100%" }} className="center-via-flex">
                        <FormControlLabel control={<Switch style={{ color: 'grey' }} checked={showOwnTrades} onChange={() => setOrder(order + 1)} />} label={"Invert order"} />
                    </div>
                </div>

                <div style={{ gridRow: "8/9" }} className="center-via-flex">
                    {outpostSortingState !== "none" && <div className="global-button-style" style={{ padding: "5px 10px" }}>Filter</div>}
                </div>

            </div>

            <div style={{
                height: "100%", width: "70%", padding: "10px", overflowY: "auto", scrollbarGutter: "stable",
                display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", gap: "10px", fontFamily: "OL", justifyItems: "center"
            }}>
                {/* <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/>
                <OutpostListingElement guest={clientGameData.guest}/> */}
            </div>
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

const sortingReinforcements = [
    {
        value: 'None',
        label: SortingMethods.NONE,
    },
    {
        value: 'Price',
        label: SortingMethods.COST,
    },
    {
        value: 'Reinforcement Amount',
        label: SortingMethods.REINF,
    },
    {
        value: 'Specific Sellers',
        label: SortingMethods.SELLER_ADDR,
    },
];


function valuetext(value: number) {
    return `${value}°C`;
}

const ReinforcementTradeWindow: React.FC = () => {

    const [inputValue, setInputValue] = useState<string>('');
    const [refresh, setRefresh] = useState<boolean>(false);
    const [tradeList, setTradeList] = useState<any | undefined[]>([]);

    const [showOthersTrades, setShowOthersTrades] = useState<boolean>();
    const [invertTrade, setInvertTrade] = useState<boolean>();
    const [showYourTrades, setShowYourTrades] = useState<boolean>();

    const [selectedSortingMethod, setSelectedSortingMethod] = useState(SortingMethods.COST);


    const [value1, setValue1] = useState<number[]>([10, 15]);

    const handleChange1 = (
        event: Event,
        newValue: number | number[],
        activeThumb: number,
    ) => {
        if (!Array.isArray(newValue)) {
            return;
        }

        if (activeThumb === 0) {
            setValue1([Math.min(newValue[0], value1[1] - 1), value1[1]]);
        } else {
            setValue1([value1[0], Math.max(newValue[1], value1[0] + 1)]);
        }
    };

    const {
        networkLayer: {
            network: { clientComponents, graphSdk }
        },
    } = useDojo();

    const handleEnterPress = () => {
        console.log(inputValue);
    };

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {

        const trades = async () => {

            const gameTrackerData = await fetchAllTrades(graphSdk, clientGameData.current_game_id, 1);
            return setTradeList(gameTrackerData?.edges);
        };
        trades();

    }, [refresh])

    useEffect(() => {
        console.error(selectedSortingMethod)
    }, [selectedSortingMethod])

    return (
        <>
            <div style={{ height: "100%", width: "9%" }}></div>
            <div style={{ backgroundColor: "#2F2F2F", height: "100%", width: "20%", border: "5px solid var(--borderColour)", boxSizing: "border-box", color: "white",borderRadius:"3px" }}>

                <div style={{ height: "15%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", flexDirection: "row", padding: "0px 5%", boxSizing: "border-box" }}>
                    <div style={{ height: "100%", width: "20%", display: "flex", justifyContent: "flex-start", alignItems: "center", fontSize: "1vw" }}>Sort</div>
                    <TextField
                        id="reinforcement-sorting"
                        select
                        value={selectedSortingMethod}
                        onChange={(e) => setSelectedSortingMethod(Number(e.target.value))}
                        SelectProps={{
                            native: true,
                            
                        }}
                        variant="outlined"
                        size="medium"
                        margin="none"
                        InputProps={{
                            style: {
                                color: "white", // Change to the desired text color
                            },
                        }}
                        
                        
                        style={{ width: "70%", height: "100%", color: "white", display: "flex", justifyContent: "center", alignItems: "center" }}
                    >
                        {sortingReinforcements.map((option) => (
                            <option key={option.value} value={option.label}>
                                {option.value}
                            </option>
                        ))}
                    </TextField> 
                    
                </div>

                <div style={{ height: "65%", width: "100%", padding: "2% 2%", boxSizing: "border-box", display: "flex", justifyContent: "flex-start", alignItems: "center", flexDirection: "column" }}>

                    {selectedSortingMethod === SortingMethods.NONE && <></>}

                    {selectedSortingMethod === SortingMethods.COST && <>
                        <h1>Set Cost Range</h1>
                        <Box
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                                overflow: "visible",
                                '& > :not(style)': { m: 1 },
                            }}
                        >
                            <TextField
                                id="demo-helper-text-aligned"
                                label="Min Amount"
                                variant="standard"
                            />
                            <TextField

                                id="demo-helper-text-aligned-no-helper"
                                label="Max Amount"
                                variant="standard"
                            />
                        </Box>
                        <div className="global-button-style">Refresh</div>
                    </>}

                    {selectedSortingMethod === SortingMethods.REINF && <>
                        <h1>Reinforcement Range</h1>
                        <Grid container spacing={2} >

                            <Grid item>
                                <h1 style={{ margin: "0px" }}>{value1[0]}</h1>
                            </Grid>

                            <Grid item xs>
                                <Slider
                                    getAriaLabel={() => 'Minimum distance'}
                                    value={value1}
                                    onChange={handleChange1}
                                    valueLabelDisplay="auto"
                                    getAriaValueText={valuetext}
                                    disableSwap
                                    min={1}
                                    max={20}
                                />
                            </Grid>

                            <Grid item>
                                <h1 style={{ margin: "0px" }}>{value1[1]}</h1>
                            </Grid>

                        </Grid>
                        <div className="global-button-style">Refresh</div>
                    </>}

                    {selectedSortingMethod === SortingMethods.SELLER_ADDR && <></>}

                </div>

                <div style={{ height: "20%", width: "100%", display: "flex", justifyContent: "space-around", alignItems: "flex-start", flexDirection: "column", color: "white", padding: "5px 10px", boxSizing: "border-box" }}>
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={showYourTrades} onChange={() => setShowYourTrades(!showYourTrades)} />} label={"Show your trades"} />
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={showOthersTrades} onChange={() => setShowOthersTrades(!showOthersTrades)} />} label={"Show other people trades"} />
                    <FormControlLabel control={<Checkbox style={{ color: 'white' }} checked={invertTrade} onChange={() => setInvertTrade(!invertTrade)} />} label={"Invert order"} />
                </div>

            </div>
            <div style={{ height: "100%", width: "2%" }}></div>
            <div style={{ height: "100%", width: "60%", overflowY: "auto" }}>
                {/* {tradeList.map((trade: TradeEdge, index: number) => {
                    return <ReinforcementListingElement trade={trade.node?.entity} key={index} />;
                })} */}
                <DumbReinforcementListing type={1} />
                <DumbReinforcementListing type={2} />
                <DumbReinforcementListing type={3} />
                <DumbReinforcementListing type={1} />
                <DumbReinforcementListing type={2} />
                <DumbReinforcementListing type={3} />
                <DumbReinforcementListing type={2} />
                <DumbReinforcementListing type={2} />
                <DumbReinforcementListing type={3} />
                <DumbReinforcementListing type={2} />
            </div>
            <div style={{ height: "100%", width: "9%" }}></div>
        </>
    );
}











const CreateReinforcementTradeWindow: React.FC = () => {

    const [numberValue, setNumberValue] = useState<number | string>('');
    const [amountToSell, setAmountToSell] = useState<number>(0);

    const handleNumberChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const input = event.target.value;
        if (!isNaN(Number(input)) || input === '') {
            setNumberValue(input);
        }
    };

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents, graphSdk },
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
            price: numberValue,
        };

        await create_trade_reinf(createTradeProp);
    };



    return (
        <>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ backgroundColor: "#2F2F2F", height: "100%", width: "40%" }}>
                <img src="./assets/Page_Bg/REINFORCEMENT_PAGE_BG.png" style={{ height: "100%", width: "100%" }}></img>
            </div>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ height: "100%", width: "20%", display: "flex", justifyContent: "flex-start", flexDirection: "column", color: "white" }}>
                <h2 style={{ fontSize: "1.7vw", margin: "0px", whiteSpace: "nowrap" }}>Sell Reinforcements</h2>
                <CounterElement value={amountToSell} setValue={setAmountToSell} containerStyleAddition={{ maxWidth: "80%", height: "12%", backgroundColor: "green", marginBottom: "9%" }} additionalButtonStyleAdd={{ width: "15%" }} textAddtionalStyle={{ fontSize: "2vw" }} />
                <h2 style={{ fontSize: "1.7vw", margin: "0px", whiteSpace: "nowrap" }}>Set a Price</h2>

                <TextField
                    id="number-input"
                    value={numberValue}
                    onChange={handleNumberChange}
                    style={{ width: "60%" }}
                />

                <h5 style={{ marginBottom: "0px" }}>Current Active Trades: X</h5>
                <h5 style={{ marginTop: "0px" }}>Trading Volume: Y</h5>
                <div className="global-button-style" style={{ padding: "5px 10px", maxWidth: "fit-content" }} onClick={confirmCreationOfOrder}>Confirm</div>
            </div>

            {/* <div style={{ backgroundColor: "red", height: "100%", width: "20%", display: "grid", color: "white", gridTemplateRows: "repeat(9, 1fr)", gridTemplateColumns: "repeat(7, 1fr)" }}>
                <div style={{gridRow:"1/1",gridColumn:"1/8", backgroundColor:"green"}}>Sell Reinforcements</div>
                <div style={{gridRow:"2/4",gridColumn:"1/1", backgroundColor:"yellow"}}></div>
                <div style={{gridRow:"2/4",gridColumn:"1/1", backgroundColor:"yellow"}}></div>
            </div> */}

            <div style={{ backgroundColor: "green", height: "100%", width: "20%" }}></div>
        </>
    )
}



