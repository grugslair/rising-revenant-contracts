//libs
import React, { useEffect, useState } from "react";
import { PrepPhaseStages } from "./prepPhaseManager";
import { getComponentValueStrict } from "@latticexyz/recs";

import { ClickWrapper } from "../clickWrapper";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";

//styles
import "./PagesStyles/PrepPhaseEndsPageStyles.css";
import "./PagesStyles/BuyingPageStyle.css";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { useLeftBlockCounter } from "../Elements/leftBlockCounterElement";

//components

//pages

/*notes
    this page is fine 
*/

interface PrepPhaseEndsPageProps {
    setMenuState: React.Dispatch<PrepPhaseStages>;
}

export const PrepPhaseEndsPage: React.FC<PrepPhaseEndsPageProps> = ({ setMenuState }) => {
    const [showBlocks, setShowBlocks] = useState(true);
    const [freeRevs, setFreeRevs] = useState<number>(10);

    const {
        networkLayer: {
          network: { contractComponents, clientComponents }
        },
      } = useDojo();

    const clientGame = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    
    const gameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGame.current_game_id)]));
    const gameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGame.current_game_id)]));

    const { blocksLeftData } = useLeftBlockCounter();
    const { numberValue, stringValue } = blocksLeftData;

    useEffect(() => {
        setFreeRevs(Number(gameData.max_amount_of_revenants) - Number(gameEntityCounter.revenant_count));
    }, [gameEntityCounter, gameData]);

 
    return (
        <div className="ppe-page-container">
            <img src="./Page_Bg/PREP_PHASE_WAIT_BG.png"  alt="testPic" />
            <ClickWrapper className="content-space">
                <h1 style={{textAlign:"center", fontFamily:"Zelda"}} className="test-h1">PREPARATION PHASE ENDS IN<br/>
                    <span onMouseDown={()=> {setShowBlocks(!showBlocks)}}>{showBlocks ? `${stringValue}` : `${numberValue} Blocks`}</span>
                </h1>
                <h2 className="global-button-style invert-colors  invert-colors no-margin test-h1-5" style={{marginBottom:"2%" ,padding:"5px 10px"}} onMouseDown={() => {setMenuState(PrepPhaseStages.PROFILE)}}>Place your Reinforcements</h2>
                <div style={{height:"fit-content", display:"flex", gap:"20px", flexDirection:"row", justifyContent:"center", alignItems:"center"}}>

                {freeRevs > 0 ? (
                        <h2 onMouseDown={() => {setMenuState(PrepPhaseStages.BUY_REVS)}} className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{padding:"5px 10px"}} >Summon more Revenants</h2>
                    ) : (

                        <h2  className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{padding:"5px 10px", opacity:"0.5"}}>Summon more Revenants</h2>
                    )}
                    
                    <h2 onMouseDown={() => {setMenuState(PrepPhaseStages.BUY_REIN)}} className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{padding:"5px 10px"}}>Buy more Reinforcements</h2>
                </div>
            </ClickWrapper>
        </div>
    );
};
