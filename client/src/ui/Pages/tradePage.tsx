//libs
import { ClickWrapper } from "../clickWrapper"
import { MenuState } from "./gamePhaseManager";
import { useState } from "react"


//styles
import "./PagesStyles/TradesPageStyles.css"


//elements/components
import PageTitleElement from "../Elements/pageTitleElement"


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
    const [inputValue, setInputValue] = useState<string>('');

    const handleEnterPress = () => {
        // Your function logic here with the inputValue
        console.log(inputValue);
    };

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} ></PageTitleElement>

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center",backgroundColor:"#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div>
                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center",backgroundColor:"#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > REINFORCEMENTS</div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>
            <ClickWrapper style={{ width: "100%", height: "70%", position: "relative", display: "flex", justifyContent: "center", alignItems: "center" }}>
                <div style={{ width: "80%", height: "100%", }}>

                    {shopState === ShopState.OUTPOST ? (<>

                        <div className="button-container-outpost-sale">
                            <div className="button-container-outpost-grid-searchbox">
                                <input
                                    type="text"
                                    className="grid-searchbox-custom-input"
                                    value={inputValue}
                                    onChange={(e) => setInputValue(e.target.value)}
                                    onKeyDown={(e) => e.key === 'Enter' && handleEnterPress()}
                                    placeholder="Search by Outpost Id"
                                />
                            </div>
                            <div className="button-container-outpost-grid-sort">
                                <div className="grid-sort-text center-via-flex">Price Low to High</div>
                            </div>
                            <div className="grid-change-view-box">
                                <div className="center-via-flex">
                                    <img src="LOGO_WHITE.png" alt="" style={{ width: "90%", height: "90%" }} />
                                </div>
                                <div className="center-via-flex">
                                    <img src="LOGO_WHITE.png" alt="" style={{ width: "90%", height: "90%" }} />
                                </div>

                            </div>
                        </div>
                        <div style={{
                            height: "90%", width: "100%", padding: "10px", overflowY: "auto", scrollbarGutter: "stable",
                            display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", gap: "10px", fontFamily: "OL", justifyItems: "center"
                        }}>
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                            <OutpostListingElement />
                        </div>
                    </>
                    ) : (
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
                                <div style={{gridColumn:"8/10"}}>
                                    <div className="grid-sort-text center-via-flex">Price Low to High</div>
                                </div>
                            </div>
                            <div style={{
                                height: "90%", width: "100%", padding: "10px", overflowY: "auto", scrollbarGutter: "stable"
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
                        </>
                    )}

                </div>
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