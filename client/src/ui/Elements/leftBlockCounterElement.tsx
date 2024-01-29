import React, { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { ClickWrapper } from "../clickWrapper";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useComponentValue } from "@latticexyz/react";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { convertBlockCountToTime } from "../../utils";

export interface blockDataTypes {
    numberValue: number;
    stringValue: string;
}

export function useLeftBlockCounter() {
    const [blocksLeftData, setData] = useState<blockDataTypes>({ numberValue: -1, stringValue: "DD: -1 HH: -1 MM: -1 SS: -1" });

    const {
        networkLayer: {
            network: { clientComponents, contractComponents }
        },
    } = useDojo();

    const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const gameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id)]));

    useEffect(() => {
        const blocksLeft = (gameData.start_block_number + gameData.preparation_phase_interval) - clientGameData!.current_block_number!;

        setData({numberValue: blocksLeft, stringValue: convertBlockCountToTime(blocksLeft)});
    }, [clientGameData]);

    // Your custom hook can return whatever values or functions you need
    return {
        blocksLeftData,
    };
}

