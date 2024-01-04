//libs
import { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";
import {useComponentValue} from "@latticexyz/react";

import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "../../hooks/useDojo";

import { ClickWrapper } from "../clickWrapper";

//styles

//components
import { VideoComponent } from "./videoPage";
import { TopBarComponent } from "../Components/topBarComponent";
import { BuyRevenantPage } from "./summonRevenantPage";
import { BuyReinforcementPage } from "./buyReinforcementsPage";
import { PrepPhaseEndsPage } from "./preparationPhaseEndsPage";
import { WaitForTransactionPage } from "./waitForTransactionPage";
import { DebugPage } from "../Pages/debugPage";

import { PrepPhaseNavbarComponent } from "../Components/navbarComponent";
import { ProfilePage } from "../Pages/playerProfilePage";
import { RulesPage } from "../Pages/rulePage";
import { Phase } from "../phaseManager";
import { SettingsPage } from "../Pages/settingsPage";
import { GuestPagePrepPhase } from "./guestPrepPhasePage";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { blockDataTypes, useLeftBlockCounter } from "../Elements/leftBlockCounterElement";
import { fetchAllOutRevData, loadInClientOutpostData, setComponentsFromGraphQlEntitiesHM } from "../../utils";

export enum PrepPhaseStages {
    VID,
    BUY_REVS,
    WAIT_TRANSACTION,
    BUY_REIN,
    WAIT_PHASE_OVER,
    RULES,
    PROFILE,
    DEBUG,
    SETTINGS,
    GUEST,
}

interface PrepPhasePageProps {
    setUIState: React.Dispatch<Phase>;
}

export const PrepPhaseManager: React.FC<PrepPhasePageProps> = ({ setUIState }) => {

    const [prepPhaseStage, setPrepPhaseStage] = useState<PrepPhaseStages>(PrepPhaseStages.VID);

    const [showBlocks, setShowBlocks] = useState(false);

    const [lastSavedState, setLastSavedState] = useState<PrepPhaseStages>(PrepPhaseStages.VID);

    const {
        account: {account},
        networkLayer: {
            network: { clientComponents, contractComponents,graphSdk }
        },
    } = useDojo();

    const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)])); 

    // this is only here to call the debug menu
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

        if (prepPhaseStage === PrepPhaseStages.PROFILE || prepPhaseStage === PrepPhaseStages.RULES || prepPhaseStage === PrepPhaseStages.SETTINGS) {
            return;
        }
        else {
            setLastSavedState(prepPhaseStage);
        }

    }, [prepPhaseStage]);

    const { blocksLeftData } = useLeftBlockCounter();
    const { numberValue, stringValue } = blocksLeftData;

    useEffect(() => {
        const reloading = async () => {
          const gameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));
      
          const allOutpostsModels = await fetchAllOutRevData(graphSdk, clientGameData.current_game_id, gameEntityCounter.outpost_count);
          setComponentsFromGraphQlEntitiesHM(allOutpostsModels, contractComponents, true);
            
          loadInClientOutpostData(clientGameData.current_game_id, contractComponents, clientComponents, account);
        };
      
        return () => {
            if (account.address !== import.meta.env.VITE_PUBLIC_MASTER_ADDRESS){    // to delete
                reloading(); 
            }
        };
    }, [account]);

    // video stuff
    const onVideoDone = () => {
        if (clientGameData.guest)
        {
            setPrepPhaseStage(PrepPhaseStages.GUEST);
        }
        else
        {
            setPrepPhaseStage(PrepPhaseStages.BUY_REVS);
        }
    }
    if (prepPhaseStage === PrepPhaseStages.VID) {
        return (<VideoComponent onVideoDone={onVideoDone} />)
    }

    // menu state stuff
    const setMenuState = (state: PrepPhaseStages) => {
        setPrepPhaseStage(state);
    }
    const closePage = () => {
        setPrepPhaseStage(lastSavedState);
    }
    const advanceToGamePhase = () => {
        setUIState(Phase.GAME);
    }

      
    if (clientGameData.guest) {
        return (
        <div className="main-page-container-layout">
          
            <div className='main-page-content'>
                <div className='page-container' style={{ backgroundColor: "black" }}>
                {prepPhaseStage === PrepPhaseStages.GUEST && <GuestPagePrepPhase/>}
                {prepPhaseStage === PrepPhaseStages.RULES && <RulesPage setUIState={closePage} />}
                {prepPhaseStage === PrepPhaseStages.SETTINGS && <SettingsPage setUIState={closePage} />}
                </div>
            </div>

            <PrepPhaseNavbarComponent currentMenuState={prepPhaseStage} lastSavedState={lastSavedState} setMenuState={setMenuState} />
        </div>);
    }

    return (<div className="main-page-container-layout">
        <div className='main-page-topbar'>
            <TopBarComponent phaseNum={1} setGamePhase={advanceToGamePhase} />
        </div>

        <div className='main-page-content'>
            <div className='page-container' style={{ backgroundColor: "black" }}>
                {prepPhaseStage === PrepPhaseStages.BUY_REVS && <BuyRevenantPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.WAIT_TRANSACTION && <WaitForTransactionPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.BUY_REIN && <BuyReinforcementPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.WAIT_PHASE_OVER && <PrepPhaseEndsPage setMenuState={setMenuState} />}
                {prepPhaseStage === PrepPhaseStages.DEBUG && <DebugPage />}
                {prepPhaseStage === PrepPhaseStages.PROFILE && <ProfilePage setUIState={closePage} />}
                {prepPhaseStage === PrepPhaseStages.RULES && <RulesPage setUIState={closePage} />}
                {prepPhaseStage === PrepPhaseStages.SETTINGS && <SettingsPage setUIState={closePage} />}
            </div>
        </div>

        {prepPhaseStage !== PrepPhaseStages.WAIT_PHASE_OVER && <ClickWrapper className='prep-phase-text' style={{ fontSize: "0.7cqw" }} onMouseDown={() => { setShowBlocks(!showBlocks) }}> <h2> Preparation phase ends in <br /> {showBlocks ? `${stringValue}` : `${numberValue} Blocks`}</h2></ClickWrapper>}
        <PrepPhaseNavbarComponent currentMenuState={prepPhaseStage} lastSavedState={lastSavedState} setMenuState={setMenuState} />
    </div>);
};
