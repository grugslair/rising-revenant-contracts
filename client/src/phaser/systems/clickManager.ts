import { PhaserLayer } from "..";

import {
  EntityIndex,
  getComponentValueStrict,
  defineSystem,
  Has,
  getComponentEntities,
  getComponentValue,
  runQuery,
  HasValue,
} from "@latticexyz/recs";

import { setTooltipArray } from "./eventSystems/eventEmitter";
import { OUTPOST_HEIGHT, OUTPOST_WIDTH, SCALE } from "../constants";

// this can be threaded

export const clickManager = (layer: PhaserLayer) => {
  const {
    world,
    scenes: {
      Main: { camera, input },
    },

    networkLayer: {
      network: { clientComponents },
      components: { Outpost, ClientClickPosition },
    },
  } = layer;

  // Click checks for the ui tooltip
  defineSystem(world, [Has(ClientClickPosition)], ({ entity }) => {

    const positionClick = getComponentValue(ClientClickPosition, entity);
    const camPos = getComponentValue(clientComponents.ClientCameraPosition, entity);

    if (camPos === undefined || positionClick === undefined)
    {
      return;
    }

    const outpostArray = Array.from(runQuery([HasValue(clientComponents.ClientOutpostData, { visible: true })]));
    
    let zoomVal: number = 0;

    camera.zoom$.subscribe((zoom) => { zoomVal = zoom; });

    let positionX = positionClick.xFromMiddle + camPos.x;
    let positionY = positionClick.yFromMiddle + camPos.y;
    
    let foundEntity: EntityIndex[] = []; 

    for (const outpostEntityValue of outpostArray) {

      const outpostData = getComponentValueStrict(Outpost, outpostEntityValue);

      const minX = outpostData.x - 512 * SCALE;
      const minY = outpostData.y - 512 * SCALE;
      const maxX = outpostData.x + 512 * SCALE;
      const maxY = outpostData.y + 512 * SCALE;

      if (
        positionX >= minX &&
        positionX <= maxX &&
        positionY >= minY &&
        positionY <= maxY
      ) {
        foundEntity.push(outpostEntityValue);
      }
    }

    if (foundEntity.length > 0) {
      setTooltipArray.emit("setToolTipArray", foundEntity);
    }
  });

};