import React, { useState, useEffect } from "react";

import "./ComponentsStyles/OutpostTooltipStyles.css";

import { ClickWrapper } from "../clickWrapper";

import { useDojo } from "../../hooks/useDojo";

import { HasValue,  getComponentValueStrict, setComponent, EntityIndex } from "@latticexyz/recs";

import { useEntityQuery } from "@latticexyz/react";

import { ConfirmEventOutpost } from "../../dojo/types";

import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";
import { truncateString } from "../../utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { setOutpostClientComponent } from "../../dojo/testCalls";

interface OutpostTooltipProps { }



export const OutpostTooltipComponent: React.FC<OutpostTooltipProps> = ({ }) => {
  const [clickedOnOutposts, setClickedOnOutposts] = useState<any>([]);
  const [selectedIndex, setSelectedIndex] = useState<any>(0);

  const {
    account: { account },
    networkLayer: {
      systemCalls: {
        confirm_event_outpost
      },
      network: { contractComponents, clientComponents },
    },
  } = useDojo();

  const setArray = (selectedOutposts: any[]) => {
    for (let index = 0; index < clickedOnOutposts.length; index++) {
      const element = clickedOnOutposts[index];
      
      const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
      clientCompData.selected = false;

      setOutpostClientComponent(clientCompData.id, clientCompData.owned, clientCompData.event_effected, clientCompData.selected, clientCompData.visible, clientComponents)
    }

    if (selectedOutposts.length === 0) { 
      setClickedOnOutposts([]);
      return; 
    }

    setClickedOnOutposts(selectedOutposts);
    setSelectedIndex(0);

    const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, selectedOutposts[0]);
    setOutpostClientComponent(clientCompData.id, clientCompData.owned, clientCompData.event_effected, true, clientCompData.visible, clientComponents)
  }

  useEffect(() => {
    setTooltipArray.on("setToolTipArray", setArray);

    return () => {
      setTooltipArray.off("setToolTipArray", setArray);
    };
  }, []);


  const changeSelectedIndex = (value: number) => {
    if (clickedOnOutposts.length === 0) { return; }

    let newIndex = selectedIndex + value;

    if (newIndex < 0) { 
      newIndex = clickedOnOutposts.length - 1;  
    }
    else if (newIndex >= clickedOnOutposts.length) { 
      newIndex = 0; 
    }

    const oldSelectedOutpost = getComponentValueStrict(clientComponents.ClientOutpostData, clickedOnOutposts[selectedIndex]);
    oldSelectedOutpost.selected = false;
    setOutpostClientComponent(oldSelectedOutpost.id, oldSelectedOutpost.owned, oldSelectedOutpost.event_effected, false, oldSelectedOutpost.visible, clientComponents)

    const newSelectedOutpost = getComponentValueStrict(clientComponents.ClientOutpostData, clickedOnOutposts[newIndex]);
    newSelectedOutpost.selected = true;
    setOutpostClientComponent(newSelectedOutpost.id, newSelectedOutpost.owned, newSelectedOutpost.event_effected, true, newSelectedOutpost.visible, clientComponents)

    setSelectedIndex(newIndex);
  }


  if (clickedOnOutposts.length === 0) { return <div></div>; }



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
        <OutpostDataElement
          entityId={clickedOnOutposts[selectedIndex]}
          contractComponents={contractComponents}
          clientComponents={clientComponents}
          account={account}
          functionBuy={confirm_event_outpost}/>
      </div>

      <RevenantDataElement
        entityId={clickedOnOutposts[selectedIndex]}
        contractComponents={contractComponents}
        clientComponents={clientComponents}
        account={account}/>

      {clickedOnOutposts.length > 1 && (
        <ClickWrapper className="multi-out-container">
          <button className="outpost-data-event-button " onMouseDown={() => {changeSelectedIndex(-1)}}>{"<"}</button>
          <div>
            <h3>Outposts: {selectedIndex + 1}/{clickedOnOutposts.length}</h3>
          </div>
          <button className="outpost-data-event-button " onMouseDown={() => {changeSelectedIndex(1)}}> {">"} </button>
        </ClickWrapper>
      )}
    </div>
  );
};

const RevenantDataElement: React.FC<{entityId:EntityIndex, contractComponents: any, clientComponents:any, account : any}> = ({ entityId, contractComponents, clientComponents, account}) => {
  
  const [owner, setOwner] = useState<string>("");
  const [name, setName] = useState<string>("");
  const [id, setId] = useState<number>(0);

  useEffect(() => {
    const revenantData = getComponentValueStrict(contractComponents.RevenantData, entityId);
    const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);

    if (revenantData.owner === "0x0000")
    {
      setOwner("You");
    }
    else
    {
      setOwner(revenantData.owner);
    }

    setOwner(revenantData.owner);
    setName(revenantData.name);  // this is where we query the names arr
    setId(outpostClientData.id);
  }, []);

  return (
    <div className="revenant-data-container">
        <h1>REVENANT DATA</h1>
        {owner === "You" ? (<h3>You</h3>) : (<h3>{truncateString(owner,5)}</h3>)}
        <h3>Name: {name}</h3>
        <h3>ID: {id}</h3>
      </div>
  );
};

const OutpostDataElement: React.FC<{entityId:EntityIndex, contractComponents: any, clientComponents:any,account:any,functionBuy}> = ({ entityId, contractComponents,clientComponents, account, functionBuy}) => {
  
  enum OutpostStatus {
    DEAD,
    HEALTHY,
    IN_EVENT,
  }

  const [position, setPosition] = useState<any>({ x: 0, y: 0 });
  const [reinforcements, setReinforcements] = useState<number>(0);
  const [state, setState] = useState<OutpostStatus>(0);
  const [id, setId] = useState<number>(0);

  useEffect(() => {
    const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
    const contractOutpostData = getComponentValueStrict(contractComponents.OutpostData, entityId);

    setPosition({ x: contractOutpostData.x, y: contractOutpostData.y });
    setReinforcements(contractOutpostData.lifes);

    if (contractOutpostData.lifes === 0) {
      setState(OutpostStatus.DEAD);
    }
    else if (clientOutpostData.event_effected) {
      setState(OutpostStatus.IN_EVENT);
    }
    else {
      setState(OutpostStatus.HEALTHY);
    }
  }, []);

  const confirmEvent = async () => {
    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
    const gameTrackerData = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

    const confirmEventProps: ConfirmEventOutpost = {
      account: account,
      game_id: clientGameData.current_game_id,
      event_id: gameTrackerData.event_count,
      outpost_id: id,
    };

    await functionBuy(confirmEventProps);
  }

  return (
    <>
      <h1>OUTPOST DATA</h1>
        <h3>X:{position.x}, Y:{position.y}</h3>
        <h3>Reinforcements: {reinforcements}</h3>
        <h3>State: {(() => {
        
          switch (state) {
            case OutpostStatus.HEALTHY:
              return <span style={{ color: 'green' }}>Healthy</span>;
            case OutpostStatus.IN_EVENT:
              return (
                <div>
                  <span style={{ color: 'orange' }}>In Event</span>
                   {/* {revenantData.owner === account.address ?  <ClickWrapper className="outpost-data-event-button" onMouseDown={() => {confirmEvent()}}>Confirm Event</ClickWrapper> : <div></div>} */}
                   <ClickWrapper className="outpost-data-event-button" onMouseDown={() => {confirmEvent()}}>Confirm Event</ClickWrapper>
                </div>
              );
            case OutpostStatus.DEAD:
              return <span style={{ color: 'red' }}>Destroyed</span>;
            default:
              return null;
          }
        })()}</h3>
    </>
  );
};


/*notes
  this component should have an event that takes a list of entity ids and start by displaying the first one

  if more it should show a counter like elemnt at the bottom that allows the user to navigate through the list

  the only thing that changes between outposts is the state at whihc they are at

  this component should also deal wiht the setting of the selected outpost and the deselection of the previous one so highlight it

the update of the outpost will be done on demand from the clicking on them so this will be done here, when an outpost is selecet it will query it self to update its data

*/

