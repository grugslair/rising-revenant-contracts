import { useEffect, useState } from "react";
import Tooltip from '@mui/material/Tooltip';

import "./ComponentsStyles/TopBarStyles.css";

import {
    Has,
    getComponentValueStrict,
    HasValue,
} from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";
import {  checkAndSetPhaseClientSide, fetchGameData, fetchSpecificEvent, setComponentsFromGraphQlEntitiesHM, truncateString } from "../../utils";
import { ClickWrapper } from "../clickWrapper";

// the main top bar will be used to load in every 10 seconds the game data and display it to the user
// THE THING TO CHECK IS THE IF I GET A COMPONENT CAN I THEN PUT IT AS A VAR IN THE USEFFECT BECAUSE IF I CAN
// I CAN JUST USE THE PAHSE MANAGER AS THE LOADER AND THEN PUT COMPS WITH USEFFECTS EVERYWHERE INSTEAD OF TIMERS

// HERE 

interface TopBarPageProps {
    phaseNum: number;
    setGamePhase?: () => void;
}

export const TopBarComponent: React.FC<TopBarPageProps> = ({ setGamePhase, phaseNum}) => {

    const [isloggedIn, setIsLoggedIn] = useState(true);
    const [inGame, setInGame] = useState(1);

    const [currentNumOfOutposts, setCurrentNumOfOutposts] = useState(0);
    const [maxNumOfOutpost, setMaxNumOfOutpost] = useState(0);

    const [Jackpot, setJackpot] = useState(0);

    const [reinforcementsInGame, setReinforcementsInGame] = useState(0);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents , graphSdk},
            systemCalls: {view_block_count}
        },
    } = useDojo();

    const outpostArray = useEntityQuery([Has(contractComponents.Outpost)]);
    const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);

    const clientGameDataQuery = useEntityQuery([Has(clientComponents.ClientGameData)]);

    useEffect(() => {
        
        if (phaseNum === 1 && setGamePhase !== undefined)
        {
            const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, clientGameDataQuery[0]);
            
            if (clientGameData.current_game_state === 2)
            {
                setGamePhase();
            }
        }

    }, [clientGameDataQuery]);
    
    useEffect(() => {

        const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
        
        if (clientGameData.current_game_state === 2)
        {
          setMaxNumOfOutpost(outpostArray.length);
          setCurrentNumOfOutposts(outpostArray.length - outpostDeadQuery.length)
        }

    }, [outpostDeadQuery]);

    useEffect(() => {
        updateFunctions();
        const intervalId = setInterval(updateFunctions, 5000);
    
        return () => clearInterval(intervalId);
    }, []);
    
    const updateFunctions = () => 
    {   
        checkBlockCount();
        getGameData();
    }

    const getGameData = async () => {
        //this should query the game stuff dependong on the state
        const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
        
        const gameDataQuery = await fetchGameData(graphSdk,clientGameData.current_game_id);
        setComponentsFromGraphQlEntitiesHM(gameDataQuery,contractComponents,false);

        const newGameData = getComponentValueStrict(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));
        setJackpot(newGameData.prize);

        const entityCount  = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

        const latest_loaded_event = clientGameData.current_event_drawn;  
        const latest_onchain_event = entityCount.event_count;    

        const initial_event_index_to_load = latest_onchain_event - latest_loaded_event;

        if (initial_event_index_to_load > 0 )
        {
            for (let i = latest_loaded_event; i <= latest_onchain_event; i++) {
                const eventQuery= await fetchSpecificEvent(graphSdk,clientGameData.current_game_id, i);

                setComponentsFromGraphQlEntitiesHM(eventQuery,contractComponents,false);
            }
        }

        setReinforcementsInGame(entityCount.remain_life_count + entityCount.reinforcement_count);
        //prep phase code only
        if (clientGameData.current_game_state === 1)
        {   
            setMaxNumOfOutpost(2000);
            setCurrentNumOfOutposts(entityCount.outpost_count);
        }
        else
        {
            setCurrentNumOfOutposts(outpostArray.length - outpostDeadQuery.length);
            setMaxNumOfOutpost(outpostArray.length);
        }
    }

    const checkBlockCount = async () => {
        const blockCount = await view_block_count();
        const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([GAME_CONFIG]));
        checkAndSetPhaseClientSide(clientGameData.current_game_id, blockCount!, contractComponents, clientComponents);
    };
  
    return (
        <ClickWrapper className="top-bar-grid-container ">
            <div className="top-bar-grid-game-logo center-via-flex">
                <img src="LOGO_WHITE.png" className="game-logo" style={{ height: "100%", aspectRatio: "1/1" }}></img>
            </div>
            <Tooltip title="this is your overall cut so far...">
                <div className="top-bar-grid-left-text-section center-via-flex">
                    <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                        <div>Jackpot: {Jackpot} $LORDS </div>
                    </div>
                    <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                        <div>Contribution: 12%</div>
                    </div>
                </div>
            </Tooltip>
            <div className="top-bar-grid-right-text-section center-via-flex">
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                    <div>Revenants Alive: {currentNumOfOutposts}/{maxNumOfOutpost}</div>
                </div>
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                    <div>Reinforcements in game: {reinforcementsInGame}</div>
                </div>
            </div>
            <div className="top-bar-grid-game-written-logo">
                <div className="center-via-flex" style={{ height: "100%", width: "100%", backgroundColor: "white", color: "black", borderRadius: "10px", padding: "2px 5px", boxSizing: "border-box" }}>
                    <h2 style={{ fontFamily: "Zelda", fontWeight: "100", fontSize: "2.8vw", whiteSpace: "nowrap" }}>Rising Revenant</h2>
                </div>
            </div>
            <div className="top-bar-grid-address center-via-flex">
                <div style={{ width: "100%", height: "75%" }} className="center-via-flex">
                    {isloggedIn ?
                        <h2 >
                            <img src="argent_logo.png" className="chain-logo"></img>
                            {truncateString("0x7h387yeh78287he7ge2778d827e78gebd", 5)}
                        </h2> :
                        <h3>
                            NOT LOGGED IN
                        </h3>}
                </div>
            </div>
        </ClickWrapper>
    );
};
