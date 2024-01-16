//libs
import { useState, useEffect, useRef } from 'react';
import {
  Has,
  getComponentValue,
  HasValue,
  getComponentValueStrict,
  runQuery,
  updateComponent
} from "@latticexyz/recs";
import { useEntityQuery, useComponentValue } from "@latticexyz/react";
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
*/

import { ClickWrapper } from '../clickWrapper';
import { CreateEventProps } from '../../dojo/types';
import { GAME_CONFIG_ID, } from '../../utils/settingsConstants';
import { useCameraInteraction } from '../Elements/cameraInteractionElement';
import { DirectionalEventIndicator } from '../Components/warningSystem';
import MinimapComponent from '../Components/minimap';
import { EventConfirmPage } from './eventConfirmPage';
import MouseInputManagerDiv from '../Components/mouseInputComponent';

export enum MenuState {
  NONE = 0,
  PROFILE = 1,
  STATS = 2,
  SETTINGS = 3,
  TRADES = 4,
  RULES = 5,
  REV_JURNAL = 6,
  WINNER = 7,
  EVENT = 8,
  Debug = 9
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

  const closePage = () => {
    setCurrentMenuState(MenuState.NONE);
  }

  const clientGameData: any = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

  const gameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id)]));
  const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
  const totalOutposts = useEntityQuery([Has(contractComponents.Outpost)]);

  useCameraInteraction(currentMenuState);

  //can be custom hooked
  useEffect(() => {
    const worldEvents = Array.from(runQuery([HasValue(clientComponents.ClientOutpostData, { selected: true })]));

    if (totalOutposts.length - outpostDeadQuery.length <= 1 && worldEvents.length > 0) {
      // setCurrentMenuState(MenuState.WINNER);
    }

  }, [outpostDeadQuery]);

  // this only needs to be like this for the debug, once the game ships take out the dependency
  useEffect(() => {
    const handleKeyPress = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setCurrentMenuState(MenuState.NONE);
      }

      if (event.key === 'j') {
        if (currentMenuState === MenuState.Debug) {
          setCurrentMenuState(MenuState.NONE);
        } else {
          setCurrentMenuState(MenuState.Debug);
        }
      }
    };

    window.addEventListener('keydown', handleKeyPress);

    return () => {
      window.removeEventListener('keydown', handleKeyPress);
    };
  }, [currentMenuState]);
  // this needs to be delete from demo and only visible locally
  useEffect(() => {

    const current_block = clientGameData!.current_block_number;
    const interval_for_new_event = gameData.event_interval;

    const currentLoadedEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id), BigInt(clientGameData!.current_event_drawn)]));

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
      game_id: clientGameData!.current_game_id
    }

    create_event(createEventProps);
  }

  const handleDragStart = () => {
    console.log('Dragging started!');
  };

  const handleDragEnd = () => {
    console.log('Dragging ended!');
  };

  const checkIfClickInEvent = (overEvent: boolean) => {
    // const currentLoadedEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));
    // const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    // if (currentLoadedEvent === undefined) { return; }

    // const centerX = window.innerWidth / 2;
    // const centerY = window.innerHeight / 2;

    // const relativeClickX = clickX - centerX + camPos.x;
    // const relativeClickY = clickY - centerY + camPos.y;

    // const distance = Math.sqrt((relativeClickX - currentLoadedEvent.x) ** 2 + (relativeClickY - currentLoadedEvent.y) ** 2);

    // if (distance <= currentLoadedEvent.radius) {
    //   setCurrentMenuState(MenuState.EVENT);
    // }
  
    if (overEvent){
      setCurrentMenuState(MenuState.EVENT);
    }
  };

  return (
    <>
      <DirectionalEventIndicator />
      <ClickWrapper className="main-page-container-layout" >
        <div className='main-page-topbar'>
          <TopBarComponent phaseNum={2} />
        </div>

        {/* enable for middle of the screen crosshair */}
        {/* <div style={{ width: '5px', height: '5px', borderRadius: '50%', background: 'red', position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }}></div> */}

        <div className='main-page-content' >
          {
            currentMenuState === MenuState.PROFILE && (
              <div className='page-container'>
                <ProfilePage setUIState={closePage} specificSetState={setCurrentMenuState} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.RULES && (
              <div className='page-container'>
                <RulesPage setUIState={closePage} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.SETTINGS && (
              <div className='page-container'>
                <SettingsPage setUIState={closePage} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.TRADES && (
              <div className='page-container'>
                <TradesPage setMenuState={setCurrentMenuState} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.STATS && (
              <div className='page-container'>
                <StatsPage setMenuState={setCurrentMenuState} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.REV_JURNAL && (
              <div className='page-container'>
                <RevenantJurnalPage setMenuState={setCurrentMenuState} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.WINNER && (
              <div className='page-container'>
                <WinnerPage setMenuState={setCurrentMenuState} />
              </div>
            )
          }
          {
            currentMenuState === MenuState.EVENT && (

              <EventConfirmPage setUIState={closePage} />

            )
          }
          {
            currentMenuState === MenuState.Debug && (
              <div className='page-container'>
                <DebugPage />
              </div>
            )
          }


        </div>
      </ClickWrapper>

      {/* pretty sure this is the wrong class as it doesnt make sense */}
      <div className='main-page-topbar'>
        <NavbarComponent menuState={currentMenuState} setMenuState={setCurrentMenuState} />
      </div>

      {currentMenuState === MenuState.NONE && <>
        <MouseInputManagerDiv onDragEnd={handleDragEnd} onDragStart={handleDragStart} onNormalClick={checkIfClickInEvent} />
        <JurnalEventComponent setMenuState={setCurrentMenuState} />
        <OutpostTooltipComponent />
        <MinimapComponent />
      </>}

      {showEventButton && <ClickWrapper className='fire-button pointer' onClick={() => createEvent()}>Summon Event</ClickWrapper>}
    </>
  );
}

