import {
  Has,
  defineEnterSystem
} from "@latticexyz/recs";
import { PhaserLayer } from "..";

import { Assets} from "../constants";

export const mapSpawn = (layer: PhaserLayer) => {
  const {
    world,
    scenes: {
      Main: { objectPool, camera },
    },
    networkLayer: {
      components: { Game },
    },
  } = layer;

  defineEnterSystem(world, [Has(Game)], ({ entity }) => {
    const mapObj = objectPool.get(entity, "Sprite");
    
    console.error("eoifhewwuirheuiqwhnqwfubqwufaebfdsbjk")
      
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

  // defineSystem(world, [Has(ClientGameData)], ({ entity }) => {

  //   const clientGameData = getComponentValueStrict(ClientGameData, decimalToHexadecimal(GAME_CONFIG));

  //   console.error("THIS IS THE CURRENT GAME STATE", clientGameData);


  //   drawPhaserLayer.emit("toggleVisibility", true);

  //   // if (clientGameData.current_game_state === 1)
  //   // {
  //   //   drawPhaserLayer.emit("toggleVisibility", false);
  //   // }
  //   // else
  //   // {
  //   //   drawPhaserLayer.emit("toggleVisibility", true);
  //   // }
  // });
};
