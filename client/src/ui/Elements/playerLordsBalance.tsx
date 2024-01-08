import React, { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { useComponentValue } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";

interface LordsBalanceElementProps {
    style?: React.CSSProperties;
}

export const LordsBalanceElement: React.FC<LordsBalanceElementProps> = ({ style }) => {

    const [reinforcementCount, setReinforcementCount] = useState<number>(150);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]));

    useEffect(() => {
        if (playerInfo === undefined) { setReinforcementCount(150); return; }
        setReinforcementCount(Number(playerInfo.player_wallet_amount))
    }, [playerInfo, account])

    return (
        <div className="title-cart-section" style={style}>
            <h2 className="test-h2 no-margin" style={{whiteSpace:"nowrap"}}>
                {reinforcementCount}
                <img src="lords_token_pic.png" className="test-embed" alt="" style={{width:"1.2em", height:"1.2em", marginLeft:"5px"}} />
            </h2>
        </div>
    );
};