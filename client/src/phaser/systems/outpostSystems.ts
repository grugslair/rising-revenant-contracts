import {
  Has,
  defineSystem,
  getComponentValueStrict,
  getComponentValue,
  defineEnterSystem,
  defineEnterQuery,
  setComponent,
} from "@latticexyz/recs";
import { PhaserLayer } from "..";
import { Assets, SCALE, getAdjacentIndices, getTileIndex, setWidthAndHeight } from "../constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { Outpost } from "../../generated/graphql";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { turnBigIntToAddress } from "../../utils";
import { useDojo } from "../../hooks/useDojo";

export const spawnOutposts = (layer: PhaserLayer) => {

  const {
    world,
    
    scenes: {
      Main: { objectPool },
    },
  } = layer;

  const {
    account: { account },
    networkLayer: {
      network: { contractComponents, clientComponents },
    },
  } = useDojo();


  defineEnterSystem(world, [Has(clientComponents.ClientOutpostData)], ({ entity }) => {
    const outpostData: any = getComponentValueStrict(contractComponents.Outpost, entity);

    let owned = false;

    if (turnBigIntToAddress(outpostData.owner) === account.address) {
      owned = true;
    }

    setComponent(clientComponents.ClientOutpostData, entity,
      {
        id: Number(outpostData.entity_id),
        owned: owned,
        event_effected: false,
        selected: false,
        visible: false
      }
    )
    setComponent(clientComponents.EntityTileIndex, entity,
      {
        tile_index: getTileIndex(outpostData.x, outpostData.y)
      }
    )


    const outpostObj = objectPool.get(entity, "Sprite");

    outpostObj.setComponent({
      id: "position",
      once: (sprite: any) => {
        sprite.setPosition(outpostData.x - (sprite.width * SCALE) / 2, outpostData.y - (sprite.height * SCALE) / 2);
      },
    });




  });


  defineSystem(world, [Has(ClientOutpostData)], ({ entity }) => {

    const outpostDojoData = getComponentValueStrict(Outpost, entity);
    const outpostClientData = getComponentValue(ClientOutpostData, entity);

    if (outpostClientData === undefined) { return }

    const outpostObj = objectPool.get(entity, "Sprite");

    outpostObj.setComponent({
      id: "texture",
      once: (sprite: any) => {

        if (outpostClientData.selected) {
          sprite.setTexture(Assets.CaslteSelectedAsset);
          sprite.depth = 3;
        }
        else {
          sprite.setVisible(true);

          if (outpostDojoData.lifes <= 0) {
            sprite.setTexture(Assets.CastleDestroyedAsset);
            sprite.depth = 1;
          }
          else {
            if (!outpostClientData.event_effected) {
              if (outpostClientData.owned) {
                sprite.setTexture(Assets.CastleHealthySelfAsset);
                sprite.depth = 3;

              } else {
                sprite.setTexture(Assets.CastleHealthyEnemyAsset);
                sprite.depth = 2;

              }
            }
            else {
              sprite.setTexture(Assets.CastleDamagedAsset);
              sprite.depth = 3;
            }
          }
        }

        if (outpostClientData.visible === false) {
          sprite.setVisible(false);
        }

        setWidthAndHeight(sprite.width * SCALE, sprite.height * SCALE);
      },
    });

    // const nameObj = objectPool.get("text_" + entity, "Text")
    // nameObj.setComponent({
    //   id: 'position',
    //   once: (text) => {
    //     if (outpostClientData.visible === false) {
    //       text.setVisible(false);
    //     } else {
    //       text.setVisible(true);
    //       text.setPosition(outpostDojoData?.x, outpostDojoData?.y - 14);
    //       text.setBackgroundColor("rgba(1,1,1,1)")
    //       text.setFontSize(24)
    //       text.depth = 5;
    //       text.setText("Your Text Here"); // Replace "Your Text Here" with the actual text you want to display

    //       // Create a graphics object for the tooltip background
    //       const graphics = text.scene.add.graphics();
    //       graphics.fillStyle(0x000000, 1); // Tooltip background color
    //       graphics.fillRoundedRect(0, 0, text.width + 20, text.height + 20, 10); // Rounded rectangle for the tooltip

    //       // Create a teardrop shape for the arrow
    //       const arrowWidth = 20;
    //       const arrowHeight = 10;
    //       const arrowX = (text.width + 20 - arrowWidth) / 2;
    //       const arrowY = text.height + 10;
    //       graphics.beginPath();
    //       graphics.moveTo(arrowX, arrowY);
    //       graphics.lineTo(arrowX + arrowWidth / 2, arrowY + arrowHeight);
    //       graphics.lineTo(arrowX + arrowWidth, arrowY);
    //       graphics.closePath();
    //       graphics.fillPath();

    //       // Set the tooltip background as the mask for the text
    //       text.setMask(graphics.createGeometryMask());

    //       // Add the graphics to the same depth as the text
    //       graphics.setDepth(5);
    //     }
    //   }
    // });

  });


  // not too sure what this is doing
  defineSystem(world, [Has(ClientOutpostData)], ({ entity }) => {
    const outpostClientData = getComponentValue(ClientOutpostData, entity);
    const entityTileIndex = getComponentValue(EntityTileIndex, entity);

    if (outpostClientData === undefined || entityTileIndex === undefined) { return }

    const cameraTileIndex = getComponentValueStrict(EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const outpostObj = objectPool.get(entity, "Sprite");

    outpostObj.setComponent({
      id: "texture",
      once: (sprite: any) => {

        const adj = getAdjacentIndices(cameraTileIndex.tile_index)

        if (!outpostClientData.selected && !adj.includes(entityTileIndex.tile_index)) {
          sprite.setVisible(false);
        }
      },
    });
  });
};