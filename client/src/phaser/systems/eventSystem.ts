declare var Phaser: any

import {
  Has,
  defineSystem,
  getComponentValueStrict, getComponentValue,
  getComponentEntities,
  updateComponent
} from "@latticexyz/recs";
import { PhaserLayer } from "..";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";

export const eventManager = (layer: PhaserLayer) => {
  const {
    world,
    networkLayer: {
      network: { clientComponents, contractComponents },
    },
  } = layer;

  defineSystem(world, [Has(contractComponents.GameEntityCounter)], ({ entity }) => {

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const game_id = clientGameData.current_game_id;
    const gameEntityCounter = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(game_id)]));

    if (gameEntityCounter.event_count === clientGameData.current_event_drawn) { return; }

    if (gameEntityCounter.event_count <= 0) { return; }

    // this should be the last event that is always fetched
    const dataEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(game_id), BigInt(gameEntityCounter.event_count)]))

    if (dataEvent === null || dataEvent === undefined) { return; }

    updateComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { current_event_drawn: Number(dataEvent.entity_id) });

    const phaserScene = layer.scenes.Main.phaserScene;
    // Destroy all graphics objects in the scene
    phaserScene.sys.displayList.each((child) => {
      if (child instanceof Phaser.GameObjects.Graphics) {
        child.destroy();
      }
    });
 

    createCircleOfTriangles(phaserScene, dataEvent.x , dataEvent.y , dataEvent.radius, 30);

    const outpostEntities = getComponentEntities(contractComponents.Outpost);
    const outpostArray = Array.from(outpostEntities);
    // this can be indexed

    for (const outpostEntityValue of outpostArray) {

      const outpostClientData = getComponentValueStrict(clientComponents.ClientOutpostData, outpostEntityValue);
      const outpostEntityData = getComponentValueStrict(contractComponents.Outpost, outpostEntityValue);

      if (outpostEntityData.last_affect_event_id >= gameEntityCounter.event_count) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(outpostClientData.id)]), { event_effected: false })
        continue;
      }

      const distance = Math.sqrt(
        (Number(outpostEntityData.x) - dataEvent.x) ** 2 + (Number(outpostEntityData.y ) - dataEvent.y ) ** 2
      );

      if (distance <= dataEvent.radius) {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(outpostClientData.id)]), { event_effected: true })
      }
      else {
        updateComponent(clientComponents.ClientOutpostData, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(outpostClientData.id)]), { event_effected: false })
      }
    }
  });

  // function destroyGraphicsInContainer(container) {
  //   container.each(function (child) {
  //     if (child instanceof Phaser.GameObjects.Graphics) {
  //       child.destroy();
  //     }
  //   });
  // }

  function createCircleOfTriangles(scene: any, centerX: number, centerY: number, radius: number, numTriangles: number) {
    
    var graphics = scene.add.graphics();

    var angleIncrement = (2 * Math.PI) / numTriangles;

    for (var i = 0; i < numTriangles; i++) {
      var angle = i * angleIncrement;
      var x1 = centerX + radius * Math.cos(angle);
      var y1 = centerY + radius * Math.sin(angle);

      var x2 = centerX + radius * Math.cos(angle + angleIncrement);
      var y2 = centerY + radius * Math.sin(angle + angleIncrement);

      var x3 = centerX;
      var y3 = centerY;

      graphics.fillStyle(0xff0000, 1);
      graphics.fillGradientStyle(0xff0000, 0xff0000, 0xff0000, 0x000000, 1, 0.05, 0.05, 0);

      graphics.beginPath();
      graphics.moveTo(x1, y1);
      graphics.lineTo(x2, y2);
      graphics.lineTo(x3, y3);
      graphics.closePath();
      graphics.fillPath();

      graphics.setDepth(-1);
    }

    scene.tweens.add({
      targets: graphics,
      alpha: 0.5,
      duration: 3000,
      yoyo: true,
      repeat: -1 
    });
  }
};