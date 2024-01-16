import React, { useEffect, useState } from "react";
import {
    EntityIndex,
    Has,
    HasValue,
    getComponentValueStrict,
    getComponentValue,
    updateComponent
} from "@latticexyz/recs";
import { useEntityQuery, useComponentValue } from "@latticexyz/react";

import "./ComponentsStyles/JurnalEventStyles.css";

import { MenuState } from "../Pages/gamePhaseManager";

import { ClickWrapper } from "../clickWrapper";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { getTileIndex } from "../../phaser/constants";
import { hexToNumber } from "../../utils";


interface JuornalEventProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}


export const JurnalEventComponent: React.FC<JuornalEventProps> = ({ setMenuState }) => {

    const {
        networkLayer: {
            network: { contractComponents, clientComponents },
        },
    } = useDojo();

    const openJurnal = () => {
        setMenuState(MenuState.REV_JURNAL);
    };

    //do we want the ones that have their event already confirmed to go?
    const ownOutpost: EntityIndex[] = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true, event_effected: true })]);
    // this is why the dead ones dont get added i think in the calc of the event the already dead ones dont get added to the event effected so dont appear HERE

    const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const lastEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id), BigInt(clientGameData!.current_event_drawn)]))

    const setCameraPos = (x: number, y: number) => {
        updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { x: x, y: y })

        const index = getTileIndex(x, y);
        updateComponent(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { tile_index: index })
    };

    //FOR THE ICON MAYBE DO THE SAME THING THAT WE ARE DOING FOR THE TITLE SECTION

    return (
        <ClickWrapper className="jurnal-event-container">
            <div className="jurnal-event-component-grid">
                <div className="jurnal-event-component-grid-title">
                    <div style={{ height: "100%", width: "100%", display: "flex", justifyContent: "flex-start", alignItems: "center" }}>
                        <h2 style={{ fontFamily: "Zelda", fontWeight: "100"}} className="test-h2 no-margin">REVENANT JOURNAL</h2>
                    </div>
                </div>
                <div className="jurnal-event-component-grid-enlarge center-via-flex">
                    <img className="pointer" onClick={() => openJurnal()} src="Icons/enlarge_icon.png" alt="Enlarge" style={{ height: "clamp(0.5rem, 0.5vw + 0.5rem, 4rem)", aspectRatio: "1/1" }} />
                </div>
                <div className="jurnal-event-component-grid-event-data">
                    {lastEvent !== undefined ?
                        (<>
                            <h3 className="no-margin test-h2" style={{ marginBottom: "3%" }}>Event Data #{clientGameData!.current_event_drawn}</h3>
                            <h4 className="no-margin test-h4">Radius: {lastEvent.radius} km</h4>
                            <h4 className="no-margin test-h4 pointer" onClick={() => setCameraPos(lastEvent.x, lastEvent.y)}>Position: X: {lastEvent.x}  || Y: {lastEvent.y}</h4>
                            {/* <h4 style={{ margin: "0px", fontSize: "1.1vw" }}>Type: {"null"}</h4> */}
                            <h4 className="no-margin test-h4">Next attack {lastEvent.block_number - clientGameData!.current_block_number <= 0 ? "IMMINENT!!" : `in ${lastEvent.block_number - clientGameData!.current_block_number} blocks`}</h4>
                            <h4 className="no-margin test-h4"></h4>
                        </>)
                        :
                        (<>
                            <h2 className="no-margin test-h2" style={{ marginBottom: "3%" }}>No event yet</h2>
                            <h4 className="no-margin test-h4"></h4>
                            <h4 className="no-margin test-h4"></h4>
                            <h4 className="no-margin test-h4"></h4>
                            <h4 className="no-margin test-h4"></h4>
                        </>)}
                </div>
                <div className="jurnal-event-component-grid-outpost-data">
                    {lastEvent !== undefined && <>
                        <h3 className="no-margin test-h2" style={{ marginBottom: "2%" }}>Your Outposts' Hit</h3>
                        {clientGameData!.guest ? <h3 className="no-margin test-h3">Log in to see your outpost that have been hit</h3> :

                            <div className="outpost-hit-list-container" >
                                {ownOutpost.map((outpostId: EntityIndex) => (
                                    <ListElement
                                        key={outpostId}
                                        entityIndex={outpostId}
                                        contractComponents={contractComponents}
                                    />
                                ))}
                            </div>
                        }
                    </>}

                    <div className="outpost-hit-list-container" >
                        {ownOutpost.map((outpostId: EntityIndex) => (
                            <ListElement
                                key={outpostId}
                                entityIndex={outpostId}
                                contractComponents={contractComponents}
                            />
                        ))}
                    </div>

                </div>
            </div>
        </ClickWrapper>
    );
};

const ListElement: React.FC<{ entityIndex: EntityIndex, contractComponents: any }> = ({ entityIndex, contractComponents }) => {

    const contractOutpostData: any = useComponentValue(contractComponents.Outpost, entityIndex);

    return (
        <>
            <h4 className="no-margin test-h4" style={{ textDecoration: contractOutpostData.lifes === 0 ? 'line-through' : 'none' }}>
                Outpost ID: {hexToNumber(contractOutpostData.entity_id.toString())} || X: {contractOutpostData.x}, Y: {contractOutpostData.y}
            </h4>
        </>
    );
};
