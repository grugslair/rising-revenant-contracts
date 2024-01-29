import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GameEntityCounter } from "../../../generated/graphql";
import { useDojo } from "../../../hooks/useDojo";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";

import { useComponentValue, useEntityQuery } from '@latticexyz/react';
import { getComponentValueStrict,HasValue } from "@latticexyz/recs";

export const SpecificPlayerLookUP: React.FC = () => {

    const {
        networkLayer: {
            network: { clientComponents, contractComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    return (
        <div style={{ height: "90%", width: "95%", marginLeft: "2.5%", display: "grid"}}>
           
        </div>
    )
}

