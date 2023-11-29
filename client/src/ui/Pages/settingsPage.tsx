import React from "react";

import "./PagesStyles/SettingPageStyle.css";

import { MenuState } from "./gamePhaseManager";


interface SettingPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const SettingsPage: React.FC<SettingPageProps> = ({ setMenuState }) => 
{

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="settings-page-container">
        </div>
    )
}
