//libs
import React, { useEffect, useState } from "react";
import { MenuState } from "./gamePhaseManager";

//styles
import "./PagesStyles/RulesPageStyles.css"
import PageTitleElement, { ImagesPosition } from "../Elements/pageTitleElement";
import { ClickWrapper } from "../clickWrapper";
import { getComponentValueStrict, updateComponent } from "@latticexyz/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { useDojo } from "../../hooks/useDojo";
import { useComponentValue } from "@latticexyz/react";

//elements/components

//pages



interface EventConfirmPageProps {
    setUIState: () => void;
}

function lerp(start: number, end: number, t: number): number {
    return start * (1 - t) + end * t;
}

export const EventConfirmPage: React.FC<EventConfirmPageProps> = ({ setUIState }) => {
    const [transitionState, setTransitionState] = useState(2); // 0 going to event // 1 zooming on event // 2 show map

    const { networkLayer: { network: { contractComponents, clientComponents } }, phaserLayer: { scenes: { Main: { camera } } } } = useDojo();

    useEffect(() => {
        const handleMovementTransition = async () => {
            const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
            const currentLoadedEvent = getComponentValueStrict(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]));

            const lerpFactor = 0.03;
            const distanceThreshold = 5;
            const timeBetweenIterations = 10;

            while (true) {

                const camPos = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

                const newX = lerp(camPos.x, currentLoadedEvent.x, lerpFactor);
                const newY = lerp(camPos.y, currentLoadedEvent.y, lerpFactor);

                updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { x: newX, y: newY });

                const distance = Math.sqrt((currentLoadedEvent.x - camPos.x) ** 2 + (currentLoadedEvent.y - camPos.y) ** 2);

                if (distance < distanceThreshold) {
                    setTransitionState(1);
                    break;
                }

                await new Promise(resolve => setTimeout(resolve, timeBetweenIterations));
            }
        };

        const handleZoomTransition = async () => {

            const lerpFactor = 0.03;
            const targetZoom = 4;
            const timeBetweenIterations = 10;

            let currentZoom: number = 0;

            while (true) {

                camera.zoom$.subscribe((zoom) => {
                    currentZoom = zoom;
                });

                const newZoom = lerp(currentZoom, targetZoom, lerpFactor);

                camera.setZoom(newZoom);


                if (newZoom >= targetZoom * 0.99) {
                    setTransitionState(2);
                    break;
                }

                await new Promise((resolve) => setTimeout(resolve, timeBetweenIterations));
            }
        };

        // if (transitionState === 0) {
        //     handleMovementTransition();
        // }
        // else if (transitionState === 1) {
        //     handleZoomTransition();
        // }
        // else if (transitionState === 2) {

        // }
    }, [transitionState]);

    const onExitMenu = () => {
        camera.setZoom(1);
        setUIState()
    }

    if (transitionState !== 2) {
        return <></>;
    }

    return (
        <>
<div style={{position: "absolute", width: "100%", height: "100%", top: "0", left: "0", backgroundColor: "red", zIndex: 1}}></div>





            <div className='page-container' >

                <div className="game-page-container">

                    <img className="page-img brightness-down" src="./Page_Bg/RULES_PAGE_BG.png" alt="testPic" />

                    <PageTitleElement
                        imagePosition={ImagesPosition.RIGHT}
                        name={"EVENT VALIDATION"}
                        rightPicture={"Icons/close_icon.png"}
                        rightImageFunction={onExitMenu}
                    />

                </div>

            </div>
        </>


    );
};
