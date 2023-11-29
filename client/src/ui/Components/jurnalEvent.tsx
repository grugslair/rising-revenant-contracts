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
// import { GAME_CONFIG } from "../../phaser/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { decimalToHexadecimal } from "../../utils";





type JournalOutpostDataType =
{
  id: string,
  x: number,
  y: number,
}

interface JuornalEventProps {
  setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const JurnalEventComponent: React.FC<JuornalEventProps> = ({ setMenuState }) => {
  // return (<></>)

  const [allOutpostEffected, setAllOutpostEffected] = useState<JournalOutpostDataType[]>([]);

  const {
    networkLayer: {
      network: { contractComponents, clientComponents },
    },
  } = useDojo();

  // const openJurnal = () => {
  //   setMenuState(MenuState.REV_JURNAL);
  // };

  const eventArray = useEntityQuery([Has(contractComponents.WorldEvent)]);
  const currentlyHitOutposts = useEntityQuery([HasValue(clientComponents.ClientOutpostData, {event_effected: true})])

  const gameClientData = getComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

  useEffect(() => {
    
      if (eventArray.length === 0)
      {
        return;
      }

      // there prob is no need for the loop here and just do a simple  =  in the future

      let outpostDataArr: JournalOutpostDataType[] = []

      for (let index = 0; index < currentlyHitOutposts.length; index++) {
        const element = currentlyHitOutposts[index];
        
        const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
        const outpostData = getComponentValueStrict(contractComponents.Outpost, element);

        const dataToSave:JournalOutpostDataType = {id: clientOutpostData.id, x: outpostData.x, y: outpostData.y}
        outpostDataArr.push(dataToSave);
      }

      setAllOutpostEffected(outpostDataArr);
  
    
  }, [eventArray])
  

  if (eventArray.length === 0) { return (<></>) }

  // console.log(eventArray.length)

  const gameTrackerComp = getComponentValue(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(gameClientData.current_game_id)]));
  const eventData = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(decimalToHexadecimal(gameClientData.current_game_id)),BigInt(gameTrackerComp.event_count)]));

  if (eventData === undefined) { return (<></>) }

  return (
    <div className="jurnal-event-container">
      <ClickWrapper className="title-div-container">
        <h2>
          REVENANT JOURNAL {" "}
          {/* <img
            src="LOGO_WHITE.png"
            style={{ maxHeight: "1em", verticalAlign: "top", marginLeft: "auto" }}
            alt="Logo"
            onMouseDown={() => (openJurnal())}
          ></img> */}
        </h2>
      </ClickWrapper>

      <div className="current-data-container">
        <h3 className="sub-title">Current Event Data</h3>
        <h4>Radius: {eventData.radius}</h4>
        <h4>Type: Null</h4>
        <h4>Position: X:{eventData.x} Y:{eventData.y}</h4>
      </div>

      <div className="outpost-hit-data-container">
        <h3 className="sub-title">Outposts Hit</h3>
        <ClickWrapper className="outpost-hit-list-container">
          {allOutpostEffected.map((outpostData: JournalOutpostDataType) => (
            <h4>
              Outpost ID:{" "}
              {outpostData.id} || {" "}
              X: {outpostData.x}, Y:{" "}
              {outpostData.y}
            </h4>
          ))}
        </ClickWrapper>
      </div>
    </div>
  );
};
