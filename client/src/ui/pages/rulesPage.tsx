//libs
import React from "react";
import { MenuState } from "./gamePhaseManager";

//styles
import "./PagesStyles/RulesPageStyles.css"
import PageTitleElement from "../Elements/pageTitleElement";

//elements/components

//pages

/*notes
should just be a block of text with the rules not really much to do here
only issue might be with the set menu state
*/

interface RulesPageProps {
    setUIState: () => void;
}

export const RulesPage: React.FC<RulesPageProps> = ({ setUIState }) => 
{
    return (
        <div className="game-page-container">
            <img className="page-img" src="./assets/Page_Bg/RULES_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"RULES"} rightPicture={"close_icon.svg"} closeFunction={setUIState} ></PageTitleElement>
        </div>
    )
}
