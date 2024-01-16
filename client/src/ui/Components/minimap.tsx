import React, { useEffect, useState } from 'react';
import { ClickWrapper } from '../clickWrapper';
import { useDojo } from '../../hooks/useDojo';

import { getComponentValueStrict, updateComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG_ID, MAP_HEIGHT, MAP_WIDTH } from '../../utils/settingsConstants';
import { WorldEvent } from '../../generated/graphql';
import { clampPercentage } from '../../utils';


const MinimapComponent: React.FC = () => {

    const [eventPos, setEventPos] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
    const [cameraTransform, setCameraTransform] = useState<{ x: number; y: number, w: number, h: number }>({ x: 0, y: 0, w: 0, h: 0 });

    const {
        networkLayer: {
            network: { contractComponents, clientComponents },
        },
        phaserLayer: {
            scenes: {
                Main: { camera },
            }
        }
    } = useDojo();

    const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const clientCameraComp = useComponentValue(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const positionOfEvent: React.CSSProperties = {
        left: `${eventPos.x}%`,
        top: `${eventPos.y}%`,
        transform: "translate(-50%, -50%)",
    };

    const transformOfCamera: React.CSSProperties = {
        left: `${cameraTransform.x}%`,
        top: `${cameraTransform.y}%`,
        width: `${cameraTransform.w}%`,
        height: `${cameraTransform.h}%`,
        transform: "translate(-50%, -50%)",
    };

    useEffect(() => {

        if (clientGameData!.current_event_drawn === 0) { return; }
        const eventData: WorldEvent = getComponentValueStrict(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id), BigInt(clientGameData!.current_event_drawn)]));
        setEventPos({
            x: clampPercentage((eventData.x / MAP_WIDTH) * 100, 0, 100),
            y: clampPercentage((eventData.y / MAP_HEIGHT) * 100, 0, 100)
        });

    }, [clientGameData]);

    useEffect(() => {
        let currentZoomValue = 0;

        const zoomSubscription = camera.zoom$.subscribe((currentZoom: any) => {
            currentZoomValue = currentZoom;

            setCameraTransform({
                x: clampPercentage((clientCameraComp!.x / MAP_WIDTH) * 100, 0, 100),
                y: clampPercentage((clientCameraComp!.y / MAP_HEIGHT) * 100, 0, 100),
                w: clampPercentage(((camera.phaserCamera.width / MAP_WIDTH) * 100) / currentZoomValue, 0, 100),
                h: clampPercentage(((camera.phaserCamera.height / MAP_HEIGHT) * 100) / currentZoomValue, 0, 100)
            });
        });

        return () => {
            zoomSubscription.unsubscribe();
        };
    }, [clientCameraComp, camera.zoom$]);

    const handleClick = (event: React.MouseEvent<HTMLDivElement>) => {
        const rect = event.currentTarget.getBoundingClientRect();
        const xPercentage = ((event.clientX - rect.left) / rect.width);
        const yPercentage = ((event.clientY - rect.top) / rect.height);

        updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { x: xPercentage * MAP_WIDTH, y: yPercentage * MAP_HEIGHT })
    };

    return (
        <div style={{
            position: 'absolute',
            width: '15%',
            aspectRatio: '2/1',
            left: '1%',
            bottom: '7%',
            boxSizing: 'border-box',
            border: '3px solid var(--borderColour)',
            borderRadius: '5px',
            overflow: 'hidden',
            backgroundImage: 'url("Misc/minimap.png")',
            backgroundSize: 'cover',
            backgroundPosition: 'center',
        }}>
            <ClickWrapper style={{ width: "100%", height: "100%", position: "relative" }} onClick={handleClick}>

                {clientGameData!.current_event_drawn !== 0 &&
                    <div style={{ ...positionOfEvent, width: "2%", borderRadius: "50%", aspectRatio: "1/1", position: "absolute", backgroundColor: "red" }}>
                    </div>}

                <div style={{ ...transformOfCamera, borderRadius: "2px", position: "absolute", border: "1px solid var(--borderColour)" }}>
                </div>
            </ClickWrapper>
        </div>
    );
};

export default MinimapComponent;
