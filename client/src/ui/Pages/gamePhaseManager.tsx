
//libs
import  { useState, useEffect } from 'react';
import {
  Has,
  getComponentValue,
  HasValue
} from "@latticexyz/recs";
import { store } from '../../store/store';
import { useEntityQuery } from "@latticexyz/react";

// styles
import "./PagesStyles/MainMenuContainerStyles.css"

//components
import { TopBarComponent } from '../Components/mainTopBar';
import { NavbarComponent } from '../Components/navbar';
import { JurnalEventComponent } from '../Components/jurnalEvent';
import { OutpostTooltipComponent } from '../Components/outpostTooltip';

import { ProfilePage } from './profilePage';
import { RulesPage } from './rulesPage';
import { SettingsPage } from './settingsPage';
import { TradesPage } from './tradesPage';
import { RevenantJurnalPage } from './revenantJurnalPage';
import { StatsPage } from './statsPage';
import { WinnerPage } from './winnerPage';

import { DebugPage } from './debugPage';

import { useDojo } from '../../hooks/useDojo';

import { getEntityIdFromKeys } from '@dojoengine/utils';
import {   setComponentQuick } from '../../dojo/testCalls';
import { GAME_CONFIG, MAP_HEIGHT, MAP_WIDTH } from '../../phaser/constants';
import { useWASDKeys } from '../../phaser/systems/eventSystems/keyPressListener';

export enum MenuState {
  NONE,
  PROFILE,
  STATS,
  SETTINGS,
  TRADES,
  RULES,
  REV_JURNAL,
  WINNER,
  Debug
}

//this needs an event for the gamephase so it redraws this is called form the mapspawn script

export const GamePhaseManager = () => {
  const [currentMenuState, setCurrentMenuState] = useState(MenuState.NONE);
  const [showEventButton, setShowEventButton] = useState(false);

  const keysDown = useWASDKeys();

  const {
    account: { account },
    networkLayer: {
      network: {  contractComponents, clientComponents },
    },
  } = useDojo();

  const CAMERA_SPEED = 10;

  const layers = store((state) => {
    return {
      phaserLayer: state.phaserLayer,
    };
  });

  const {
    scenes: {
      Main: { camera },
    }
  } = layers.phaserLayer;

  let prevX: number = 0;
  let prevY: number = 0;

  const handleIconClick = (newMenuState: MenuState) => {
    setCurrentMenuState(newMenuState);
  };

  const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
  const totalOutposts = useEntityQuery([Has(contractComponents.Outpost)]);

  useEffect(() => {

    if (totalOutposts.length - outpostDeadQuery.length <= 1 )
    {
      setCurrentMenuState(MenuState.WINNER);
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

  useEffect(() => {
    let animationFrameId: number;

    let currentZoomValue = 0;

    // Subscribe to zoom$ observable
    const zoomSubscription = camera.zoom$.subscribe((currentZoom: any) => {
      currentZoomValue = currentZoom; // Update the current zoom value
    });

    const update = () => {
      const current_pos = getComponentValue(
        clientComponents.ClientCameraPosition,
        getEntityIdFromKeys([BigInt(GAME_CONFIG)])
      );

      if (!current_pos) {
        console.log("failed");
        return;
      }

      let newX = current_pos.x;
      let newY = current_pos.y;

      if (keysDown.W) {
        newY = current_pos.y - CAMERA_SPEED;
      }
      if (keysDown.A) {
        newX = current_pos.x - CAMERA_SPEED;
      }

      if (keysDown.S) {
        newY = current_pos.y + CAMERA_SPEED;
      }
      if (keysDown.D) {
        newX = current_pos.x + CAMERA_SPEED;
      }

      if (newX > MAP_WIDTH - camera.phaserCamera.width / currentZoomValue / 2) {
        newX = MAP_WIDTH - camera.phaserCamera.width / currentZoomValue / 2;
      }
      if (newX < camera.phaserCamera.width / currentZoomValue / 2) {
        newX = camera.phaserCamera.width / currentZoomValue / 2;
      }
      if (
        newY >
        MAP_HEIGHT - camera.phaserCamera.height / currentZoomValue / 2
      ) {
        newY = MAP_HEIGHT - camera.phaserCamera.height / currentZoomValue / 2;
      }
      if (newY < camera.phaserCamera.height / currentZoomValue / 2) {
        newY = camera.phaserCamera.height / currentZoomValue / 2;
      }

      if (newX !== prevX || newY !== prevY) {


        setComponentQuick({ "x": newX, "y": newY, "tile_index": current_pos.tile_index }, [getEntityIdFromKeys([BigInt(GAME_CONFIG)])], "ClientCameraPosition", clientComponents);

        prevX = newX;
        prevY = newY;
      }

      animationFrameId = requestAnimationFrame(update);
    };

    update();

    return () => {
      cancelAnimationFrame(animationFrameId);
      zoomSubscription.unsubscribe();
    };
  }, [keysDown]);

  return (
    <>
      <div className="main-page-container-layout">
        <div className='main-page-topbar'>
          <TopBarComponent />
        </div>

        <div className='main-page-content'>
          {currentMenuState !== MenuState.NONE && (
            <div className='page-container'>
              {currentMenuState === MenuState.PROFILE && <ProfilePage setMenuState={setCurrentMenuState} account_add={account.address}/>}
              {currentMenuState === MenuState.RULES && <RulesPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.SETTINGS && <SettingsPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.TRADES && <TradesPage />}
              {currentMenuState === MenuState.STATS && <StatsPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.REV_JURNAL && <RevenantJurnalPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.WINNER && <WinnerPage setMenuState={setCurrentMenuState} />}
              {currentMenuState === MenuState.Debug && <DebugPage />}
            </div>
          )}

        {showEventButton && <div className='confirm-event-button'>Event</div>}
        </div>
      </div>
      

      {/* pretty sure this is the wrong class as it doesnt make sense */}
      <div className='main-page-topbar'>
        <NavbarComponent menuState={currentMenuState} setMenuState={setCurrentMenuState} onIconClick={handleIconClick} />
      </div>

      {currentMenuState === MenuState.NONE && <JurnalEventComponent setMenuState={setCurrentMenuState} />}
      {currentMenuState === MenuState.NONE && <OutpostTooltipComponent />}
    </>
  );
}
