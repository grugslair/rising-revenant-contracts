import React, { useState, useEffect } from "react";

import "./ComponentsStyles/OutpostTooltipStyles.css";

import { ClickWrapper } from "../clickWrapper";

import { useDojo } from "../../hooks/useDojo";

import { HasValue,  getComponentValueStrict, setComponent } from "@latticexyz/recs";

import { useEntityQuery } from "@latticexyz/react";

import { ConfirmEventOutpost } from "../../dojo/types";

import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";
import { truncateString } from "../../utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";

interface OutpostTooltipProps { }

export const OutpostTooltipComponent: React.FC<OutpostTooltipProps> = ({ }) => {
  const [selectedIndexFromArray, setSelectedIndexFromArray] = useState<any>(0);
  const [entityIdSelected, setEntityIdSelected] = useState<any>(0);
  const [selectedIndex, setSelectedIndex] = useState<any>(1);

  const [arrayOfEntities, setArrayOfEntities] = useState<any>([]);

  const {
    account: { account },
    networkLayer: {
      systemCalls: {
        reinforce_outpost, confirm_event_outpost
      },
      network: { contractComponents, clientComponents },
    },
  } = useDojo();

  let selectedOutposts = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { selected: true })]);

  const setArray = (array: any[]) => {

    // this loop does not convince me
    for (let index = 0; index < selectedOutposts.length; index++) {

      const element = selectedOutposts[index];
      const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
      setComponent(clientComponents.ClientOutpostData, element, { id: clientCompData.id, event_effected: clientCompData.event_effected,visible : clientCompData.visible, selected: false, owned: clientCompData.owned })
    }

    if (array.length === 0) { setArrayOfEntities([]); return; }
    console.log(array.length);
    setSelectedIndexFromArray(0);
    setArrayOfEntities(array);

    setEntityIdSelected(array[0]);
  }

  useEffect(() => {
    setTooltipArray.on("setToolTipArray", setArray);

    return () => {
      setTooltipArray.off("setToolTipArray", setArray);
    };
  }, []);

  useEffect(() => {

    for (let index = 0; index < selectedOutposts.length; index++) {
      const element = selectedOutposts[index];
      
      const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
      setComponent(clientComponents.ClientOutpostData, element, { id: clientCompData.id, event_effected: clientCompData.event_effected, visible : clientCompData.visible,selected: false, owned: clientCompData.owned })
    }

    if (arrayOfEntities.length === 0) { return; }

    const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, entityIdSelected);

    setComponent(clientComponents.ClientOutpostData, entityIdSelected, { id: outpostClientData.id, event_effected: outpostClientData.event_effected, visible: outpostClientData.visible,selected: true, owned: outpostClientData.owned })

  }, [entityIdSelected])


  if (arrayOfEntities.length === 0) { return <div></div>; }

  // const revenantData = getComponentValueStrict(contractComponents.Revenant, entityIdSelected);
  const outpostData = getComponentValueStrict(contractComponents.Outpost, entityIdSelected);

  const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, entityIdSelected);

  const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
  
  const ChangeCounter = (number: number) => {

    const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, entityIdSelected);

    // just realised this works now for some reason setComponent is what should be use
    setComponent(clientComponents.ClientOutpostData, entityIdSelected, { id: outpostClientData.id, event_effected: outpostClientData.event_effected,visible : outpostClientData.visible, selected: false, owned: outpostClientData.owned })

    setSelectedIndex(1);

    if (arrayOfEntities.length === 1) {
      return;
    }

    if (selectedIndexFromArray + number >= arrayOfEntities.length) {
      setSelectedIndexFromArray(0);
      setEntityIdSelected(arrayOfEntities[0]);
      setSelectedIndex(1);
      return;
    }
    else if (selectedIndexFromArray + number < 0) {
      setSelectedIndexFromArray(arrayOfEntities.length - 1);
      setEntityIdSelected(arrayOfEntities[arrayOfEntities.length - 1]);
      setSelectedIndex(arrayOfEntities.length);
      return;
    }
    
    else {
      setSelectedIndexFromArray(selectedIndexFromArray + number);
      setEntityIdSelected(arrayOfEntities[selectedIndexFromArray + number]);
      setSelectedIndex(selectedIndexFromArray + number + 1);
      return;
    }
  }

  const confirmEvent = async () => {

      const gameTrackerData = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

      const confirmEventProps: ConfirmEventOutpost = {
        account: account,
        game_id: clientGameData.current_game_id,
        event_id: gameTrackerData.event_count,
        outpost_id: outpostClientData.id,
      };
  
      await confirm_event_outpost(confirmEventProps);
  }

  const GetOutpostStatus = () => {

    if (outpostData.lifes === 0) {
      return 3;
    }
    if (outpostClientData.event_effected) {
      return 2;
    }

    return 1;
  }

  return (
    <div className="outpost-tooltip-container">
      <div className="outpost-data-container">
        <ClickWrapper
          className="top-right-button"
          style={{ fontSize: "2rem", top: "8px", right: "8px" }}
          onMouseDown={() => {setArray([]) }}
        >
          X
        </ClickWrapper>
        <h1>OUTPOST DATA</h1>
        <h3>X:{outpostData.x}, Y:{outpostData.y}</h3>
        <h3>Reinforcements: {outpostData.lifes}</h3>
        <h3>State: {(() => {
          const outpostStatus = GetOutpostStatus();

          switch (outpostStatus) {
            case 1:
              return <span style={{ color: 'green' }}>Healthy</span>;
            case 2:
              return (
                <div>
                  <span style={{ color: 'orange' }}>In Event</span>
                   {/* {revenantData.owner === account.address ?  <ClickWrapper className="outpost-data-event-button" onMouseDown={() => {confirmEvent()}}>Confirm Event</ClickWrapper> : <div></div>} */}
                   <ClickWrapper className="outpost-data-event-button" onMouseDown={() => {confirmEvent()}}>Confirm Event</ClickWrapper>
                </div>
              );
            case 3:
              return <span style={{ color: 'red' }}>Destroyed</span>;
            default:
              return null;
          }
        })()}</h3>
      </div>

      <div className="revenant-data-container">
        <h1>REVENANT DATA</h1>
        {/* {revenantData.owner === account.address ?   <h3>Owner: You</h3> : <h3>Owner: {truncateString(revenantData.owner, 5)}</h3>} */}
        <h3>Name: {`Revenant ${outpostClientData.id}`}</h3>
        <h3>ID: {outpostClientData.id}</h3>
      </div>

      {arrayOfEntities.length > 1 && (
        <ClickWrapper className="multi-out-container">
          <button className="outpost-data-event-button " onMouseDown={() => {ChangeCounter(-1)}}>{"<"}</button>
          <div>
            <h3>Outposts: {selectedIndex}/{arrayOfEntities.length}</h3>
          </div>
          <button className="outpost-data-event-button " onMouseDown={() => {ChangeCounter(1)}}> {">"} </button>
        </ClickWrapper>
      )}
    </div>
  );
};