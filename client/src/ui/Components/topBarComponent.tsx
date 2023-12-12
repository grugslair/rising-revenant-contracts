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
                        <h4>Revenants Alive: {currentNumOfOutposts}/{maxNumOfOutpost}</h4>
                        <h4>Reinforcements in game: {reinforcementsInGame}</h4>
                    </div>

                    {isloggedIn ? 
                        <h3 onMouseDown={() => {}} style={{fontSize:"1cqw"}}> <img src="argent_logo.png" className="chain-logo" style={{fontSize:"1cqw"}}></img>{truncateString(account.address, 5)} 
                    </h3> : <button>Log in now</button>}
                    
                </ClickWrapper>
            </div>
        </div>
    );
};
