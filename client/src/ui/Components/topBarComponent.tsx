//Libs
import { useEffect, useState } from "react";
import {
    Has,
    getComponentValueStrict,
    HasValue,
    getComponentValue,
    updateComponent
} from "@latticexyz/recs";
import { useEntityQuery, useComponentValue } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { checkAndSetPhaseClientSide, fetchGameData, fetchPlayerInfo, fetchSpecificEvent, fetchSpecificOutRevData, setComponentsFromGraphQlEntitiesHM, truncateString } from "../../utils";
import { ClickWrapper } from "../clickWrapper";
import { GAME_CONFIG_ID, getRefreshOwnOutpostDataTimer } from "../../utils/settingsConstants";

//styles
import "./ComponentsStyles/TopBarStyles.css";

//Comps
import Tooltip from '@mui/material/Tooltip';
import { toast } from "react-toastify";
import { LordsBalanceElement } from "../Elements/playerLordsBalance";

//Pages



const notify = (message: string) => {
    toast("✅ " + message, {
        position: "top-left",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
    });
}


interface TopBarPageProps {
    phaseNum: number;
    setGamePhase?: () => void;
}

export const TopBarComponent: React.FC<TopBarPageProps> = ({ setGamePhase, phaseNum }) => {

    const [playerContribScore, setPlayerContribScore] = useState(0);
    const [playerContribScorePerc, setPlayerContribScorePerc] = useState(0);
    const [soundOn, setSoundOn] = useState<Boolean>(true);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents, graphSdk },
        },
    } = useDojo();

    const outpostQuery = useEntityQuery([Has(contractComponents.Outpost)]);
    const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
    const ownOutposts = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { event_effected: true })]);

    const clientGameData = useComponentValue(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const gameEntityCounter = useComponentValue(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id)]));
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id), BigInt(account.address)]))
    const gameData = useComponentValue(contractComponents.Game, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id)]));

    useEventAndUserDataLoader();

    // this should only be getting called when the user is active the moment the game switches from prep to game phase as the other oupost from other people are not loaded in 
    // in the prep phase
    
    useEffect(() => {
        if (phaseNum === 1 && setGamePhase !== undefined) {   // this should only be getting called when the phase goes from prep to game
            if (clientGameData!.current_game_state === 2) {
                setGamePhase();
            }
        }
    }, [clientGameData, gameEntityCounter]);

    // on change this should deal with the contribution value change draw
    useEffect(() => {

        if (playerInfo === null || playerInfo === undefined) { return; }

        setPlayerContribScore(playerInfo.score);
        setPlayerContribScorePerc(Number.isNaN((playerInfo.score / gameEntityCounter!.score_count) * 100) ? 0 : Number(((playerInfo.score / gameEntityCounter!.score_count) * 100).toFixed(2)));

    }, [playerInfo]);

    // this should update all the outpost that have been hit by the current event, as those are the ones with the most likely change of data
    useEffect(() => {

        const updateOwnData = async () => {
            // if (clientGameData === 1) { return; }

            for (let index = 0; index < ownOutposts.length; index++) {
                const entity_id = ownOutposts[index];

                let outpostData = getComponentValueStrict(contractComponents.Outpost, entity_id);
                const lastSavedLifes = outpostData.lifes;

                if (outpostData.lifes === 0) {
                    continue;
                }

                // if there is at least on event being drawn then
                if (clientGameData!.current_event_drawn !== 0) {
                    // create the query
                    const outpostModelQuery = await fetchSpecificOutRevData(graphSdk, clientGameData!.current_game_id, Number(outpostData.entity_id));
                    // set the query
                    setComponentsFromGraphQlEntitiesHM(outpostModelQuery, contractComponents, false);
                    outpostData = getComponentValueStrict(contractComponents.Outpost, entity_id);

                    if (clientGameData!.current_event_drawn !== 0) {
                        const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, entity_id);

                        // if the outpost has the same value of last event then dont set it to effectd
                        if (Number(outpostData.last_affect_event_id) === clientGameData!.current_event_drawn) {
                            updateComponent(clientComponents.ClientOutpostData, entity_id, { event_effected: false });
                        } else {
                            // else calc if it is in there which it should be, to check if this is necessary HERE
                            const lastEvent = getComponentValue(contractComponents.WorldEvent, getEntityIdFromKeys([BigInt(clientGameData!.current_game_id), BigInt(clientGameData!.current_event_drawn)]));

                            const outpostX = outpostData.x;
                            const outpostY = outpostData.y;
                            const eventX = lastEvent!.x;
                            const eventY = lastEvent!.y;
                            const eventRadius = lastEvent!.radius;
                            const inRadius = Math.sqrt(Math.pow(outpostX - eventX, 2) + Math.pow(outpostY - eventY, 2)) <= eventRadius;
                            updateComponent(clientComponents.ClientOutpostData, entity_id, { event_effected: inRadius })
                        }

                        if (outpostData.lifes !== lastSavedLifes && clientOutpostData.owned) {
                            notify(`Someone confirmed your outpost ${clientOutpostData.id}`);
                        }
                    }
                }
            }
        }

        updateOwnData();
        const intervalId = setInterval(updateOwnData, getRefreshOwnOutpostDataTimer() * 1000);

        return () => clearInterval(intervalId);
    }, [clientGameData]);



    // to remove
    // const playClickSound = () => {
    //     if (soundOn) {
    //         // const audio = new Audio("/Sounds/click.wav");
    //         // audio.currentTime = 0;
    //         // audio.play();
    //     }
    // };
    // useEffect(() => {
    //     document.addEventListener('click', playClickSound);
    //     return () => {
    //         document.removeEventListener('click', playClickSound);
    //     };
    // }, [soundOn]);



    return (
        <ClickWrapper className="top-bar-grid-container">
            <div className="top-bar-grid-game-logo" style={{ display: "flex", justifyContent: "space-evenly", alignItems: "center" }}>
                <img src="Icons/LOGO_WHITE.png" style={{ height: "100%", aspectRatio: "1/1" }}></img>
                <img src={soundOn === true ? "Icons/soundon.png" : "Icons/soundoff.png"} className="pointer" style={{ height: "50%", aspectRatio: "1/1" }} onClick={() => setSoundOn(!soundOn)}></img>
            </div>

            <div className="top-bar-grid-left-text-section center-via-flex">
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                    <div style={{ fontSize: "1.2vw" }}>Jackpot: {Number(gameData!.prize)} $LORDS </div>
                </div>
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">

                    {clientGameData!.current_game_state === 2 && (<>
                        {clientGameData!.guest ? (
                            <div style={{ fontSize: "1.2vw", filter: "brightness(70%) grayscale(70%)" }}>Contribution: Log in</div>
                        ) : (
                            <Tooltip title={<>
                                <h4 className="no-margin test-h4" style={{ textAlign: "center" }}>Total contribution game score: {gameEntityCounter!.score_count}</h4>
                                <h4 className="no-margin test-h4" style={{ textAlign: "center" }}>Your contribution score count: {playerContribScore}</h4></>}>

                                <div style={{ fontSize: "1.2vw" }}>Contribution: {playerContribScorePerc}%</div>
                            </Tooltip>
                        )} </>)}
                </div>
            </div>
            <div className="top-bar-grid-right-text-section center-via-flex">
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                    {clientGameData!.current_game_state === 1 ?
                        <div style={{ fontSize: "1.2vw" }}>Revenants Summoned: {gameEntityCounter!.revenant_count}/{gameData!.max_amount_of_revenants}</div>
                        :
                        <div style={{ fontSize: "1.2vw" }}>Revenants Alive: {outpostQuery.length - outpostDeadQuery.length}/{outpostQuery.length}</div>

                    }
                </div>
                <div style={{ width: "100%", flex: "1" }} className="center-via-flex">
                    <div style={{ fontSize: "1.2vw" }}>Reinforcements in game: {gameEntityCounter!.remain_life_count + gameEntityCounter!.reinforcement_count}</div>
                </div>
            </div>
            <div className="top-bar-grid-game-written-logo">
                <div className="center-via-flex" style={{ height: "100%", width: "100%", backgroundColor: "white", color: "black", borderRadius: "10px", padding: "2px 5px", boxSizing: "border-box" }}>
                    <h2 style={{ fontFamily: "Zelda", fontWeight: "100", fontSize: "2.8vw", whiteSpace: "nowrap" }}>Rising Revenant</h2>
                </div>
            </div>
            <div className="top-bar-grid-address" style={{ justifyContent: "space-between", display: "flex", alignItems: "center" }}>
                <LordsBalanceElement />

                <div style={{ width: "60%", height: "75%" }} className="center-via-flex">
                    {!clientGameData!.guest ?
                        <Tooltip title="Click to copy" placement="bottom">
                            <h2  style={{whiteSpace:"nowrap"}}  onClick={() => navigator.clipboard.writeText(account.address)} className=" pointer">
                                <img src="Icons/argent_logo.png" className="chain-logo" alt="Logo" />
                                {truncateString(account.address, 5)}
                            </h2>
                        </Tooltip>
                        :
                        <div className="global-button-style" style={{ padding: "5px 10px", fontSize: "1.2vw", cursor: "pointer" }} onClick={() => window.location.reload()}>
                            LOG IN
                        </div>
                    }
                </div>
            </div>
        </ClickWrapper>
    );
};


const useEventAndUserDataLoader = (updateInterval = 5000) => {

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents, graphSdk },
            systemCalls: { get_current_block }
        },
    } = useDojo();

    useEffect(() => {

        const updateFunctions = () => {
            const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

            checkBlockCount(clientGameData);
            getGameData(clientGameData);
        }

        const getGameData = async (clientGameData: any) => {
            // fetch new game data from chain
            const gameDataQuery = await fetchGameData(graphSdk, clientGameData.current_game_id);
            setComponentsFromGraphQlEntitiesHM(gameDataQuery, contractComponents, false);

            //and new data of the player it self
            const playerInfoQuery = await fetchPlayerInfo(graphSdk, clientGameData.current_game_id, account.address);
            setComponentsFromGraphQlEntitiesHM(playerInfoQuery, contractComponents, false);

            //get the entity counter
            const entityCount = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

            // this checks if there is an event to load in 
            const latest_loaded_event = clientGameData.current_event_drawn;
            const latest_onchain_event = entityCount.event_count;

            const initial_event_index_to_load = latest_onchain_event - latest_loaded_event;

            if (initial_event_index_to_load > 0) {
                for (let i = latest_loaded_event; i <= latest_onchain_event; i++) {
                    const eventQuery = await fetchSpecificEvent(graphSdk, clientGameData.current_game_id, i);

                    setComponentsFromGraphQlEntitiesHM(eventQuery, contractComponents, false);
                }
            }
        }

        const checkBlockCount = async (clientGameData: any) => {
            const blockCount = await get_current_block();

            checkAndSetPhaseClientSide(clientGameData.current_game_id, blockCount!, contractComponents, clientComponents);
        };

        updateFunctions();
        const intervalId = setInterval(updateFunctions, updateInterval);

        return () => clearInterval(intervalId);
    }, []);

};
