//libs
import React from "react";
import { MenuState } from "./gamePhaseManager";

//styles
import "./PagesStyles/SettingPageStyle.css";
import PageTitleElement from "../Elements/pageTitleElement";

//elements/components

//pages

/*notes
    should be divide in two sections 

    one for the hold of all of the transactions done this session, this will be a dict somewhere in the codebase with the key being the tx hash and the value being the current state
    this will all be set via a promise?

    the other section is a list of setting for the player to deal with camera speed and stuff like that, no real query needed for this one
    
*/


interface SettingPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const SettingsPage: React.FC<SettingPageProps> = ({ setMenuState }) => {

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <div className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"SETTINGS"} rightPicture={"close_icon.svg"} closeFunction={closePage} ></PageTitleElement>
        </div>
    )
}
