//libs
import  { useState, useEffect } from 'react';
import {
  Has,
  getComponentValue,
  HasValue
} from "@latticexyz/recs";
import { store } from '../../store/store';
import { useEntityQuery } from "@latticexyz/react";
import { useDojo } from '../../hooks/useDojo';

import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG, MAP_HEIGHT, MAP_WIDTH, getTileIndex } from '../../phaser/constants';

// styles
import "./PagesStyles/MainMenuContainerStyles.css"

//elements/components
import { TopBarComponent } from '../Components/topBarComponent';
import { NavbarComponent } from '../Components/nabarComponent';
import { OutpostTooltipComponent } from '../Components/toolTipComponent';
import { JurnalEventComponent } from '../Components/jurnalEventComponent';


//pages
import { ProfilePage } from './playerProfilePage';
import { RulesPage } from './rulePage';
import { SettingsPage } from './settingsPage';
import { TradesPage } from './tradePage';
import { RevenantJurnalPage } from './revenantJurnalPage';
import { StatsPage } from './statsPage';
import { WinnerPage } from './winnerPage';

import { DebugPage } from './debugPage';

/*notes
component that manages the game phase, this should deal with the update of the UI state and then update of the camera movement and any other related inputs
to phaser

should also dictate the winning state
do two simple queries one for the totla outpost and one for the totla outposts wiht 0 health and then if the total outposts - the total outposts with 0 health is less than 2
then we have a winner
*/

import { useWASDKeys } from '../../phaser/systems/eventSystems/keyPressListener';
import { setClientCameraComponent, setClientCameraEntityIndex } from '../../utils';

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
    networkLayer: {
      network: {  contractComponents, clientComponents },
    },
    phaserLayer:{
      scenes: {
        Main: { camera },
      }
    }
  } = useDojo();

  const CAMERA_SPEED = 10;   ///needs to be global in the settings

  let prevX: number = 0;
  let prevY: number = 0;

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
      const camPos = getComponentValue(
        clientComponents.ClientCameraPosition,
        getEntityIdFromKeys([BigInt(GAME_CONFIG)])
      );

      if (!camPos) {
        console.log("failed");
        return;
      }

      let newX = camPos.x;
      let newY = camPos.y;

      if (keysDown.W) {
        newY = camPos.y - CAMERA_SPEED;
      }
      if (keysDown.A) {
        newX = camPos.x- CAMERA_SPEED;
      }

      if (keysDown.S) {
        newY = camPos.y + CAMERA_SPEED;
      }
      if (keysDown.D) {
        newX = camPos.x + CAMERA_SPEED;
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
        
        setClientCameraComponent(newX, newY, clientComponents);

        prevX = newX;
        prevY = newY;

        const camTileIndex = getComponentValue(
          clientComponents.EntityTileIndex,
          getEntityIdFromKeys([BigInt(GAME_CONFIG)])
        );

        const newIndex = getTileIndex(newX,newY);

        if (newIndex !== camTileIndex.tile_index)
        {
          setClientCameraEntityIndex(newX, newY, clientComponents)
        }
      }

      animationFrameId = requestAnimationFrame(update);
    };

    update();

    return () => {
      cancelAnimationFrame(animationFrameId);
      zoomSubscription.unsubscribe();
    };
  }, [keysDown]);

  const closePage = () => {
    setCurrentMenuState(MenuState.NONE);
  }

  return (
    <>
      <div className="main-page-container-layout">
        <div className='main-page-topbar'>
          <TopBarComponent phaseNum={2}/>
        </div>

        <div className='main-page-content'>
          {currentMenuState !== MenuState.NONE && (
            <div className='page-container'>
              {currentMenuState === MenuState.PROFILE && <ProfilePage setUIState={closePage}/>}
              {currentMenuState === MenuState.RULES && <RulesPage setUIState={closePage} />}
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
        <NavbarComponent menuState={currentMenuState} setMenuState={setCurrentMenuState} />
      </div>

      {currentMenuState === MenuState.NONE && <JurnalEventComponent setMenuState={setCurrentMenuState} />}
      {currentMenuState === MenuState.NONE && <OutpostTooltipComponent />}
    </>
  );
}
