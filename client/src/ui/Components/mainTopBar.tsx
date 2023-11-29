import { useEffect, useState } from "react";

import "./ComponentsStyles/TopBarStyles.css";

import {
    Has,
    getComponentValue,
    getComponentValueStrict,
    HasValue,
} from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";
import {  truncateString } from "../../utils";
import { ClickWrapper } from "../clickWrapper";


export const TopBarComponent = () => {
    const [isloggedIn, setIsLoggedIn] = useState(true);
    const [inGame, setInGame] = useState(1);

    const [numberOfRevenants, setNumberOfRevenants] = useState(0);
    const [Jackpot, setJackpot] = useState(2000);

    const [playerReinforcementNumber, setPlayerReinforcementNumber] = useState(0);
    const [userAddress, setUserAddress] = useState("0xet132876472387126367126737uqe877dy87e7t");

    const [reinforcementsInGame, setReinforcementsInGame] = useState(0);

    const [Number, setNumber] = useState(0);


    // const {
    //     account: { account },
    //     networkLayer: {
    //         network: { contractComponents, clientComponents },
    //         systemCalls: {view_block_count}
    //     },
    // } = useDojo();

    // const outpostArray = useEntityQuery([Has(contractComponents.Outpost)]);
    // const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
    // const clientGameData = useEntityQuery([Has(clientComponents.ClientGameData)]);

    // const entityCounterArr = useEntityQuery([Has(contractComponents.GameEntityCounter)]);
    

    // useEffect(() => {

    //     const gameClientData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

    //     setInGame(gameClientData.current_game_state);

    //     const gameData = getComponentValue(contractComponents.Game, getEntityIdFromKeys([BigInt(gameClientData.current_game_id)]));
    //     const balance = getComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(gameClientData.current_game_id), BigInt(account.address)]));

    //     if (gameData === undefined) {
    //         return;
    //     }
    //     setJackpot(gameData.prize);
    //     setInGame(gameClientData.current_game_state);

    //     setNumberOfRevenants(outpostArray.length);

    //     if (balance === undefined) {
    //         setPlayerReinforcementNumber(0);
    //     }
    //     else {
    //         setPlayerReinforcementNumber(balance.reinforcement_count);
    //     }

    //     setUserAddress(account.address);

    //     if (inGame === 2) {
    //         setNumberOfRevenants(outpostArray.length - outpostDeadQuery.length);
    //     }
    //     else
    //     {
    //         setNumberOfRevenants(outpostArray.length);
    //     }

    // }, [outpostArray, clientGameData, account]);

    
    // useEffect(() => {
        
    //     if (entityCounterArr.length !== 0)
    //     {
    //         const reinforcementInGame = getComponentValueStrict(contractComponents.GameEntityCounter, entityCounterArr[0])

    //         setReinforcementsInGame(reinforcementInGame.reinforcement_count + reinforcementInGame.remain_life_count);
    //     }
        
    // }, [entityCounterArr, account]);
    



    // useEffect(() => {
    //     const intervalId = setInterval(async () => {
    //      const num =  await view_block_count();

    //         setNumber(num!)

    //     }, 5000);
    
    //     return () => {
    //       clearInterval(intervalId);
    //     };
    //   }, []);
  
    return (
        <div className="top-bar-container-layout">
            <div style={{ width: "100%", height: "30%" }}></div>
            <div className="top-bar-content-section">
                <div className="left-section">
                    <div className="left-section-image-div">
                        <div className="logo-img"></div>
                    </div>
                    <div className="text-section">
                        <h4>Jackpot: {Jackpot} $LORDS</h4>
                    </div>
                </div>
                <div className="name-section">
                    <div className="game-title">Rising Revenant</div>
                </div>
                <ClickWrapper className="right-section">
                    <div className="text-section">

                        {/* {inGame === 2 ? <h4>Revenants Alive: {numberOfRevenants}/{outpostArray.length}</h4> : <h4>Revenants Summoned: {outpostArray.length || "0"}/2000</h4>} */}
                        <h4>Revenants Alive: 200/2000</h4>
                        <h4>Reinforcements in game: {reinforcementsInGame}</h4>
                    </div>

                    {isloggedIn ? 
                        <h3 onMouseDown={() => {}}> <img src="LOGO_WHITE.png" className="chain-logo" style={{fontSize:"1cqw"}}></img>{truncateString(userAddress, 5)} 
                            
                    </h3> : <button>Log in now</button>}
                    
                </ClickWrapper>
            </div>
        </div>
    );
};
