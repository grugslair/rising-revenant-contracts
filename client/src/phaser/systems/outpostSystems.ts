import {
  defineSystem,
  Has,
  Not,
  getComponentValue,
  getComponentValueStrict,
  EntityIndex,
  runQuery,
  HasValue,
  setComponent,
  updateComponent,
  defineEnterSystem,
  getEntitiesWithValue,
  getComponentEntities
} from "@latticexyz/recs";
import { PhaserLayer } from "..";
import { Assets, SCALE, getAdjacentIndices, getTileIndex } from "../constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";

export const spawnOutposts = (layer: PhaserLayer) => {

  const {
    world,
    scenes: {
      Main: { objectPool },
    },
    networkLayer: {
      network: { contractComponents, clientComponents },
    },
  } = layer;

  defineEnterSystem(world, [Has(clientComponents.ClientOutpostData)], ({ entity }) => {
    const outpostData: any = getComponentValueStrict(contractComponents.Outpost, entity);

    setComponent(clientComponents.EntityTileIndex, entity,
      {
        tile_index: getTileIndex(outpostData.x - (150 * SCALE), outpostData.y- (150 * SCALE))
      }
    )

    const outpostObj = objectPool.get(entity, "Sprite");

    outpostObj.setComponent({
      id: "position",
      once: (sprite: any) => {
        sprite.setPosition(outpostData.x - (150 * SCALE) , outpostData.y - (150 * SCALE));
        sprite.setScale(0);
        sprite.setVisible(false);
      },
    });
  });

  defineSystem(world, [Has(clientComponents.ClientOutpostData)], ({ entity }) => {

    const outpostDojoData = getComponentValueStrict(contractComponents.Outpost, entity);
    const outpostClientData = getComponentValue(clientComponents.ClientOutpostData, entity);

    if (outpostClientData === undefined) { return }

    const outpostObj = objectPool.get(entity, "Sprite");

    outpostObj.setComponent({
      id: "texture",
      once: (sprite: any) => {
        if (outpostClientData.visible === false && !outpostClientData.selected) {
          sprite.setVisible(false);
        }
        else {
          sprite.setVisible(true);
          if (outpostClientData.selected) {
            sprite.setTexture(Assets.CaslteSelectedAsset);
            sprite.depth = 3;
          }
          else {
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
        }
      },
    });
  });

  defineSystem(world, [Has(clientComponents.ClientOutpostViewSettings)], ({ entity }) => {
    const outpostViewSettings = getComponentValue(clientComponents.ClientOutpostViewSettings, entity);
    const clientGameData = getComponentValue(clientComponents.ClientGameData, entity);

    const allOutposts = getComponentEntities(clientComponents.ClientOutpostData);

    for (let index = 0; index < allOutposts.length; index++) {

      const entityId = allOutposts[index];

      const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
      const contractOutpostData = getComponentValueStrict(contractComponents.Outpost, entityId);

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
    }
  });
};