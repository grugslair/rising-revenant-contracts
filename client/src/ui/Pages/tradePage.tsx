//libs
import { ClickWrapper } from "../clickWrapper"
import { MenuState } from "./gamePhaseManager";
import { useEffect, useState } from "react"
import { Switch } from "@mui/material";
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select, { SelectChangeEvent } from '@mui/material/Select';
import Slider from '@mui/material/Slider';

import FormControlLabel from '@mui/material/FormControlLabel';

//styles
import "./PagesStyles/TradesPageStyles.css"


//elements/components
import PageTitleElement from "../Elements/pageTitleElement"
import { MAP_HEIGHT } from "../../phaser/constants";


//pages

/*notes
 this will be a query system but it wont be a query of the saved components instead it will be straight from the graphql return as its done in beer baroon, this is 
 to save on a little of space 
*/


enum ShopState {
    OUTPOST,
    REINFORCES
}

interface TradesPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const TradesPage: React.FC<TradesPageProps> = ({ setMenuState }) => {

    const [shopState, setShopState] = useState<ShopState>(ShopState.OUTPOST);

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} ></PageTitleElement>

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div>
                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > REINFORCEMENTS</div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>
            <ClickWrapper style={{ width: "100%", height: "70%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row", padding: "10px" }}>

                {shopState === ShopState.OUTPOST ? (
                    <OutpostTradeWindow />

                ) : (
                    <ReinforcementTradeWindow />
                )}

            </ClickWrapper>
            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>

        </div>
    )
}



// this should take the trade id 
const OutpostListingElement: React.FC = () => {

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
                <h3 style={{ fontWeight: "100", fontFamily: "Zelda", color: "black" }}>BUY NOW</h3>
            </div>
        </div>
    )
}

const ReinforcementListingElement: React.FC = () => {

    return (
        <div className="reinforcement-sale-element-container ">
            <div className="reinf-grid-wallet center-via-flex">Wallet Id</div>
            <div className="reinf-grid-reinf-amount center-via-flex"><img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {56}</div>
            <div className="reinf-grid-cost center-via-flex">Price: $57 LORDS</div>
            <div className="reinf-grid-buy-button center-via-flex">BUY NOW</div>
        </div>
    )
}


const OutpostTradeWindow: React.FC = () => {

    const [outpostSortingState, setOutpostSortingState] = useState<string>("none");

    const [showOwnTrades, setShowOwnTrades] = useState<boolean>(false);
    const [showOthersTrades, setShowOthersTrades] = useState<boolean>(false);
    const [order, setOrder] = useState<number>(0);

    const [sliderValue, setSliderValue] = useState(0);

    const [idInputValue, setIdInputValue] = useState<string>('');

    const [xInputValue, setXInputValue] = useState<number>(1000);
    const [yInputValue, setYInputValue] = useState<number>(1000);

    // const [arrayOfOutpostTrades] = useState<enitty> there is a specific way to do this look at beer baron

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

        if (xInputValue < 0)
        {
            setXInputValue(0);
        }

        if (yInputValue < 0)
        {
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
                        

                        
                    </>)}

                    {/* ------------------------------------ */}


                    {outpostSortingState === "pos" && (<>
                        <h2>set the middle pos of the desired outpost</h2>

                        <input
                                type="number"
                                className="grid-searchbox-custom-input"
                                style={{height:"10%"}}
                                value={xInputValue}
                                onChange={(e) => setXInputValue(Number(e.target.value))}
                                placeholder="X value"
                        />

                        <input
                                type="number"
                                className="grid-searchbox-custom-input"
                                style={{height:"10%"}}
                                value={yInputValue}
                                onChange={(e) => setYInputValue(Number(e.target.value))}
                                placeholder="Y value"
                        />

                        <div style={{ display: 'flex', alignItems: 'center', padding:"5px 10px", width:"90%", boxSizing:"border-box"}}>
                            <span style={{ color: 'blue', marginRight: '10px' }}>Slider Value: {sliderValue}</span>
                            <Slider style={{ color: 'blue' }} value={sliderValue} onChange={(event, newValue) => setSliderValue(newValue as number)} defaultValue={50} aria-label="Default" valueLabelDisplay="auto" max={MAP_HEIGHT} min={0} />
                        </div>

                    </>)}


                    {/* ------------------------------------ */}


                    {outpostSortingState === "cost" && (<>
                        
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
                <OutpostListingElement />
                <OutpostListingElement />
                <OutpostListingElement />
                <OutpostListingElement />
                <OutpostListingElement />
                <OutpostListingElement />
                <OutpostListingElement />
            </div>
        </>
    )
}




const ReinforcementTradeWindow: React.FC = () => {

    const [inputValue, setInputValue] = useState<string>('');

    const handleEnterPress = () => {
        console.log(inputValue);
    };

    return (
        <>
            <div className="button-container-outpost-sale">
                <div className="button-container-outpost-grid-searchbox">
                    <input
                        type="text"
                        className="grid-searchbox-custom-input"
                        value={inputValue}
                        onChange={(e) => setInputValue(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && handleEnterPress()}
                        placeholder="Search by Address"
                    />
                </div>
                <div style={{ gridColumn: "8/10" }}>
                    <div className="grid-sort-text center-via-flex">Price Low to High</div>
                </div>
            </div>
            <div style={{
                height: "75%", width: "100%", padding: "10px", overflowY: "auto", scrollbarGutter: "stable"
            }}>
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
                <ReinforcementListingElement />
            </div>
            <div style={{ backgroundColor: "red", height: "15%", width: "100%", display: "flex", justifyContent: "flex-start", alignItems: "center" }}>

            </div>
        </>
    )
}

