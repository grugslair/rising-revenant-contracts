import React from "react";

import "./PagesStyles/RevenantJurnalPageStyles.css";

import { MenuState } from "./gamePhaseManager";


interface RevenantjurnalPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const RevenantJurnalPage: React.FC<RevenantjurnalPageProps> = ({ setMenuState }) => {

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="revenant-jurnal-page-container">
        </div>
    );
};
