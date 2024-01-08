//libs
import { useState, useEffect, useRef } from 'react';
import {
  Has,
  getComponentValue,
  HasValue,
  getComponentValueStrict,
  runQuery
} from "@latticexyz/recs";
import { useEntityQuery,useComponentValue } from "@latticexyz/react";
import { useDojo } from '../../hooks/useDojo';
import { getEntityIdFromKeys } from '@dojoengine/utils';

// styles
import "./PagesStyles/MainMenuContainerStyles.css"

//elements/components
import { TopBarComponent } from '../Components/topBarComponent';
import { NavbarComponent } from '../Components/navbarComponent';
import { OutpostTooltipComponent } from '../Components/toolTipComponent';
import { JurnalEventComponent } from '../Components/jurnalEventComponent';

//pages
import { ProfilePage } from './playerProfilePage';
import { RulesPage } from './rulePage';
import { SettingsPage } from './settingsPage';
import { TradesPage } from './Trades/tradePage';
import { RevenantJurnalPage } from './revenantJurnalPage';
import { StatsPage } from './Stats/gameStatsPage';
import { WinnerPage } from './winnerPage';

import { DebugPage } from './debugPage';

/*notes
component that manages the game phase, this should deal with the update of the UI state and then update of the camera movement and any other related inputs
to phaser

should also dictate the winning state
do two simple queries one for the totla outpost and one for the totla outposts wiht 0 health and then if the total outposts - the total outposts with 0 health is less than 2
then we have a winner
*/

import { setClientCameraComponent, setClientClickPositionComponent } from '../../utils';
import { ClickWrapper } from '../clickWrapper';
import { CreateEventProps } from '../../dojo/types';
import { GAME_CONFIG_ID,  } from '../../utils/settingsConstants';
import { useCameraInteraction } from '../Elements/cameraInteractionElement';
import { DirectionalEventIndicator } from '../Components/warningSystem';

export enum MenuState {
  NONE = 0,
  PROFILE= 1,
  STATS=2 ,
  SETTINGS= 3,
  TRADES= 4,
  RULES= 5,
  REV_JURNAL= 6,
  WINNER= 7,
  Debug= 8
}

//this needs an event for the gamephase so it redraws this is called form the mapspawn script

export const GamePhaseManager = () => {
  const [currentMenuState, setCurrentMenuState] = useState(MenuState.NONE);
  const [showEventButton, setShowEventButton] = useState(false);

  const {
    account: { account },
    networkLayer: {
      network: { contractComponents, clientComponents },
      systemCalls: { create_event }
    }
  } = useDojo();

  const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

  const gameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));
  const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
  const totalOutposts = useEntityQuery([Has(contractComponents.Outpost)]);

  useCameraInteraction(currentMenuState);

  //can be custom hooked HERE
  useEffect(() => {
    const worldEvents = Array.from(runQuery([Has(contractComponents.WorldEvent)]));

    if (totalOutposts.length - outpostDeadQuery.length <= 1  && worldEvents.length > 0) {
      setCurrentMenuState(MenuState.WINNER);
    }

  }, [outpostDeadQuery]);

  // this only needs to be like this for the debug, once the game ships take out the dependency
  // useEffect(() => {
  //   const handleKeyPress = (event: KeyboardEvent) => {
  //     if (event.key === 'Escape') {
  //       setCurrentMenuState(MenuState.NONE);
  //     }

  //     if (event.key === 'j') {
  //       if (currentMenuState === MenuState.Debug) {
  //         setCurrentMenuState(MenuState.NONE);
  //       } else {
  //         setCurrentMenuState(MenuState.Debug);
  //       }
  //     }
  //   };

  //   window.addEventListener('keydown', handleKeyPress);

  //   return () => {
  //     window.removeEventListener('keydown', handleKeyPress);
  //   };
  // }, [currentMenuState]);


  // this needs to be delete from demo and only visible locally
  useEffect(() => {

    const current_block = clientGameData.current_block_number;
    const interval_for_new_event = gameData.event_interval;

    const currentLoadedEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));

    if (currentLoadedEvent === null || currentLoadedEvent === undefined) {
      setShowEventButton(true);
    }
    else {           //20                                //5
      if (currentLoadedEvent.block_number + interval_for_new_event < current_block) {
        setShowEventButton(true);
      }
      else {
        setShowEventButton(false)
      }
    }

  }, [clientGameData]);

  const createEvent = () => {
    const createEventProps: CreateEventProps = {
      account: account,
      game_id: clientGameData.current_game_id
    }

    create_event(createEventProps);
  }

  const closePage = () => {
    setCurrentMenuState(MenuState.NONE);
  }

  useMainPageContentClick(currentMenuState);

  return (
    <>
      
      <DirectionalEventIndicator/>
      <ClickWrapper className="main-page-container-layout" >
        <div className='main-page-topbar'>
          <TopBarComponent phaseNum={2} />
        </div>

        <div className='main-page-content'>
          {currentMenuState !== MenuState.NONE && (
            <div className='page-container'>
              {currentMenuState === MenuState.PROFILE && <ProfilePage setUIState={closePage} specificSetState={setCurrentMenuState}/>}
              {currentMenuState === MenuState.RULES && <RulesPage setUIState={closePage} />}
              {currentMenuState === MenuState.SETTINGS && <SettingsPage setUIState={closePage} />}
              {currentMenuState === MenuState.TRADES && <TradesPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.STATS && <StatsPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.REV_JURNAL && <RevenantJurnalPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.WINNER && <WinnerPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.Debug && <DebugPage />}
            </div>
          )}

        </div>
      </ClickWrapper>
      {/* pretty sure this is the wrong class as it doesnt make sense */}
      <div className='main-page-topbar'>
        <NavbarComponent menuState={currentMenuState} setMenuState={setCurrentMenuState} />
      </div>
      
      {currentMenuState === MenuState.NONE && <JurnalEventComponent setMenuState={setCurrentMenuState} />}
      {currentMenuState === MenuState.NONE && <OutpostTooltipComponent />}
      
      {/* {showEventButton && <ClickWrapper className='fire-button pointer' onClick={() => createEvent()}>Summon Event</ClickWrapper>} */}
      
    </>
  );
}

const useMainPageContentClick = (currentMenuState: MenuState) => {
  const {
    networkLayer: {
      network: { clientComponents },
    },
  } = useDojo();

  useEffect(() => {
    const handleClick = (event: MouseEvent) => {
      const clickedElement = event.target as HTMLElement;

      if (
        clickedElement.classList.contains('main-page-content') &&
        currentMenuState === MenuState.NONE
      ) {
        const pointXRelativeToMiddle = event.clientX -(window.innerWidth / 2 );
        const pointYRelativeToMiddle = event.clientY - (window.innerHeight / 2);

        const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

        if (event.button === 1)
        {
          setClientCameraComponent(camPos.x + pointXRelativeToMiddle, camPos.y + pointYRelativeToMiddle, clientComponents);
        }
        else if (event.button === 0)
        { 
          setClientClickPositionComponent(event.clientX, event.clientY, pointXRelativeToMiddle, pointYRelativeToMiddle, clientComponents);
        }
      }
    };

    document.addEventListener('mousedown', handleClick);

    return () => {
      document.removeEventListener('mousedown', handleClick);
    };
  }, [currentMenuState]);

};
 