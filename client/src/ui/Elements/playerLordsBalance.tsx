import React, { useEffect, useState } from "react";
import { getComponentValueStrict } from "@latticexyz/recs";

import { useComponentValue } from "@latticexyz/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";

interface LordsBalanceElementProps {
    contractComponents: any;
    clientComponents:any;
    account: any;
    style?: React.CSSProperties;
}

export const LordsBalanceElement: React.FC<LordsBalanceElementProps> = ({ style,contractComponents,clientComponents,account }) => {

    const [reinforcementCount, setReinforcementCount] = useState<number>(150);

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
                <img src="Icons/lords_token_pic.png" className="test-embed" alt="" style={{width:"1.2em", height:"1.2em", marginLeft:"5px"}} />
            </h2>
        </div>
    );
};