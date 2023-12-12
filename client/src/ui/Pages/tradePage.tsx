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


    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { closePage() }} ></PageTitleElement>

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "20px", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw" }}>
                <div onClick={() => setShopState(ShopState.OUTPOST)} style={{ opacity: shopState !== ShopState.OUTPOST ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > OUTPOSTS</div>
                </div>
                <div onClick={() => setShopState(ShopState.REINFORCES)} style={{ opacity: shopState !== ShopState.REINFORCES ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style" style={{ textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }} > REINFORCEMENTS</div>
                </div>
            </ClickWrapper>

            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>
            <ClickWrapper style={{ width: "100%", height: "70%", position: "relative", display: "flex", justifyContent: "center", alignItems: "center" }}>
                <div style={{ width: "80%", height: "100%", }}>

                    {shopState === ShopState.OUTPOST ? (<>

                        <div style={{ height: "10%", width: "100%", display: "flex", flexDirection: "row" }}>
                            <div style={{ flex: "1" }}>

                            </div>
                            <div style={{ flex: "1", display: "flex", justifyContent: "end", alignItems: "center" }}>
                                <div className="global-button-style" style={{ height: "fit-content", display: "flex", justifyContent: "center", alignItems: "center", padding: "5px 10px", textAlign: "center" }}>test one</div>
                            </div>
                        </div>
                        <div style={{
                            height: "90%", width: "100%", padding: "10px", overflowY: "auto", scrollbarGutter: "stable",
                            display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(230px, 1fr))", gap: "10px", fontFamily: "OL"
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
                            <div style={{ height: "10%", width: "100%", display: "flex", flexDirection: "row", justifyContent: "flex-end", alignItems: "center", scrollbarGutter: "stable" }}>
                                <div className="global-button-style" style={{ padding: "5px 2px", fontFamily: "OL", boxSizing: "border-box" }}>Price low to high</div>
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

    //get the data of the outpost and trade

    return (
        <div style={{ width: "230px", height: "250px", backgroundColor: "#202020", border: "4px #717171 solid", padding: "1px", display: "flex", flexDirection: "column", textAlign: "center", boxSizing: "border-box", color: "white" }}>
            <div style={{ height: "45%", width: "100%" }}>
                <img style={{ width: "100%", height: "100%" }} src="test_out_pp.png"></img>
            </div>
            <div style={{ height: "15%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div style={{ height: "100%", width: "70%", padding: "2px 2px", display: "flex", flexDirection: "row", justifyContent: "start", gap: "3px", boxSizing: "border-box" }}>
                    <img style={{ height: "100%", flex: "1" }} src="SHIELD.png"></img>
                    <img style={{ height: "100%", flex: "1" }} src="SHIELD.png"></img>
                    <img style={{ height: "100%", flex: "1" }} src="SHIELD.png"></img>
                    <div style={{ flex: "1" }}></div>
                    <div style={{ flex: "1" }}></div>
                </div>
                <div style={{ height: "100%", width: "15%", display: "flex", justifyContent: "center", alignItems: "center", textAlign: "center" }}>#ID</div>
            </div>
            <div style={{ height: "40%", width: "100%", display: "flex", justifyContent: "flex-start", flexDirection: "column", alignItems: "start", gap: "2px", padding: "5px 5px" }}>
                <h4 style={{ margin: "0px", height: "25%" }}>Reinforcements: 35</h4>
                <h4 style={{ margin: "0px", height: "25%" }}>Owner: You</h4>
                <div style={{ padding: "2px 4px", height: "25%", backgroundColor: "#2F2F2F" }}>Show on map</div>
                <div style={{ height: "25%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", textAlign: "center" }}>
                    <div style={{ height: "100%", width: "fit-content" }}>$45 Lords</div>
                    <div style={{ height: "100%", width: "fit-content", backgroundColor: "white", color: "black", fontFamily: "Zelda", padding: "2px 5px" }}>BUY NOW</div>
                </div>
            </div>
        </div>
    )
}



const ReinforcementListingElement: React.FC = () => {

    return (
        <div style={{ width: "98%", height: "40px", backgroundColor: "#2F2F2F", display: "flex", flexDirection: "row", padding: "5px 5px", border: "3px #C0C0C0 solid", gap: "5px", textAlign: "center", color: "white", marginBottom: "15px" }}>
            <div style={{ height: "100%", width: "15%", display: "flex", justifyContent: "center", alignItems: "center" }}>Walled Id</div>
            <div style={{ height: "100%", width: "5%", display: "flex", justifyContent: "center", alignItems: "center" }}></div>
            <div style={{ height: "100%", width: "25%", display: "flex", justifyContent: "center", alignItems: "center" }}>  <img src="reinforcements_logo.png" className="test-embed" alt="" /> Reinforcements: {56}</div>
            <div style={{ height: "100%", width: "25%" }}></div>
            <div style={{ height: "100%", width: "15%", display: "flex", justifyContent: "center", alignItems: "center" }}>Price: $57 LORDS</div>
            <div style={{ height: "100%", width: "15%", backgroundColor: "#C0C0C0", color: "black", display: "flex", justifyContent: "center", alignItems: "center", fontFamily: "Zelda" }}>BUY NOW</div>
        </div>
    )
}
