//libs
import React, { useEffect, useState } from "react";
import { MenuState } from "../gamePhaseManager";

//styles
import "./StatsPageStyle.css";
import "../../../App.css"

//elements/components
import { ClickWrapper } from "../../clickWrapper";
import PageTitleElement, { ImagesPosition } from "../../Elements/pageTitleElement";
import { StatsTable } from "./statsTable";
import { WholeGameDataStats } from "./wholeGameStats";
import { SpecificPlayerLookUP } from "./specificPlayerStats";

//pages

enum StatsState {
    TABLE,
    OVERALL,
    SPECIFIC
}

interface StatsPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const StatsPage: React.FC<StatsPageProps> = ({ setMenuState }) => {

    const [statsState, setStatsState] = useState<StatsState>(StatsState.TABLE);

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <ClickWrapper className="game-page-container">

            <img className="page-img brightness-down" src="./Page_Bg/STATS_PAGE_BG.png" alt="testPic" />

            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"STATISTICS"} rightPicture={"Icons/close_icon.png"} rightImageFunction={closePage} />

            <ClickWrapper style={{ display: "flex", flexDirection: "row", justifyContent:"center", gap: "1%", position: "relative", width: "100%", height: "10%", whiteSpace:"nowrap" }}>

                <div onClick={() => setStatsState(StatsState.TABLE)} style={{ opacity: statsState !== StatsState.TABLE ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                    <div className="global-button-style invert-colors " style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px",  boxSizing: "border-box",width:"fit-content",  height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}><h2 className="test-h2 no-margin"> TABLE OF DATA</h2></div>
                </div>

                {/* <div onClick={() => setStatsState(StatsState.SPECIFIC)} style={{ opacity: statsState !== StatsState.SPECIFIC ? 0.5 : 1, display: "flex", justifyContent: "center", width:"fit-content"}}>
                    <div className="global-button-style invert-colors" style={{ textAlign: "center",whiteSpace:"nowrap", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px",  boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}> <h2 className="test-h2 no-margin"> SPECIFIC PLAYER</h2></div>
                </div> */}

                <div onClick={() => setStatsState(StatsState.OVERALL)} style={{ opacity: statsState !== StatsState.OVERALL ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <div className="global-button-style invert-colors " style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width:"fit-content", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}> <h2 className="test-h2 no-margin">OVERALL GAME DATA </h2></div>
                </div>
               
            </ClickWrapper>

            <ClickWrapper style={{ width: "100%", height: "80%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
                {statsState === StatsState.TABLE && <StatsTable />}
                {statsState === StatsState.OVERALL && <WholeGameDataStats />}
                {statsState === StatsState.SPECIFIC && <SpecificPlayerLookUP />}
            </ClickWrapper>

        </ClickWrapper>
    );
};

