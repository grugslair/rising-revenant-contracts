import React, { useEffect, useState } from 'react';
import { useComponentValue } from "@latticexyz/react";
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG_ID } from '../../utils/settingsConstants';
import { useDojo } from '../../hooks/useDojo';
import { getComponentValueStrict } from "@latticexyz/recs";


// this is to check  HERE

export const DirectionalEventIndicator: React.FC = () => {

  const direction = useDirectionalEventIndicator();

  if (direction === "") {
    return <></>;
  }

  const imageUrl = `/warning_system/${direction}.png`;

  return (
    <div style={{ width: '100vw', height: '100vh', backgroundImage: `url(${imageUrl})`, backgroundSize: 'cover', position: 'absolute', zIndex: "-1" }}>
    </div>
  );
};

const useDirectionalEventIndicator = () => {
  const [direction, setDirection] = useState<string>('');

  const { networkLayer: { network: { contractComponents, clientComponents } }, phaserLayer: { scenes: { Main: { camera } } } } = useDojo();

  const camPos = useComponentValue(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

  useEffect(() => {
        const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    
        if (clientGameData.current_event_drawn === 0) {
          return;
        }
    
        const currentEvent = getComponentValueStrict(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));
    
        const circleCenterX = currentEvent.x - camPos.x + camera.phaserCamera.width / 2;
        const circleCenterY = currentEvent.y - camPos.y + camera.phaserCamera.height / 2;
    
        const isCircleVisible = (
          circleCenterX + currentEvent.radius > 0 &&
          circleCenterX - currentEvent.radius < camera.phaserCamera.width &&
          circleCenterY + currentEvent.radius > 0 &&
          circleCenterY - currentEvent.radius < camera.phaserCamera.height
        );
    
        if (isCircleVisible) {
          // No need to update direction if the circle is visible
          setDirection("");
          return;
        }
    
        let newDirection = '';
    
        if (circleCenterY + currentEvent.radius < 0) {
          newDirection += 'N';
        } else if (circleCenterY - currentEvent.radius > camera.phaserCamera.height) {
          newDirection += 'S';
        }
    
        if (circleCenterX + currentEvent.radius < 0) {
          newDirection += 'W';
        } else if (circleCenterX - currentEvent.radius > camera.phaserCamera.width) {
          newDirection += 'E';
        }
    
        setDirection(newDirection);
      
  }, [camPos]);

  return direction;
};
