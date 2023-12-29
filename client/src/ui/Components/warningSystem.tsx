import React, { useEffect, useState } from 'react';

import { useComponentValue } from "@latticexyz/react";
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG_ID } from '../../utils/settingsConstants';
import { useDojo } from '../../hooks/useDojo';
import {getComponentValueStrict} from "@latticexyz/recs";


export const DirectionalEventIndicator: React.FC = () => {
    const [direction, setDirection] = useState<string>(''); // Holds the direction based on eventData and camPos

    const {
        networkLayer: {
            network: { contractComponents, clientComponents },
        },
    } = useDojo();

    const camPos = useComponentValue(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {
        // Calculate the direction based on eventData and camPos
        const calculateDirection = () => {
            // Assume eventData is available and has x, y properties
            const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

            if (clientGameData.current_event_drawn === 0) { return; }

            const currentEvent = getComponentValueStrict(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));

            // Calculate the x and y differences
            const deltaX = currentEvent.x - camPos.x;
            const deltaY = currentEvent.y - camPos.y;

            // Determine the direction based on the differences
            if (deltaX === 0 && deltaY === 0) {
                setDirection('center');
            } else if (deltaX === 0) {
                setDirection(deltaY > 0 ? 'south' : 'north');
            } else if (deltaY === 0) {
                setDirection(deltaX > 0 ? 'east' : 'west');
            } else {
                setDirection(deltaY > 0 ? (deltaX > 0 ? 'southeast' : 'southwest') : deltaX > 0 ? 'northeast' : 'northwest');
            }
        };
        calculateDirection();
    }, [camPos]);

    useEffect(() => {
        console.error(direction);
    }, [direction]);
    
    return (<></>);
    // Map the direction to the corresponding image URL
    // const imageUrl = `/images/${direction}.png`; // Replace with your actual image paths

    // return (
    //     <div style={{ width: '100vw', height: '100vh', backgroundImage: `url(${imageUrl})`, backgroundSize: 'cover' }}>
    //         {/* Additional styling and content can be added as needed */}
    //     </div>
    // );
};

