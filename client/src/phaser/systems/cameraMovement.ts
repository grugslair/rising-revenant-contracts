
import { COLOUMNS_NUMBER,  SCALE, compareAdjacentIndexes,  getAdjacentIndexesAllDirections, getEntityArrayAtIndex, getMoveDirection, getTileIndex } from "../constants";

import { PhaserLayer } from "..";


import {
  defineSystem,
  Has,
  getComponentValue,
  getComponentValueStrict,
  EntityIndex,
  getEntitiesWithValue,
} from "@latticexyz/recs";
import { setComponentQuick, setOutpostClientComponent } from "../../dojo/testCalls";

export const cameraManager = (layer: PhaserLayer) => {
  const {
    world,
    scenes: {
      Main: { camera, objectPool },
    },
    networkLayer: {
      network: { clientComponents},
      components: { ClientCameraPosition,  ClientOutpostData,ClientGameData },
    },
  } = layer;

  defineSystem(world, [Has(ClientCameraPosition)], ({ entity }) => {
    const newCamPos = getComponentValue(ClientCameraPosition, entity);    //get the cam entity

    const clientGameData = getComponentValue(ClientGameData, entity);

    if (!newCamPos || !clientGameData) {   //check if its true
      console.log("there is a failure")
      return;
    }

    if (newCamPos) {
      camera.centerOn(newCamPos.x, newCamPos.y);   //set the position of the camera
    }

    const index = getTileIndex(newCamPos.x, newCamPos.y);  //get the index of the tile where the cam is 

    //therefore new index
    if (newCamPos.tile_index !== index) {    //if a new index then set the new outpost

      setComponentQuick({
        "x": newCamPos.x,
        "y": newCamPos.y,
        "tile_index": index,
      }, ["0x1"], "ClientCameraPosition", clientComponents)

      const direction = getMoveDirection(newCamPos.tile_index, index);  //get the direction it went

      if (direction !== null) {  // if the change was by one then normal way   //this is to change to a better way

        const oldAdjacent = getAdjacentIndexesAllDirections(newCamPos.tile_index, 1);
        const newAdjacent = getAdjacentIndexesAllDirections(index, 1);

        const data = compareAdjacentIndexes(oldAdjacent, newAdjacent);

        for (const index of data.newAdjacent) {
          const entityArray = getEntityArrayAtIndex(index);
          for (const entity of entityArray) {
            const clientData = getComponentValueStrict(ClientOutpostData, entity);
            if (!clientData.selected) {

              setOutpostClientComponent(clientData.id, clientData.owned, clientData.event_effected, clientData.selected, true, clientComponents);
            }
          }
        }

        for (const index of data.removedAdjacent) {
          const entityArray = getEntityArrayAtIndex(index);
          for (const entity of entityArray) {
            const clientData = getComponentValueStrict(ClientOutpostData, entity);
            if (!clientData.selected) {
              setOutpostClientComponent(clientData.id, clientData.owned, clientData.event_effected, clientData.selected, false, clientComponents);
            }
          }
        }
      } 
      else {
        console.log("nuke option")   //else nuke it and start the array again, slower
        nukeOption(newCamPos.tile_index, index);
      }
    }

    const outpostEntities = getEntitiesWithValue(ClientOutpostData, { visible: true});
    const outpostArray = Array.from(outpostEntities);

    for (const entity of outpostArray) {
      spriteTransform(entity, newCamPos);
    }
  });
  

  function nukeOption(originalIndex: number, newIndex: number) {
    const originalIndexAdjacentIndexes = getAdjacentIndexesAllDirections(originalIndex, COLOUMNS_NUMBER);

    // loop through all the adjacent indexes
    for (const index of originalIndexAdjacentIndexes) {
      const entityArray = getEntityArrayAtIndex(index);

      for (const entity of entityArray) {
        const clientData = getComponentValueStrict(ClientOutpostData, entity);
        
        setOutpostClientComponent(clientData.id, clientData.owned, clientData.event_effected, clientData.selected, false, clientComponents);

      }
    }

    const newIndexAdjacentIndexes = getAdjacentIndexesAllDirections(newIndex, COLOUMNS_NUMBER);

    // loop through all the adjacent indexes
    for (const index of newIndexAdjacentIndexes) {
      const entityArray = getEntityArrayAtIndex(index);
      // console.log("this are the ones to delete", entityArray)
      for (const entity of entityArray) {
        const clientData = getComponentValueStrict(ClientOutpostData, entity);

        setOutpostClientComponent(clientData.id, clientData.owned, clientData.event_effected, clientData.selected, true, clientComponents);
      }
    }
  }

  function spriteTransform(outpostEntityValue: EntityIndex, newCamPos: any) {

      const playerObj = objectPool.get(outpostEntityValue, "Sprite");

      playerObj.setComponent({
        id: "texture",
        once: (sprite:any) => {

          //get the disatnce from the center cam to the sprite
          let distanceX = Math.abs(sprite.x - newCamPos.x);  //wtf is this
          let distanceY = Math.abs(sprite.y - newCamPos.y);

          //get the hypothenuse
          let totDistance = Math.sqrt(distanceX * distanceX + distanceY * distanceY); 

          // console.log(totDistance)
          const clientData = getComponentValueStrict(ClientOutpostData, outpostEntityValue);

          // sprite.alpha = 1;
          // sprite.setScale(SCALE);
          let min = 150;
          let max = 600;

          sprite.setScale(SCALE);

          if (totDistance < min || clientData.selected) {
            sprite.alpha = 1;
            // sprite.setScale(SCALE);
          } else if (totDistance > min && totDistance < max) {
            sprite.alpha = 1 - ((totDistance - min) / (max - min));
            // sprite.setScale(SCALE * (1 - ((totDistance - min) / (max - min))));
          } else {
            // sprite.alpha = 0;
            // sprite.setScale(0);
            sprite.setVisible(false);
          }

      }});
  }
}

