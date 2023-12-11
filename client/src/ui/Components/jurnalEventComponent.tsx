import React, { useEffect, useState } from "react";
import {
    EntityIndex,
    Has,
    HasValue,
    getComponentValueStrict,
    getComponentValue
} from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";

import "./ComponentsStyles/JurnalEventStyles.css";

import { MenuState } from "../Pages/gamePhaseManager";

import { ClickWrapper } from "../clickWrapper";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { isNullableType } from "graphql";


interface JuornalEventProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

//HERE THIS IS VERY BROKEN AND NEEDS THE BACKGROUND MAYBE TAKEN CARE OFF I AM NOT TOO SURE

export const JurnalEventComponent: React.FC<JuornalEventProps> = ({ setMenuState }) => {

    const [effectedOutposts, setEffectecOutposts] = useState([getEntityIdFromKeys([BigInt(1), BigInt(1)])]);

    const {
        networkLayer: {
            network: { contractComponents, clientComponents },
        },
    } = useDojo();

    const openJurnal = () => {
        setMenuState(MenuState.REV_JURNAL);
    };

    //do we want the ones that have their event already confirmed to go?
    const ownOutpost = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true, event_effected: true })]);

    // useEffect(() => {
    //     console.error(effectedOutposts);
    //     setEffectecOutposts(ownOutpost);
    // }, [ownOutpost])

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
    const lastEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientGameData.current_event_drawn)]))

    return (
        <div className="jurnal-event-container">
            {/* this is to check as i dont think it is standardisez */}
            <ClickWrapper className="title-div-container">
                <h2>
                    REVENANT JOURNAL {" "}
                </h2>

                <h2 onMouseDown={() => (openJurnal())} className="close-button">
                    X
                </h2>

            </ClickWrapper>

            <div className="current-data-container">
                {lastEvent !== undefined ? (
                    <>
                        <h3 className="sub-title">Current Event Data #{clientGameData.current_event_drawn}</h3>
                        <h4>Radius: {lastEvent.radius}</h4>
                        <h4>Type: Null</h4>
                        <h4>Position: X: {lastEvent.x}  || Y: {lastEvent.y}</h4>
                    </>
                ) : (
                    <>
                        <h3 className="sub-title">No event Yet</h3>
                        <h4></h4>
                        <h4></h4>
                        <h4></h4>
                    </>
                )}
            </div>

            {lastEvent !== undefined && (
                <div className="outpost-hit-data-container">
                    <h3 className="sub-title">Outposts Hit</h3>
                    <ClickWrapper className="outpost-hit-list-container">
                        {ownOutpost.map((outpostId: EntityIndex) => (
                            <ListElement
                                key={outpostId}
                                entityIndex={getComponentValue(clientComponents.ClientOutpostData, outpostId).id}
                                contractComponents={contractComponents}
                            />
                        ))}
                    </ClickWrapper>
                </div>
            )}
        </div>
    );
};

const ListElement: React.FC<{ entityIndex: EntityIndex, contractComponents: any }> = ({ entityIndex, contractComponents }) => {
    const [outpostData, setOutpostData] = useState({
        id: 0,
        x: 0,
        y: 0,
    });
    const [lifes, setLifes] = useState(0);

    const contractOutpostDataQuery = useEntityQuery([HasValue(contractComponents.Outpost, { entity_id: BigInt(entityIndex) })]);

    useEffect(() => {

        const contractOutpostData = getComponentValueStrict(contractComponents.Outpost, contractOutpostDataQuery[0]);

        setOutpostData({
            id: Number(contractOutpostData.entity_id),
            x: contractOutpostData.x,
            y: contractOutpostData.y,
        });

        setLifes(contractOutpostData.lifes); // Assuming the correct property is 'lifes'
    }, [contractOutpostDataQuery]);

    return (
        <>
            <h4 style={{ textDecoration: lifes === 0 ? 'line-through' : 'none' }}>
                Outpost ID: {outpostData.id} || X: {outpostData.x}, Y: {outpostData.y}
            </h4>
        </>
    );
};
