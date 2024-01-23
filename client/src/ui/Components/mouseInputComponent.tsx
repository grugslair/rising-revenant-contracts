import React, { useEffect, useRef, useState } from 'react';
import { ClickWrapper } from '../clickWrapper';
import { useDojo } from '../../hooks/useDojo';

import { getComponentValue, getComponentValueStrict, updateComponent } from "@latticexyz/recs";
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { GAME_CONFIG_ID } from '../../utils/settingsConstants';

interface DragAndClickProps {
    onDragStart: () => void;
    onDragEnd: () => void;
    onNormalClick: (overEvent : boolean) => void;
    contractComponents: any;
    clientComponents:any;
    camera: any;
}

const MouseInputManagerDiv: React.FC<DragAndClickProps> = ({
    onDragStart,
    onDragEnd,
    onNormalClick,
    contractComponents,
    clientComponents,
    camera
}) => {
    const dragRef = useRef<HTMLDivElement>(null);
    const [isDragging, setDragging] = useState(false);
    const [overEvent, setOverEvent] = useState(false);
    const [startX, setStartX] = useState(0);
    const [startY, setStartY] = useState(0);

    const [lastDragX, setLastDragX] = useState(0);
    const [lastDragY, setLastDragY] = useState(0);

  

    useEffect(() => {
        const handleClick = (event: MouseEvent) => {
            const clickedElement = event.target as HTMLElement;

            if (
                clickedElement.classList.contains('target-for-mouse')
            ) {

                let zoomVal: number = 0;
                camera.zoom$.subscribe((zoom) => { zoomVal = zoom; });

                const pointXRelativeToMiddle = event.clientX - (window.innerWidth / 2);
                const pointYRelativeToMiddle = event.clientY - (window.innerHeight / 2);

                const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

                if (event.button === 1) {
                    updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
                        x: (camPos.x + pointXRelativeToMiddle / zoomVal),
                        y: (camPos.y + pointYRelativeToMiddle / zoomVal)
                    })
                }
                else if (event.button === 2) {
                    updateComponent(clientComponents.ClientClickPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
                        xFromOrigin: event.clientX,
                        yFromOrigin: event.clientY,
                        xFromMiddle: ((pointXRelativeToMiddle) / zoomVal),
                        yFromMiddle: ((pointYRelativeToMiddle) / zoomVal)
                    })
                }
            }
        };

        document.addEventListener('mousedown', handleClick);

        return () => {
            document.removeEventListener('mousedown', handleClick);
        };
    }, [camera.zoom$]);

    const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
        if (e.button !== 0) { return; }

        setStartX(e.clientX);
        setStartY(e.clientY);
        setDragging(true);

        setLastDragX(0);
        setLastDragY(0);
        onDragStart();
    };

    const handleMouseUp = (e: React.MouseEvent<HTMLDivElement>) => {
        setDragging(false);
        if (lastDragX === 0 && lastDragY === 0 && e.button === 0) {
            onNormalClick(overEvent);
        } else {
            onDragEnd();
        }
    };

    const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
        if (isDragging) {
            const deltaX = (e.clientX - startX);
            const deltaY = (e.clientY - startY);

            setLastDragX(deltaX);
            setLastDragY(deltaY);

            const currentCamPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
            updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { x: currentCamPos.x - deltaX, y: currentCamPos.y - deltaY })

            setStartX(e.clientX);
            setStartY(e.clientY);
        }
        else {
            const currentGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

            const currentLoadedEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(currentGameData.current_game_id), BigInt(currentGameData.current_event_drawn)]));
            const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

            if (currentLoadedEvent === undefined) { return; }

            const centerX = window.innerWidth / 2;
            const centerY = window.innerHeight / 2;

            const relativeClickX = e.clientX - centerX + camPos.x;
            const relativeClickY = e.clientY - centerY + camPos.y;

            const distance = Math.sqrt((relativeClickX - currentLoadedEvent.x) ** 2 + (relativeClickY - currentLoadedEvent.y) ** 2);

            if (distance <= currentLoadedEvent.radius) {
                setOverEvent(true);
            }
            else{
                setOverEvent(false)
            }
        }
    };

    const handleMouseLeave = () => {
        if (isDragging) {
            setDragging(false);
            onDragEnd();
        }
    };

    const handleScroll = (event: React.WheelEvent) => {
        let currentZoomValue = 0;
        camera.zoom$.subscribe((currentZoom: any) => {
            currentZoomValue = currentZoom;
        });

        const newZoomVal = Math.round((currentZoomValue - event.deltaY / 1000) * 1000) / 1000;

        if (newZoomVal < 0.5) {
            camera.setZoom(0.5);
        }
        else if (newZoomVal > 2.5) {
            camera.setZoom(2.5);
        }
        else {
            camera.setZoom(newZoomVal);
        }
    };

    return (
        <ClickWrapper >
            <div
                ref={dragRef}
                onMouseDown={handleMouseDown}
                onMouseUp={handleMouseUp}
                onMouseMove={handleMouseMove}
                onMouseLeave={handleMouseLeave}
                onWheel={handleScroll}
                style={{
                    cursor: `${ overEvent && !isDragging ? "pointer" : isDragging && (lastDragX !== 0 || lastDragY !== 0) ? "grabbing" : "default"}`,
                    width: "100%", height: "90%", position: "absolute", left: "0", top: "10%"
                }}
                className='target-for-mouse'
            >
            </div>
        </ClickWrapper>
    );
};

export default MouseInputManagerDiv;


// // this could probably be merge with the thing above
// const useMainPageContentClick = () => {
//     const {
//         networkLayer: {
//             network: { clientComponents },
//         },
//         phaserLayer: {
//             scenes: {
//                 Main: { camera },
//             },
//         }
//     } = useDojo();

//     // here we need to see what sort of click gets registered
//     useEffect(() => {
//         const handleClick = (event: MouseEvent) => {
//             const clickedElement = event.target as HTMLElement;

//             if (
//                 clickedElement.classList.contains('target-for-mouse')
//             ) {

//                 let zoomVal: number = 0;
//                 camera.zoom$.subscribe((zoom) => { zoomVal = zoom; });

//                 const pointXRelativeToMiddle = event.clientX - (window.innerWidth / 2);
//                 const pointYRelativeToMiddle = event.clientY - (window.innerHeight / 2);

//                 const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

//                 if (event.button === 1) {
//                     updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
//                         x: (camPos.x + pointXRelativeToMiddle / zoomVal),
//                         y: (camPos.y + pointYRelativeToMiddle / zoomVal)
//                     })
//                 }
//                 else if (event.button === 2) {
//                     updateComponent(clientComponents.ClientClickPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
//                         xFromOrigin: event.clientX,
//                         yFromOrigin: event.clientY,
//                         xFromMiddle: ((pointXRelativeToMiddle ) / zoomVal),
//                         yFromMiddle: ((pointYRelativeToMiddle ) / zoomVal)
//                     })
//                 }
//             }
//         };

//         document.addEventListener('mousedown', handleClick);

//         return () => {
//             document.removeEventListener('mousedown', handleClick);
//         };
//     }, [camera.zoom$]);
// };