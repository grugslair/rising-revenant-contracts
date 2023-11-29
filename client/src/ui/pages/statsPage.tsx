import React from "react";

import "./PagesStyles/StatsPageStyle.css";
import "../../App.css"

import { MenuState } from "./gamePhaseManager";
import { ClickWrapper } from "../clickWrapper";

interface StatsPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const StatsPage: React.FC<StatsPageProps> = ({ setMenuState }) => {
    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    const sortList = () => { };

    const refreshList = () => { };

    return (
        <ClickWrapper className="stats-page-container">
            <div className="title-section">
                <h2>STATISTICS</h2>
            </div>
            <div className="content-section">
                <div className="stats-section">
                    <div className="list-container">
                        <div className="list-title-section">

                            <h2>NAME OF FIELD  
                                <img className="icon" src="LOGO_WHITE.png" alt="add button" onMouseDown={() => { refreshList() }} /> 
                                <img className="icon" src="LOGO_WHITE.png" alt="add button" onMouseDown={() => { sortList() }} />
                            </h2>

                        </div>
                        <div className="item-container"></div>
                    </div>
                </div>
                <div className="stats-section">
                    <div className="list-container">
                        <div className="list-title-section">

                            <h2>NAME OF FIELD  
                                <img className="icon" src="LOGO_WHITE.png" alt="Sort Data" onMouseDown={() => { refreshList() }} /> 
                                <img className="icon" src="LOGO_WHITE.png" alt="Reload Data" onMouseDown={() => { sortList() }} />
                            </h2>

                        </div>
                        <div className="item-container">
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                            <div className="item">NAME OF FIELD</div>
                        </div>
                    </div>
                </div>
                <div className="stats-section">

                </div>
            </div>
            <div className="top-right-button" onMouseDown={() => {closePage()}}>X</div>
        </ClickWrapper>
    );
};
