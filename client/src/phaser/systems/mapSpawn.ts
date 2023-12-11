import {
  Has,
  defineEnterSystem,
  defineSystem,
  getComponentValueStrict
} from "@latticexyz/recs";
import { PhaserLayer } from "..";

import { Assets, GAME_CONFIG} from "../constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { drawPhaserLayer } from "./eventSystems/eventEmitter";

export const mapSpawn = (layer: PhaserLayer) => {
  const {
    world,
    scenes: {
      Main: { objectPool, camera },
    },
    networkLayer: {
      components: { Game, ClientGameData },
    },
  } = layer;

  defineEnterSystem(world, [Has(Game)], ({ entity }) => {
    const mapObj = objectPool.get(entity, "Sprite");
      
    mapObj.setComponent({
      id: "animation",
      once: (sprite:any) => {
        sprite.setTexture(Assets.MapPicture);
        sprite.depth = -2;
        camera.phaserCamera.setBounds(0, 0, sprite.width, sprite.height);
        camera.centerOn(sprite.width / 2, sprite.height / 2);
      },
    });
  });


  //HERE HIGH PRIO THE MAP DOES NOT SHOW ON FIREFOX BECAUSE OF A WEBGL THING BUT EVERYTHING ELSE DOES?

  defineSystem(world, [Has(ClientGameData)], () => {

    const clientGameData = getComponentValueStrict(ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

    if (clientGameData.current_game_state === 1)
    {
      drawPhaserLayer.emit("toggleVisibility", false);
    }
    else
    {
      drawPhaserLayer.emit("toggleVisibility", true);
    }
  });
};
