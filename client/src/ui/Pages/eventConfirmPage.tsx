//libs
import React, { useEffect, useState } from "react";
import { MenuState } from "./gamePhaseManager";

//styles
import "./PagesStyles/RulesPageStyles.css"
import PageTitleElement, { ImagesPosition } from "../Elements/pageTitleElement";
import { ClickWrapper } from "../clickWrapper";
import { EntityIndex, HasValue, getComponentValueStrict, updateComponent } from "@latticexyz/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID, test_3_size, test_4_size, test_5_size } from "../../utils/settingsConstants";
import { useDojo } from "../../hooks/useDojo";
import { useResizeableHeight } from "../Hooks/gridResize";
import { mapEntityToImage, namesArray, revenantsPicturesLinks, surnamesArray } from "../../utils";
import { ConfirmEventOutpost } from "../../dojo/types";
import { useOutpostAmountData } from "../Hooks/outpostsAmountData";

//elements/components

//pages



interface EventConfirmPageProps {
    setBackground: (boolean) => void;
    setUIState: () => void;
}

function lerp(start: number, end: number, t: number): number {
    return start * (1 - t) + end * t;
}

export const EventConfirmPage: React.FC<EventConfirmPageProps> = ({ setUIState,setBackground }) => {
    const [transitionState, setTransitionState] = useState(0); // 0 going to event // 1 zooming on event // 2 show map
    const [entityIdsOfOutposts, setEntityIdsOfOutposts] = useState<EntityIndex[]>([]);

    const {
        phaserLayer: {
            scenes: {
                Main: {
                    camera
                }
            }
        },
        networkLayer: {
            network: { contractComponents, clientComponents },
        }
    } = useDojo();

    // const outpostsHit = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { event_effected: true })]);
    // const deadOutposts = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
    const outpostAmountData = useOutpostAmountData();

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

        if (transitionState === 0) {
            handleMovementTransition();
        }
        else if (transitionState === 1) {
            handleZoomTransition();
        }
        else if (transitionState === 2) {
            setBackground(true);
        }
    }, [transitionState]);


    useEffect(() => {
    
        return () => {
            camera.setZoom(1);
            setBackground(false)
        };
    }, []); 

    // useEffect(() => {
    //     const aliveOutposts = outpostAmountData.outpostsHitQuery.filter(outpost => !outpostAmountData.outpostDeadQuery.includes(outpost));
    //     setEntityIdsOfOutposts(aliveOutposts);
    // }, [outpostAmountData.outpostsHitQuery, outpostAmountData.outpostDeadQuery]);

    if (transitionState !== 2) {
        return <></>;
    }

    return (
        <>
            <div style={{ width: "60%", height: "75%"  }} >

                <div style={{ height: "15%", width: "100%", display: "grid", gridTemplateRows: "repeat(2, 1fr)", gridTemplateColumns: "0.5fr 1fr 0.5fr" }}>

                    <div style={{ gridRow: "1", gridColumn: "1", display: "flex", justifyContent: "flex-start", alignItems: "start" }}>
                        <h3 className="global-button-style no-margin test-h3" onClick={setUIState} style={{ padding: "5px", boxSizing: "border-box" }}>
                            <img className="embedded-text-icon" src="Icons/left-arrow.png" alt="Sort Data" style={{ height: `${test_4_size}`, width: `${test_4_size}` }} />
                            Back to the map</h3>
                    </div>

                    <div style={{ gridRow: "1", gridColumn: "2", display: "flex", justifyContent: "center", alignItems: "start" }}> <h1 className="no-margin test-h1-75" style={{whiteSpace:"nowrap", fontFamily: "Zelda", fontWeight: "100", color: "white" }}>OUTPOSTS UNDER ATTACK</h1></div>
                    <div style={{ gridRow: "2", gridColumn: "1/4", display: "flex", justifyContent: "center", alignItems: "end" }}>
                        <h2 className="no-margin test-h2" style={{ color: "white" }}>Validate attacks in order to get rewards</h2>
                    </div>
                </div>
                <div style={{ height: "7%", width: "100%", }}></div>
                <div style={{ height: "65%", width: "100%", display: "grid", gap: "5%", scrollbarGutter: "stable", overflowY: "auto", gridTemplateColumns: "repeat(2, 1fr)", padding: "5px 10px", boxSizing: "border-box" }}>
                    {outpostAmountData.outpostsHitQuery.map((outpostId: EntityIndex) => (
                        <OutpostEventAttackedElement entityId={outpostId} key={outpostId} />
                    ))}
                </div>
                <div style={{ height: "13%", width: "100%", display:"flex", justifyContent: "center", alignItems: "flex-end"}}>
                    <div className="global-button-style" style={{padding:"5px 10px", backgroundColor:"#9d0e0e"}}>
                        <h2 className="test-h2 no-margin">Validate All</h2>
                    </div>
                </div>

            </div>
        </>
    );
};




interface ItemListingProp {
    entityId: EntityIndex
}

export const OutpostEventAttackedElement: React.FC<ItemListingProp> = ({ entityId }) => {

    const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(14, 4, "100%");

    const {
        account: { account },
        networkLayer: {
            systemCalls: { confirm_event_outpost },
            network: { contractComponents, clientComponents },
        },
    } = useDojo();


    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const outpostData: any = getComponentValueStrict(contractComponents.Outpost, entityId);
    const revenantData: any = getComponentValueStrict(contractComponents.Revenant, entityId);

    console.log(mapEntityToImage(Number(outpostData.entity_id), namesArray[revenantData.first_name_idx], revenantsPicturesLinks.length), outpostData.entity_id)

    const confirmEvent = async () => {

        const gameTrackerData = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

        const confirmEventProps: ConfirmEventOutpost = {
            account: account,
            game_id: clientGameData.current_game_id,
            event_id: gameTrackerData.event_count,
            outpost_id: Number(outpostData.entity_id),
        };

        await confirm_event_outpost(confirmEventProps);
    }

    return (
        <div ref={clickWrapperRef} style={{
            ...clickWrapperStyle, width: "100%", display: "grid", gridTemplateColumns: "repeat(14, 1fr)", gridTemplateRows: "repeat(4, 1fr)", color: "white"
        }}>
            <div style={{ gridRow: "1/4", gridColumn: "1/4" }}>
                <img src={revenantsPicturesLinks[mapEntityToImage(Number(outpostData.entity_id), namesArray[revenantData.first_name_idx], revenantsPicturesLinks.length)]} style={{ width: "100%", height: "100%", border: "1px solid var(--borderColour)", boxSizing: "border-box" }}></img>
            </div>
            <div style={{ gridRow: "4", gridColumn: "1/4", display: "flex", justifyContent: "start", alignItems: "center" }}>
                <h3 className="test-h3 no-margin">{namesArray[revenantData.first_name_idx]} {surnamesArray[revenantData.last_name_idx]}</h3>
            </div>
            <div style={{ gridRow: "1", gridColumn: "5/11", display: "flex", justifyContent: "start", alignItems: "flex-end" }}>
                <h3 className="test-h3 no-margin"> Outpost ID: {Number(outpostData.entity_id)}</h3>
            </div>
            <div style={{ gridRow: "2", gridColumn: "5/11", display: "flex", justifyContent: "start", alignItems: "center" }}>
                <h3 className="test-h3 no-margin">Coordinates: X: {outpostData.x}, Y: {outpostData.y}</h3>
            </div>
            <div style={{ gridRow: "3", gridColumn: "5/12", display: "flex", justifyContent: "start", alignItems: "flex-start" }}>
                <h3 className="test-h3 no-margin"> Reinforcements: {outpostData.lifes}</h3>
            </div>
            <div style={{ gridRow: "1/4", gridColumn: "12/15" }} className="center-via-flex">
                <div onClick={confirmEvent}  style={{backgroundColor:"#202020", padding: "5px 10px", boxSizing:"border-box"}} className="global-button-style center-via-flex">
                    <h2 className="no-margin test-h3">Validate</h2>
                </div>
            </div>
        </div>
    )
}
