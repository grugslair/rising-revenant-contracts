declare var Phaser: any


import {
    Has,
    defineSystem,
    getComponentValueStrict, getComponentValue,
    getComponentEntities,
  } from "@latticexyz/recs";
  import { PhaserLayer } from "..";
  import { GAME_CONFIG } from "../constants";
import {  setOutpostClientComponent } from "../../dojo/testCalls";
import { getEntityIdFromKeys } from "@dojoengine/utils";

  export const eventManager = (layer: PhaserLayer) => {
    const {
      world,
      networkLayer: {
        network: { clientComponents },
        components: { Outpost, WorldEvent, ClientOutpostData , GameEntityCounter, ClientGameData},
      },
    } = layer;
  
    defineSystem(world, [Has(WorldEvent)], ({ entity }) => {

        

      const dataEvent = getComponentValue(WorldEvent, entity);
      const clientGameData = getComponentValue(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

      if (!dataEvent || !clientGameData) {  // this doesnt make sense
        return;
      }

      const phaserScene = layer.scenes.Main.phaserScene;

      // Destroy all graphics objects in the scene
      phaserScene.sys.displayList.each((child) => {
        if (child instanceof Phaser.GameObjects.Graphics) {
            child.destroy();
        }
      });

      const graphics = phaserScene.add.graphics();

      graphics.lineStyle(3, 0xff0000); // Set line style for the outline
      graphics.strokeCircle(dataEvent.x, dataEvent.y, dataEvent.radius); // Draw the outline of a circle with a radius of 50

      let radius = dataEvent.radius;
  
      if (radius === 0) {  // this also makes no sense
        return;
      }
  
      let positionX = dataEvent.x;
      let positionY = dataEvent.y;
  
      const outpostEntities = getComponentEntities(Outpost);
      const outpostArray = Array.from(outpostEntities);

      const gameEntityCounter = getComponentValueStrict(GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));
  
      for (const outpostEntityValue of outpostArray) {

        const outpostClientData = getComponentValueStrict(ClientOutpostData, outpostEntityValue);
        const outpostEntityData = getComponentValueStrict(Outpost, outpostEntityValue);

        if (outpostEntityData.last_affect_event_id >= gameEntityCounter.event_count)
        {
          setOutpostClientComponent(outpostClientData.id, outpostClientData.owned, false, outpostClientData.selected, outpostClientData.visible, clientComponents ) 
        
          continue;
        }

        const distance = Math.sqrt(
          (Number(outpostEntityData.x) - positionX) ** 2 + (Number(outpostEntityData.y)- positionY) ** 2
        );

        if (distance <= radius) {
          setOutpostClientComponent(outpostClientData.id, outpostClientData.owned, true, outpostClientData.selected, outpostClientData.visible, clientComponents ) 
        }
        else 
        {
          setOutpostClientComponent(outpostClientData.id, outpostClientData.owned, false, outpostClientData.selected, outpostClientData.visible, clientComponents ) 
        }
      }
    });
  };
  