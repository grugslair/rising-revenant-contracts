import React, { useEffect, useState } from 'react';
import { useComponentValue } from "@latticexyz/react";
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG_ID } from '../../utils/settingsConstants';
import { useDojo } from '../../hooks/useDojo';
import { getComponentValueStrict } from "@latticexyz/recs";


// this is to check  HERE

export const DirectionalEventIndicator: React.FC = () => {

  useEffect(() => {
    // Function to preload images
    const preloadImages = async () => {
      const imageUrls = [
        '/Warning_system/W.png',
        '/Warning_system/S.png',
        '/Warning_system/E.png',
        '/Warning_system/N.png',
        '/Warning_system/NW.png',
        '/Warning_system/NW.png',
        '/Warning_system/SW.png',
        '/Warning_system/SE.png',
      ];

      const imagePromises = imageUrls.map((url) => {
        return new Promise((resolve, reject) => {
          const img = new Image();
          img.src = url;
          img.onload = resolve;
          img.onerror = reject;
        });
      });

      await Promise.all(imagePromises);
    };

    // Call the function to preload images
    preloadImages();
  }, []); // Empty dependency array ensures that the effect runs only once


  const direction = useDirectionalEventIndicator();

  if (direction === "") {
    return <></>;
  }

  const imageUrl = `/Warning_system/${direction}.png`;

  return (
    <div style={{ backgroundImage: `url(${imageUrl})` }} className='directional-event-indicator'>
    </div>
  );
};

const useDirectionalEventIndicator = () => {
  const [direction, setDirection] = useState<string>('');

  const { networkLayer: { network: { contractComponents, clientComponents } }, phaserLayer: { scenes: { Main: { camera } } } } = useDojo();

  const camTile: any = useComponentValue(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

  useEffect(() => {
    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const camPos: any = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    if (clientGameData.current_event_drawn === 0) {
      return;
    }

    let zoomVal: number = 0;
    camera.zoom$.subscribe((zoom) => { zoomVal = zoom; });

    const currentEvent = getComponentValueStrict(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));

    const circleCenterX = currentEvent.x - camPos.x + (camera.phaserCamera.width / zoomVal) / 2;
    const circleCenterY = currentEvent.y - camPos.y + (camera.phaserCamera.height / zoomVal) / 2;

    const isCircleVisible = (
      circleCenterX + currentEvent.radius > 0 &&
      circleCenterX - currentEvent.radius < (camera.phaserCamera.width / zoomVal) &&
      circleCenterY + currentEvent.radius > 0 &&
      circleCenterY - currentEvent.radius < (camera.phaserCamera.height / zoomVal)
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

  }, [camTile, camera.zoom$]);

  return direction;
};
