
import { SCALE, getAdjacentIndices } from "../constants";

import { PhaserLayer } from "..";

import {
  defineSystem,
  Has,
  Not,
  getComponentValue,
  getComponentValueStrict,
  EntityIndex,
  runQuery,
  HasValue,
  updateComponent,
  getEntitiesWithValue,
  getComponentEntities,
} from "@latticexyz/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { log } from "console";

//too many for loops in this place this all needs to be rewritten
// HERE

export const cameraManager = (layer: PhaserLayer) => {
  const {
    world,
    scenes: {
      Main: { camera, objectPool },
    },
    networkLayer: {
      network: { clientComponents, contractComponents },
    },
  } = layer;

  // this can be threaded

  defineSystem(world, [Has(clientComponents.ClientCameraPosition)], async ({ entity }) => {

    const clientGameData = getComponentValue(clientComponents.ClientGameData, entity);
    const camPos = getComponentValue(clientComponents.ClientCameraPosition, entity);
    const chunkSettings = getComponentValue(clientComponents.ClientChunkSettings, entity);
    const outpostViewSettings = getComponentValue(clientComponents.ClientOutpostViewSettings, entity);

    if (!camPos || !clientGameData) {   //check if its true
      console.log("there is a failure on the cam system movement function")
      return;
    }

    camera.centerOn(camPos.x, camPos.y);
    const entitiesAtTileIndex = Array.from(runQuery([HasValue(clientComponents.ClientOutpostData, { visible: true })]));

    for (let index = 0; index < entitiesAtTileIndex.length; index++) {
      const entityId = entitiesAtTileIndex[index];

      spriteTransform(entityId, camPos, chunkSettings, outpostViewSettings);
    }

  });

  function spriteTransform(outpostEntityValue: EntityIndex, camPos: any, chunkSettings: any, outpostViewSettings: any) {
    const playerObj = objectPool.get(outpostEntityValue, "Sprite");

    playerObj.setComponent({
      id: "texture",
      once: (sprite: any) => {

        const distanceX = Math.abs(sprite.x - camPos.x);
        const distanceY = Math.abs(sprite.y - camPos.y);
        const totDistance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

        const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, outpostEntityValue);
        const outpostContractData = getComponentValueStrict(contractComponents.Outpost, outpostEntityValue);

        const min: number = chunkSettings.view_range_min;
        const max: number = chunkSettings.view_range_max;

        // this is vile this needs to be cleaned

        if (outpostClientData.selected) {
          sprite.alpha = 1;
          sprite.setScale(SCALE);
        }
        else {
          if (outpostContractData.lifes === 0 && outpostViewSettings.hide_dead_ones) {
            sprite.alpha = 0;
            sprite.setScale(0);
            sprite.setVisible(false);
          }
          else if (outpostClientData.owned && outpostViewSettings.show_your_everywhere) {
            sprite.alpha = 1;
            sprite.setScale(SCALE);
          }
          else if (!outpostClientData.owned && outpostViewSettings.hide_others_outposts) {
            sprite.alpha = 0;
            sprite.setScale(0);
            sprite.setVisible(false);
          }
          else {
            if (totDistance < min) {
              sprite.alpha = 1;
              sprite.setScale(SCALE);
            } else if (totDistance > min && totDistance < max) {
              sprite.alpha = 1 - ((totDistance - min) / (max - min));
              sprite.setScale(SCALE * (1 - ((totDistance - min) / (max - min))));
            } else {
              sprite.alpha = 0;
              sprite.setScale(0);
              sprite.setVisible(false);
            }
          }
        }
      }
    });
  }


  // we need an array of outpost types so that would mean making another array which tbf we already do then loop this array on return

  // function sortByDistance(arr: { x: number; y: number }[], targetX: number, targetY: number): { x: number; y: number }[] {
  //   // Calculate distances and sort the array based on distance
  //   const sortedArray = arr.sort((a, b) => {
  //     const distanceA = Math.sqrt(Math.pow(a.x - targetX, 2) + Math.pow(a.y - targetY, 2));
  //     const distanceB = Math.sqrt(Math.pow(b.x - targetX, 2) + Math.pow(b.y - targetY, 2));
  //     return distanceA - distanceB;
  //   });

  //   return sortedArray;
  // }


  // this can be threaded
  // could use has camere but that would update this everytime for the cam too and we dont want that so for now its ok 

  // we need to NOT keyword
  defineSystem(world, [Has(clientComponents.EntityTileIndex)], ({ entity }) => {
    const camIndex = getComponentValue(clientComponents.EntityTileIndex, entity);
    const clientGameData = getComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const outpostViewSettings = getComponentValue(clientComponents.ClientOutpostViewSettings, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    if (entity !== getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)])) {
      return;
    }

    if (!camIndex || !clientGameData || entity !== getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)])) {
      console.error("there is a failure in the cam system for index")
      return;
    }

    const camTileIndex = camIndex.tile_index;

    const adjecentData = getAdjacentIndices(camTileIndex);

    const visibleOutposts = getEntitiesWithValue(clientComponents.ClientOutpostData, { visible: true });
    const selectedOutpost = getEntitiesWithValue(clientComponents.ClientOutpostData, { selected: true });

    let arrOfEntitiesInIndexes: any = [];
    for (let index = 0; index < adjecentData.length; index++) {
      const tileIndex = adjecentData[index];

      // const entitiesAtTileIndex = getEntitiesWithValue(clientComponents.EntityTileIndex, { tile_index: tileIndex });
      const entitiesAtTileIndex = Array.from(runQuery([HasValue(clientComponents.EntityTileIndex, { tile_index: tileIndex }), Not(clientComponents.ClientCameraPosition)]));
      //leave it with runQuery for now but look into getents with val

      arrOfEntitiesInIndexes = arrOfEntitiesInIndexes.concat(entitiesAtTileIndex);
    }
    const mergedEntities = [...new Set([...arrOfEntitiesInIndexes, ...visibleOutposts, ...selectedOutpost])];

    for (let index = 0; index < mergedEntities.length; index++) {

      const entityId = mergedEntities[index];

      const indexOfEntity = getComponentValueStrict(clientComponents.EntityTileIndex, entityId);
      const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
      const contractOutpostData = getComponentValueStrict(contractComponents.Outpost, entityId);

      if (selectedOutpost.length > 0) {
        if (selectedOutpost[0] === entityId) {
          continue;
        }
      }

      // this is also messy af
      if (contractOutpostData.lifes === 0 && outpostViewSettings.hide_dead_ones) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: false })
      }
      else if (clientOutpostData.owned && outpostViewSettings.show_your_everywhere) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: true })
      }
      else if (!clientOutpostData.owned && outpostViewSettings.hide_others_outposts) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: false })
      }
      else {
        if (adjecentData.includes(indexOfEntity.tile_index)) {
          updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: true })
        }
        else {
          updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: false })
        }
      }
    }
  });












  defineSystem(world, [Has(clientComponents.ClientOutpostViewSettings)], ({ entity }) => {

    const settings = getComponentValue(clientComponents.ClientOutpostViewSettings, entity);
    const clientGameData = getComponentValue(clientComponents.ClientGameData, entity);

    if (settings === undefined || clientGameData === undefined){return;}

    const outpostEntitiesAll = getComponentEntities(contractComponents.Outpost);
    const outpostArray = Array.from(outpostEntitiesAll);

    if (outpostArray.length === 0) {return;}

    for (let index = 0; index < outpostArray.length; index++) {
      const entityId = outpostArray[index];

      const contractOutpostData = getComponentValueStrict(contractComponents.Outpost, entityId);
      const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);

      if (contractOutpostData.lifes === 0 && settings.hide_dead_ones) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: false })
      }
      else if (clientOutpostData.owned && settings.show_your_everywhere) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: true })
      }
      else if (!clientOutpostData.owned && settings.hide_others_outposts) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(clientOutpostData.id)]), { visible: false })
      }
    }
  });
}