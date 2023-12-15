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
            <div className="jurnal-event-component-grid">
                <div className="jurnal-event-component-grid-title">
                    <div style={{height:"100%", width:"100%", display:"flex", justifyContent:"flex-start", alignItems:"center"}}>
                        <h2 style={{fontFamily:"Zelda", fontWeight:"100", fontSize:"1.8vw"}}>REVENANT JOURNAL</h2>
                    </div>
                </div>
                <ClickWrapper className="jurnal-event-component-grid-enlarge center-via-flex">
                    <img className="pointer" onClick={() => openJurnal()} src="LOGO_WHITE.png" alt="Enlarge" style={{height:"80%", width:"80%"}}/>
                </ClickWrapper>
                <div className="jurnal-event-component-grid-event-data">
                    <h2 style={{fontSize:"1.7vw", marginBottom:"3%"}}>Outpost Event</h2>
                    <h4 style={{margin:"0px", fontSize:"1.1vw"}}>Radius</h4>
                    <h4 style={{margin:"0px", fontSize:"1.1vw"}}>Type</h4>
                    <h4 style={{margin:"0px", fontSize:"1.1vw"}}>Coords</h4>
                </div>
                <div className="jurnal-event-component-grid-outpost-data">
                    <h2 style={{margin:"0px", marginBottom:"2%", fontSize:"1.7vw"}}>Your Outposts Hit</h2>
                    <ClickWrapper className="outpost-hit-list-container" >
                        <ListElement
                            entityIndex={3 as EntityIndex}
                            contractComponents={5}
                        />
                    </ClickWrapper>
                </div>
            </div>
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
            <h3 style={{ textDecoration: lifes === 0 ? 'line-through' : 'none' , margin:"0px", fontSize:"1.2vw"}}>
                Outpost ID: {outpostData.id} || X: {outpostData.x}, Y: {outpostData.y}
            </h3>
        </>
    );
};
