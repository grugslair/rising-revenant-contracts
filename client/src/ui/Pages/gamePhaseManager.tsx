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
import { useOutpostAmountData } from '../Hooks/outpostsAmountData';

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

export const GamePhaseManager = () => {
  const [currentMenuState, setCurrentMenuState] = useState(MenuState.NONE);
  const [showEventButton, setShowEventButton] = useState(false);

  const [showBackground, setShowBackground] = useState(false);

  const {
    phaserLayer: {
      scenes: {
          Main: { camera },
      }
  },
    account: { account },
    networkLayer: {
      network: { contractComponents, clientComponents, graphSdk },
      systemCalls: { create_event }
    }
  } = useDojo();

  const closePage = () => {
    setCurrentMenuState(MenuState.NONE);
  }

  const clientGameData: any = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
  const gameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id)]));

  useCameraInteraction(currentMenuState, clientComponents, contractComponents, camera);
  const outpostData = useOutpostAmountData(clientComponents, contractComponents);

  useEffect(() => {
    if (outpostData.outpostsLeftNumber <= 1 && clientGameData.current_event_drawn !== 0) {
      setCurrentMenuState(MenuState.WINNER);
    }
  }, [outpostData.outpostDeadQuery]);

  // this only needs to be like this for the debug, once the game ships take out the dependency we still need this because of the escape
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

  const handleDragStart = () => {
    console.log('Dragging started!');
  };
  const handleDragEnd = () => {
    console.log('Dragging ended!');
  };
  const checkIfClickInEvent = (overEvent: boolean) => {
    if (overEvent) {
      setCurrentMenuState(MenuState.EVENT);
    }
  };


  
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



  return (
    <>
      <DirectionalEventIndicator clientComponents={clientComponents} contractComponents={contractComponents} camera={camera}/>
      <ClickWrapper className="main-page-container-layout">

        {currentMenuState === MenuState.EVENT && showBackground &&
          <img src='Page_Bg/VALIDATE_EVENT_BG.png' className='brightness-down' style={{ position: 'absolute', top: "0", left: "0", aspectRatio: "1.7/1", width: "100%", height: "100%" }}></img>}

        <div className='main-page-topbar' style={{ position: "relative" }}>
           <TopBarComponent phaseNum={2} clientComponents={clientComponents} contractComponents={contractComponents} graphSdk={graphSdk} account={account}/>
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
                <SettingsPage setUIState={closePage} clientComponents={clientComponents} contractComponents={contractComponents}/>
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
                <RevenantJurnalPage setMenuState={setCurrentMenuState} contractComponents={contractComponents} clientComponents={clientComponents}/>
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
              <EventConfirmPage setUIState={closePage} setBackground={setShowBackground} />
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
        <NavbarComponent menuState={currentMenuState} setMenuState={setCurrentMenuState} clientComponents={clientComponents}/>
      </div>

      {currentMenuState === MenuState.NONE && <>
        <MouseInputManagerDiv onDragEnd={handleDragEnd} onDragStart={handleDragStart} onNormalClick={checkIfClickInEvent} clientComponents={clientComponents} contractComponents={contractComponents} camera={camera}/>
        <JurnalEventComponent setMenuState={setCurrentMenuState} contractComponents={contractComponents} clientComponents={clientComponents}/>
        <OutpostTooltipComponent />
        <MinimapComponent camera={camera} clientComponents={clientComponents} contractComponents={contractComponents}/>

        {outpostData.outpostsLeftNumber === 1 &&
          <ClickWrapper style={{ position: 'absolute', width: "40%", height: "20%", transform: "translate(-50%, 0%)", bottom: "4%", left: "50%", zIndex: 20, color: "white" }}>
            <div style={{ width: "100%", height: "75%", display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "column" }}>
              <h1 className='no-margin test-h1' style={{ fontFamily: "Zelda" }}>GAME HAS ENDED</h1>
              <h1 className='no-margin test-h1' style={{ fontFamily: "Zelda" }}>ARE YOU THE RISING REVENANT</h1>
            </div>
            <div style={{ width: "100%", height: "25%", display: 'flex', justifyContent: "center", alignItems: "flex-start" }}>
              <div className='global-button-style'>
                <h2 className='test-h2 no-margin' style={{ padding: "2px 10px" }} onClick={() => setCurrentMenuState(MenuState.WINNER)}>Check it out now</h2>
              </div>
            </div>
          </ClickWrapper>
        }
      </>}

      {showEventButton && currentMenuState === MenuState.NONE && <ClickWrapper className='fire-button pointer' onClick={() => createEvent()}>Summon Event</ClickWrapper>}
    </>
  );
}

