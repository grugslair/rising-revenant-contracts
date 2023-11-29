//libs
import { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { useDojo } from "../../hooks/useDojo";

import { ClickWrapper } from "../clickWrapper";

//styles

//components
import { VideoComponent } from "./videoPage";
import { TopBarComponent } from "../Components/mainTopBar";
import { BuyRevenantPage } from "./summonRevenantPage";
import { BuyReinforcementPage } from "./buyReinforcementsPage";
import { PrepPhaseEndsPage } from "./preparationPhaseEndsPage";
import { WaitForTransactionPage } from "./waitForTransactionPage";
import { DebugPage } from "../Pages/debugPage";

import { PrepPhaseNavbarComponent } from "../Components/navbar";
import { ProfilePage } from "../Pages/profilePage";
import { RulesPage } from "../Pages/rulesPage";

export enum PrepPhaseStages {
    VID,
    BUY_REVS,
    WAIT_TRANSACTION,
    BUY_REIN,
    WAIT_PHASE_OVER,
    RULES,
    PROFILE,
    DEBUG
}

export const PrepPhaseManager = () => {

    const [prepPhaseStage, setPrepPhaseStage] = useState<PrepPhaseStages>(PrepPhaseStages.VID);

    const [showBlocks, setShowBlocks] = useState(false);
    const [blocksLeft, setBlocksLeft] = useState(0);

    const [lastSavedState, setLastSavedState] = useState<PrepPhaseStages>(PrepPhaseStages.VID);

    useEffect(() => {
        const handleKeyPress = (event: KeyboardEvent) => {

            if (event.key === 'j') {
                if (prepPhaseStage === PrepPhaseStages.DEBUG) {
                    setPrepPhaseStage(PrepPhaseStages.BUY_REVS);
                } else {
                    setPrepPhaseStage(PrepPhaseStages.DEBUG);
                }
            }
        };

        window.addEventListener('keydown', handleKeyPress);

        return () => {
            window.removeEventListener('keydown', handleKeyPress);
        };
    }, [prepPhaseStage]);

    // this useeffect is used so we can save the last state for the navbar retreat
    useEffect(() => {

        if (prepPhaseStage === PrepPhaseStages.PROFILE || prepPhaseStage === PrepPhaseStages.RULES)
        {
            return;
        }
        else
        {
            setLastSavedState(prepPhaseStage);
        }

    }, [prepPhaseStage]);


    const onVideoDone = () => {
        setPrepPhaseStage(PrepPhaseStages.BUY_REVS);
    }

    if (prepPhaseStage === PrepPhaseStages.VID) {
        return (<VideoComponent onVideoDone={onVideoDone} />)
    }

    const setMenuState = (state: PrepPhaseStages) => {
        setPrepPhaseStage(state);
    }

    return (<div className="main-page-container-layout">
        <div className='main-page-topbar'>
            <TopBarComponent />
        </div>

        <div className='main-page-content'>
            <div className='page-container' style={{ backgroundColor: "white" }}>
                {prepPhaseStage === PrepPhaseStages.BUY_REVS && <BuyRevenantPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.WAIT_TRANSACTION && <WaitForTransactionPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.BUY_REIN && <BuyReinforcementPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.WAIT_PHASE_OVER && <PrepPhaseEndsPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.DEBUG && <DebugPage />}
                {prepPhaseStage === PrepPhaseStages.PROFILE && <ProfilePage/>}
                {prepPhaseStage === PrepPhaseStages.RULES && <RulesPage/>}
            </div>
        </div>

        <ClickWrapper className='prep-phase-text' style={{fontSize:"0.7cqw"}}  onMouseDown={() => { setShowBlocks(!showBlocks) }}> <h2> Preparation phase ends in <br /> {showBlocks ? "DD: 5 HH: 5 MM: 5 SS: 5" : `${blocksLeft} Blocks`}</h2></ClickWrapper>
        <PrepPhaseNavbarComponent currentMenuState={prepPhaseStage} lastSavedState={lastSavedState} setMenuState={setMenuState}/>
    </div>);
};
