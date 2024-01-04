import React, { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { useComponentValue } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";


export const LordsBalanceElement: React.FC = () => {

    const [reinforcementCount, setReinforcementCount] = useState<number>(0);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]));

    useEffect(() => {
        if (playerInfo === undefined) { setReinforcementCount(0); return; }
        setReinforcementCount(Number(playerInfo.player_wallet_amount))
    }, [playerInfo, account])

    return (
        <div className="title-cart-section">
            <h3 style={{ marginRight: "4px" }}>Player Wallet</h3>
            <h1>
                {reinforcementCount}
                <img src="lords_toke_pic.png" className="test-embed" alt="" />
            </h1>
        </div>
    );
};