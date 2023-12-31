import React, { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { useComponentValue } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";


export const ReinforcementCountElement: React.FC = () => {

    const [reinforcementCount, setReinforcementCount] = useState<number>(0);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents,clientComponents }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]));

    useEffect(() => {
        if (playerInfo === undefined) { setReinforcementCount(0); return;}
        setReinforcementCount(playerInfo.reinforcement_count)
    }, [playerInfo])

    //HERE bring styles here

    return (
        <div className="title-cart-section">
            <h1>
                <img src="reinforcements_logo.png" className="test-embed" alt="" />
                {reinforcementCount}
            </h1>
            <h3>Reinforcement available</h3>
        </div>
    );
};