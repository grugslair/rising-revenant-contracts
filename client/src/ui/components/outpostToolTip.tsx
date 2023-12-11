import React, { useState, useEffect } from "react";

import "./ComponentsStyles/OutpostTooltipStyles.css";

import { ClickWrapper } from "../clickWrapper";

import { useDojo } from "../../hooks/useDojo";

import { getComponentValueStrict, EntityIndex, HasValue, getComponentValue } from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";

import { ConfirmEventOutpost } from "../../dojo/types";

import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";
import { decimalToHexadecimal, fetchSpecificOutRevData, namesArray, setClientOutpostComponent, setComponentsFromGraphQlEntitiesHM, surnamesArray, truncateString } from "../../utils";
import { GAME_CONFIG } from "../../phaser/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useNetworkLayer } from "../../hooks/useNetworkLayer";

interface OutpostTooltipProps { }

//HERE the X on the side is not correct also the size is not correct
// ALSO on the selected update data THIS SHOULD BE DONE
// THHERE IS ALSO THE ISSUE THAT THE TOOLTIP DOES NOT GET UPDATE 
// there is a new style :|

export const OutpostTooltipComponent: React.FC<OutpostTooltipProps> = ({ }) => {
  const [clickedOnOutposts, setClickedOnOutposts] = useState<any>([]);
  const [selectedIndex, setSelectedIndex] = useState<any>(0);

  const {
    account: { account },
    networkLayer: {
      systemCalls: {
        confirm_event_outpost
      },
      network: { contractComponents, clientComponents, graphSdk },
    },
  } = useDojo();

  const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
  const selectedOutpost = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { selected: true })]);

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
    setClientOutpostComponent(oldSelectedOutpost.id, oldSelectedOutpost.owned, oldSelectedOutpost.event_effected, oldSelectedOutpost.selected, oldSelectedOutpost.visible, clientComponents,  contractComponents,clientGameData.current_game_id)

    const newSelectedOutpost = getComponentValueStrict(clientComponents.ClientOutpostData, clickedOnOutposts[newIndex]);
    newSelectedOutpost.selected = true;
    setClientOutpostComponent(newSelectedOutpost.id, newSelectedOutpost.owned, newSelectedOutpost.event_effected, true, newSelectedOutpost.visible, clientComponents,  contractComponents,clientGameData.current_game_id)

    setSelectedIndex(newIndex);
  }

  const setArray = async (selectedOutposts: any[]) => {

    for (let index = 0; index < clickedOnOutposts.length; index++) {
      const entity_id = clickedOnOutposts[index];
      const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entity_id);
      setClientOutpostComponent(clientOutpostData.id, clientOutpostData.owned, clientOutpostData.event_effected, false, clientOutpostData.visible, clientComponents,  contractComponents,clientGameData.current_game_id)
    }

    if (selectedOutposts.length === 0) {
      setClickedOnOutposts([]);
      return;
    }

    setClickedOnOutposts(selectedOutposts);

    for (let index = 0; index < selectedOutposts.length; index++) {
      const entity_id = selectedOutposts[index];
      const outpostData = getComponentValueStrict(contractComponents.Outpost, entity_id);
      const outpostModelQuery = await fetchSpecificOutRevData(graphSdk, clientGameData.current_game_id, Number(outpostData.entity_id));
      setComponentsFromGraphQlEntitiesHM(outpostModelQuery, contractComponents, false);
    }

    setSelectedIndex(0);

    const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, selectedOutposts[0]);
    setClientOutpostComponent(clientCompData.id, clientCompData.owned, clientCompData.event_effected, true, clientCompData.visible, clientComponents,  contractComponents,clientGameData.current_game_id)
  }

  const desmountComponentAction = () => {
    if (selectedOutpost[0] !== undefined && selectedOutpost[0] !== null) {
      console.log(selectedOutpost[0] );
      const clientCompData = getComponentValueStrict(clientComponents.ClientOutpostData, selectedOutpost[0]);

      setClientOutpostComponent(clientCompData.id, clientCompData.owned, clientCompData.event_effected, false, clientCompData.visible, clientComponents,  contractComponents,clientGameData.current_game_id);
    }
  }


  useEffect(() => {

    return () => {
      desmountComponentAction()

    };
  }, [selectedOutpost]);


  useEffect(() => {

    setTooltipArray.on("setToolTipArray", setArray);

    return () => {
      setTooltipArray.off("setToolTipArray", setArray);

    };
  }, [clickedOnOutposts]);

  if (clickedOnOutposts.length === 0) { return <div></div>; }

  return (
    <div className="outpost-tooltip-container" >
      <div className="outpost-data-container" style={{position:"relative"}}>

        {selectedOutpost[0] !== undefined && (
          <OutpostDataElement
            entityId={selectedOutpost[0]}
            contractComponents={contractComponents}
            clientComponents={clientComponents}
            account={account}
            functionEvent={confirm_event_outpost}
            functionClose={setArray} />
        )}

      </div>

      {selectedOutpost[0] !== undefined && (
        <RevenantDataElement
          entityId={selectedOutpost[0]}
          contractComponents={contractComponents}
          clientComponents={clientComponents}
          account={account} />
      )}

      {clickedOnOutposts.length > 1 && (
        <ClickWrapper className="multi-out-container">
          <button className="outpost-data-event-button " onMouseDown={() => { changeSelectedIndex(-1) }}>{"<"}</button>
          <div>
            <h3>Outposts: {selectedIndex + 1}/{clickedOnOutposts.length}</h3>
          </div>
          <button className="outpost-data-event-button " onMouseDown={() => { changeSelectedIndex(1) }}> {">"} </button>
        </ClickWrapper>
      )}

    </div>
  );
};

const RevenantDataElement: React.FC<{ entityId: EntityIndex, contractComponents: any, clientComponents: any, account: any }> = ({ entityId, contractComponents, clientComponents, account }) => {

  const [owner, setOwner] = useState<string>("");
  const [name, setName] = useState<string>("");
  const [id, setId] = useState<number>(0);

  const revenantData = getComponentValueStrict(contractComponents.Revenant, entityId);
  const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);

  useEffect(() => {

    if (revenantData.owner === account.address) {
      setOwner("You");
    }
    else {
      setOwner(revenantData.owner);
    }

    const name = namesArray[revenantData.first_name_idx] + " " + surnamesArray[revenantData.last_name_idx];

    setOwner(revenantData.owner);
    setName(name);
    setId(outpostClientData.id);
  }, [entityId]);

  return (
    <div className="revenant-data-container">
      <h1>REVENANT DATA</h1>
      {owner === "You" ? (<h3>You</h3>) : (<h3>{truncateString(owner, 5)}</h3>)}
      <h3>Name: {name}</h3>
      <h3>ID: {id}</h3>
    </div>
  );
};


const OutpostDataElement: React.FC<{ entityId: EntityIndex, contractComponents: any, clientComponents: any, account: any, functionEvent, functionClose }> = ({ entityId, contractComponents, clientComponents, account, functionEvent, functionClose }) => {

  enum OutpostStatus {
    DEAD,
    HEALTHY,
    IN_EVENT,
  }

  const [position, setPosition] = useState<any>({ x: 0, y: 0 });
  const [reinforcements, setReinforcements] = useState<number>(0);
  const [state, setState] = useState<OutpostStatus>(0);
  const [id, setId] = useState<number>(0);

  const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
  const contractOutpostData = useEntityQuery([HasValue(contractComponents.Outpost, { entity_id: BigInt(clientOutpostData.id) })]);

  useEffect(() => {

    if (contractOutpostData[0] === null || contractOutpostData[0] === undefined) { return; }

    const contractOutpostDataElement = getComponentValueStrict(contractComponents.Outpost, contractOutpostData[0]);

    setPosition({ x: contractOutpostDataElement.x, y: contractOutpostDataElement.y });
    setReinforcements(contractOutpostDataElement.lifes);

    setId(Number(contractOutpostDataElement.entity_id));

    if (contractOutpostDataElement.lifes === 0) {
      setState(OutpostStatus.DEAD);
    }
    else if (clientOutpostData.event_effected) {
      setState(OutpostStatus.IN_EVENT);
    }
    else {
      setState(OutpostStatus.HEALTHY);
    }
  }, [contractOutpostData]);

  const confirmEvent = async () => {
    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
    const gameTrackerData = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

    const confirmEventProps: ConfirmEventOutpost = {
      account: account,
      game_id: clientGameData.current_game_id,
      event_id: gameTrackerData.event_count,
      outpost_id: id,
    };

    await functionEvent(confirmEventProps);
  }

  return (
    <>
      <ClickWrapper style={{ height: "fit-content", display: "flex", justifyContent: "space-between", alignItems: "center", gap: "10px", textAlign: "center" }}>
        <h1>OUTPOST DATA</h1>
        <h1 onClick={() => functionClose([])} className="pointer">X</h1>
      </ClickWrapper>
      {/* <img src="test_out_pp.png" style={{height:"30%", width:"100%", margin:"5px 5px"}}></img> */}
      {/* <div style={{width:"100%", display:"flex", justifyContent:"flex-start", alignItems:"center", height:"10%", flexDirection:"row"}}> */}
        {/* <div style={{height:"100%", width:"60%", backgroundColor:"red"}}>
          <img style={{flex:"1", height:"100%"}} src="SHIELD.png"></img>
          <img style={{flex:"1", height:"100%"}} src="SHIELD.png"></img>
          <div style={{flex:"1"}}></div>
          <div style={{flex:"1"}}></div>
          <div style={{flex:"1"}}></div>
        </div>
      </div> */}
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
                <ClickWrapper className="outpost-data-event-button" onMouseDown={() => { confirmEvent() }}>Confirm Event</ClickWrapper>
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

