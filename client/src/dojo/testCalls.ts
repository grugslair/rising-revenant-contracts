import { request, gql } from 'graphql-request';
import { decimalToHexadecimal } from '../utils';
import { getEntityIdFromKeys, setComponentFromGraphQLEntity } from '@dojoengine/utils';
import { GAME_CONFIG } from '../phaser/constants';

import {
  getComponentValue,
  getComponentValueStrict,
} from "@latticexyz/recs";

// this script is a mess


interface DataFormatted {
  allKeys: string[];
  gameModels: any[];
}

const getDataFormatted = (entities: any, typename: string): DataFormatted => {
  let allKeys: string[] = [];
  let gameModels: any[] = [];

  for (const edge of entities.edges) {
    const node = edge.node;

    if (node.models) {
      const gameModel = node.models.find((model: any) => model.__typename === typename);

      if (gameModel) {
        allKeys = allKeys.concat(node.keys);
        gameModels.push(gameModel);
      }
    }
  }

  return { allKeys, gameModels };
}


interface Model {
  __typename: string;
}

interface Node {
  keys: string[];
  models: Model[];
}

interface Data {
  node: Node;
}

function removeModelsByTypename(data: Data, typenamesToRemove: string[]): Data {
  const updatedData: Data = { ...data };

  if (updatedData.node && updatedData.node.models) {
    updatedData.node.models = updatedData.node.models.filter(
      (model) => !typenamesToRemove.includes(model.__typename)
    );
  }

  return updatedData;
}




interface Edge {
  node: Node;
}

interface Data {
  edges: Edge[];
}

function extractSpecificNode(data: Data, key: string): Edge | null {
  for (const edge of data.edges) {
    if (
      edge.node &&
      edge.node.keys &&
      edge.node.keys.length === 1 && // Ensure only one key is present
      edge.node.keys[0] === key &&
      edge.node.models
    ) {
      return edge;
    }
  }
  return null;
}



interface ComponentSchema {
  [key: string]: any;
}

export function createComponentStructure(componentSchema: ComponentSchema, keys: string[], componentName: string): any {
  return {
    "node": {
      "keys": keys,
      "models": [
        {
          "__typename": componentName,
          ...componentSchema
        }
      ]
    }
  };
}


//#region GAME RELATED DATABASE CALLS

export const getGameEntitiesSpecific = async (graphSDK_: any, key_: string) => {
  let {
    data: { entities },
  } = await graphSDK_().getGameEntity({ key: key_ })

  const adjustedStartPoint: any = extractSpecificNode(entities, key_);
  const newData = removeModelsByTypename(adjustedStartPoint, ["GameTracker"])

  return newData;
}

export async function getGameTrackerEntity() {
  const query = gql`
    query getEntities {
      entities(keys: ["0x1"]) {
        edges {
          node {
            keys
            models {
              __typename
              ... on GameTracker {
                count
              }
            }
          }
        }
      }
    }
  `;

  const endpoint = 'https://api.cartridge.gg/x/risingrevenant/torii/graphql';
  // const endpoint = 'http://127.0.0.1:8080/graphql';

  try {
    const data: any = await request(endpoint, query);

    const gameTrackerCount: number | undefined = data!.entities.edges
      .find(edge => edge.node.models.some((model: any) => model.__typename === "GameTracker"))
      ?.node.models.find((model: any) => model.__typename === "GameTracker")?.count;

    return gameTrackerCount;

  } catch (error) {
    console.error('Error executing GraphQL query:', error);
    throw error;
  }
}



//#endregion

//#region OUTPOST DATABASE RELATED CALLS

export const getOutpostEntitySpecific = async (graphSDK_: any, game_id: string, entity_id: string): Promise<DataFormatted[]> => {
  const {
    data: { entities },
  } = await graphSDK_().getOutpostEntity({ game_id: game_id, entity_id: entity_id })

  return entities
}

export const getFullOutpostGameData = async (graphSDK_: any, game_id: string, end_index: number, start_index: number = 1) => {

  try {
    let arrOfEntities: any[] = [];

    for (let index = start_index; index < end_index + 1; index++) {
      const {
        data: { entities },
      } = await graphSDK_().getOutpostEntity({ game_id: game_id, entity_id: decimalToHexadecimal(index) });

      arrOfEntities.push(entities.edges[0]);
    }

    return arrOfEntities;
  } catch (error) {
    console.error('Error fetching outpost game data:', error);
    throw error;
  }
};


export const getReinforcementSpecific = async (graphSDK_: any, game_id: string, owner: string) => {
  const {
    data: { entities },
  } = await graphSDK_().getReinforcement({ game_id: game_id, owner: owner })

  if (entities.edges.length === 0) {
    return undefined;
  }
  else {
  
  }

  return entities;
}


//#endregion


//#region WORLDEVENT RELATED DATABASE CALLS

export const getWorldEventEntitySpecific = async (graphSDK_: any, game_id: string, entity_id: string): Promise<DataFormatted> => {
  const {
    data: { entities },
  } = await graphSDK_().getWorldEventEntity({ game_id: game_id, entity_id: entity_id })

  const { allKeys, gameModels } = getDataFormatted(entities, "WorldEvent")

  return { allKeys, gameModels };
}

export const getFullEventGameData = async (graphSDK_: any, game_id: string, end_index: number, start_index: number = 1) => {

  if (graphSDK_ === undefined || graphSDK_ !== undefined)
  {
    //filler code
  }

  let arrOfEntities: any[] = [];

    for (let index = start_index; index < end_index + 1; index++) {
      // const {
      //   data: { entities },
      // } = await graphSDK_().getWorldEventEntity({ game_id: game_id, entity_id: decimalToHexadecimal(index) });

      const entities: any = await getEventEntity(game_id, decimalToHexadecimal(index));

      const fixedType = getWorldEventSection(entities);

      const stuff = createComponentStructure({
        "block_number": fixedType[0].block_number,
        "destroy_count": fixedType[0].destroy_count,
        "entity_id": fixedType[0].entity_id,
        "game_id":  fixedType[0].game_id,
        "radius": fixedType[0].radius,
        "x": fixedType[0].x,
        "y": fixedType[0].y,

      }, [entities[0].node.keys[0], entities[0].node.keys[1]], "WorldEvent")

      arrOfEntities.push(stuff);
    }

    return arrOfEntities;
};



// migght be an issue
type NodeWE = {
  keys: string[];
  models: {
    __typename: string;
    game_id: number;
    entity_id: string;
    x: number;
    y: number;
    radius: number;
    destroy_count: number;
    block_number: number;
  }[];
};

function getWorldEventSection(data: { node: NodeWE }[]): { __typename: string; game_id: number; entity_id: string; x: number; y: number; radius: number; destroy_count: number; block_number: number }[] {
  return data
    .flatMap((item) => item.node.models.filter((model) => model.__typename === "WorldEvent"))
    .map(({ __typename, game_id, entity_id, x, y, radius, destroy_count, block_number }) => ({
      __typename,
      game_id,
      entity_id,
      x,
      y,
      radius,
      destroy_count,
      block_number,
    }));
}


export async function getEventEntity(game_id: string, entity_id: string) {
  const query = gql`
  query getEntities {
    entities(keys: ["${game_id}", "${entity_id}"]) {
      edges {
        node {
          keys
          models {
            __typename
             ... on WorldEvent {
              game_id
              entity_id
              x
              y
              radius
              destroy_count
              block_number
            }
          }
        }
      }
    }
  }`;

  const endpoint = 'https://api.cartridge.gg/x/risingrevenant/torii/graphql';
  // const endpoint = 'http://127.0.0.1:8080/graphql';


  try {
    const data: any = await request(endpoint, query);

    console.log("this is the data for the event", data);

    const gameTrackerCount = data.entities.edges;
    console.log("this is the game tracker count", gameTrackerCount);

    return gameTrackerCount;

  } catch (error) {
    console.error('Error executing GraphQL query:', error);
    throw error;
  }
}


//#endregion


export function setComponentQuick(schema: any, keys: string[], componentName: string, components: any) {
  const component = createComponentStructure(schema, keys, componentName);
  setComponentFromGraphQLEntity(components, component);
}

export const setClientGameComponent = async (phase: number,  game_id: number, current_block: number, clientComponents: any, contractComponents: any, account: string) => {

  const firstOutpost = getComponentValue(contractComponents.Outpost, getEntityIdFromKeys([BigInt(game_id), BigInt(1)]))

  let current_game_admin = false;

  if (firstOutpost !== undefined)
  { 
    if (firstOutpost.owner ===account)
      {current_game_admin = true}
   
  }

  const componentSchemaClientGameData = {
    "current_game_state": phase,
    "current_game_id": game_id,
    "current_block_number": current_block,
    "current_game_admin": current_game_admin,
  };

  const craftedEdgeGT = createComponentStructure(componentSchemaClientGameData, ["0x1"], "ClientGameData");
  setComponentFromGraphQLEntity(clientComponents, craftedEdgeGT);
}

export const setOutpostClientComponent = async (id: number, owned: boolean, event_effected: boolean, disabled: boolean, visible: boolean,clientComponents: any) => {

  const game_id = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)])).current_game_id;

  const componentSchemaClientGameData = {
    "id": id,
    "owned": owned,
    "event_effected": event_effected,
    "selected": disabled,
    "visible": visible
  };

  const craftedEdgeGT = createComponentStructure(componentSchemaClientGameData, [decimalToHexadecimal(game_id), decimalToHexadecimal(id)], "ClientOutpostData");
  setComponentFromGraphQLEntity(clientComponents, craftedEdgeGT);
}

export const getUpdatedGameData = async (blockCount: number, clientComponents: any, contractComponents: any, address: string, graphSdk: any) => {

  const clientGameComp = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
  const gameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameComp.current_game_id)]));
  const gameComponent = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameComp.current_game_id)]));

  let phase = 2;

  if (gameComponent.start_block_number + gameComponent.preparation_phase_interval > blockCount!) {
    phase = 1;
  }
  else {
    phase = 2;
  }

  setClientGameComponent(phase, clientGameComp.current_game_id, blockCount!,clientComponents,contractComponents, address);

  const entityEdge: any = await getGameEntitiesSpecific(graphSdk, decimalToHexadecimal(clientGameComp.current_game_id));

  const revenantCount = entityEdge.node.models[1].revenant_count;
  const outpostCount = entityEdge.node.models[1].outpost_count;
  const eventCount = entityEdge.node.models[1].event_count;

  if (revenantCount > gameEntityCounter.revenant_count || outpostCount > gameEntityCounter.outpost_count) {

    for (let index = gameEntityCounter.revenant_count + 1; index < revenantCount + 1; index++) {

      callOutpostUpdate(graphSdk, clientGameComp.current_game_id, index,address, contractComponents, clientComponents);

    }
  }

  const balanceGrapqhql = await getReinforcementSpecific(graphSdk, decimalToHexadecimal(clientGameComp.current_game_id), address);
  

  if (balanceGrapqhql !== undefined) {
    setComponentFromGraphQLEntity(contractComponents, balanceGrapqhql.edges[0]);
  }


  loadEvents(graphSdk, decimalToHexadecimal(clientGameComp.current_game_id), eventCount, contractComponents);

  setComponentFromGraphQLEntity(contractComponents, entityEdge);
}

export const callOutpostUpdate = async (graphSdk: any, game_id: number, entity_id: number,address:string, contractComponents: any, clientComponents: any) => {

  const entity: any = await getOutpostEntitySpecific(graphSdk, decimalToHexadecimal(game_id), decimalToHexadecimal(entity_id));
  
  const owner = entity.edges[0].node.models[0].owner;
  const key = +entity.edges[0].node.models[0].entity_id;

  let owned = false;

  if (owner === address ) { owned = true; }

  const oldData = getComponentValue(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(game_id),BigInt(key)]));
  
  if (oldData === undefined) {

    setOutpostClientComponent(key, owned, false, false, true, clientComponents);
  }
  else
  {
    setOutpostClientComponent(key, owned, oldData.event_effected, oldData.disabled, oldData.visible, clientComponents);
  }

  setComponentFromGraphQLEntity(contractComponents, entity.edges[0]);
}

const loadEvents = async (graphSdk: any, game_id: string, event_amount: number, contractComponents: any) => {

  const data = await getFullEventGameData(graphSdk, game_id, event_amount);

  for (let index = 0; index < data.length; index++) {
    const element = data[index];

    setComponentFromGraphQLEntity(contractComponents, element);
  }
}

