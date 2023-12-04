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

  const [eventData, setEventData] = useState({
    radius: 0,
    x: 0,
    y: 0,
  });

  const {
    networkLayer: {
      network: { contractComponents, clientComponents },
    },
  } = useDojo();

  const openJurnal = () => {
    setMenuState(MenuState.REV_JURNAL);
  };

  const allEvents = useEntityQuery([Has(contractComponents.WorldEvent)]);
  const ownOutpost = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true, event_effected: true })]);

  //should update based on the query above
  useEffect(() => {
    if (allEvents.length > 0) {

      //get the last event
      const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
      const gameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

      const worldEventData = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(gameEntityCounter.event_count)]));

      setEventData({
        radius: worldEventData.radius,
        x: worldEventData.x,
        y: worldEventData.y,
      });
    }
  }, [allEvents]);

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
        {/* <img src="enlarge_icon.svg" className="test-embed" alt=""  onMouseDown={() => (openJurnal())}></img> */}

      </ClickWrapper>

      <div className="current-data-container">
        {allEvents.length > 0 ? (
          <>
            <h3 className="sub-title">Current Event Data</h3>
            <h4>Radius: {eventData.radius}</h4>
            <h4>Type: Null</h4>
            <h4>Position: X:{eventData.x} Y:{eventData.y}</h4>
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

      {allEvents.length > 0 && (
        <div className="outpost-hit-data-container">
          <h3 className="sub-title">Outposts Hit</h3>
          <ClickWrapper className="outpost-hit-list-container">
            {ownOutpost.map((outpostData: EntityIndex) => (
              ListElement({ entityIndex: outpostData, clientComponents: clientComponents , contractComponents: contractComponents })
            ))}
          </ClickWrapper>
        </div>
      )}

    </div>
  );
};

const ListElement: React.FC<{ entityIndex: EntityIndex, clientComponents: any, contractComponents:any }> = ({ entityIndex, clientComponents, contractComponents }) => {

  const [outpostData, setOutpostData] = useState<JournalOutpostDataType>({
    id: "",
    x: 0,
    y: 0,
  });

  useEffect(() => {
    const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityIndex);
    const contractOutpostData = getComponentValueStrict(contractComponents.Outpost, entityIndex);

    setOutpostData({
      id: decimalToHexadecimal(clientOutpostData.id),
      x: contractOutpostData.x,
      y: contractOutpostData.y,
    });
  }, []);

  return (
    <>
      <h4>
        Outpost ID:{" "}
        {outpostData.id} || {" "}
        X: {outpostData.x}, Y:{" "}
        {outpostData.y}
      </h4>
    </>
  )
}