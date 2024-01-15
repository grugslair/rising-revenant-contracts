//libs
import React, { useEffect, useRef, useState } from "react";
import { HasValue, getComponentValueStrict, getComponentValue, EntityIndex, Has, updateComponent } from "@latticexyz/recs";
import { useEntityQuery, useComponentValue } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { ConfirmEventOutpost, ReinforceOutpostProps } from "../../dojo/types";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { getEntityIdFromKeys } from "@dojoengine/utils";

//styles
import "./PagesStyles/ProfilePageStyles.css";

//elements/components
import { ClickWrapper } from "../clickWrapper";
import PageTitleElement, { ImagesPosition } from "../Elements/pageTitleElement";
import { mapEntityToImage, namesArray, revenantsPicturesLinks, surnamesArray } from "../../utils";
import { ReinforcementCountElement } from "../Elements/reinfrocementBalanceElement";
import { MenuState } from "./gamePhaseManager";
import { useResizeableHeight } from "../loginComponent";
import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";
import { getTileIndex } from "../../phaser/constants";

//pages


/*notes
    this could have an issue, when in event effected it could still be triggered if no health
*/


interface ProfilePageProps {
    setUIState: () => void;
    specificSetState?:(number: MenuState) => void;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({ setUIState, specificSetState}) => {

    const [reinforcementCount, setReinforcementCount] = useState(0);
    const [arrOfEnt, setArrOfEnt] = useState<EntityIndex[]>([]);
    const [entsInEvents, setEntsInEvents] = useState(false);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents, graphSdk },
            systemCalls: { reinforce_outpost, confirm_event_outpost }
        },
    } = useDojo();


    // this can actaully be merged 
    const ownedOutpost = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true })]);
    // const ownedAndInEvent = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true, event_effected: true })]);

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]))

    const dividingLine: JSX.Element = (
        <div className="divider"></div>
    )

    useEffect(() => {

        if (playerInfo !== undefined) {
            setReinforcementCount(playerInfo.reinforcement_count);
        }
    }, [playerInfo]);

    useEffect(() => {
        // If you can't use an interface, you can set the type on the arrays directly.
        let numInEvent = 0;
        const updatedArrOfEnt = ownedOutpost.reduce(
            (result: { aliveEntities: EntityIndex[]; deadEntities: EntityIndex[] }, entityId: EntityIndex) => {

                const clientOutpostEntity = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
                if (clientOutpostEntity.event_effected === true){
                    numInEvent++;
                }

                const outpostEntity = getComponentValueStrict(contractComponents.Outpost, entityId);
                if (outpostEntity.reinforcement_count > 0) {
                    result.aliveEntities.push(entityId);
                } else {
                    result.deadEntities.push(entityId);
                }
                return result;
            },
            { aliveEntities: [] as EntityIndex[], deadEntities: [] as EntityIndex[] }
        );

        if (numInEvent > 0)
        {
            setEntsInEvents(true);
        }
        else{
            setEntsInEvents(false);
        }

        setArrOfEnt([...updatedArrOfEnt.aliveEntities, ...updatedArrOfEnt.deadEntities]);
    }, [ownedOutpost]);

    const reinforceOutpost = (outpost_id: any, count: number) => {

        const reinforceOutpostProps: ReinforceOutpostProps = {
            account: account,
            game_id: clientGameData.current_game_id,
            count: count,
            outpost_id: outpost_id,
        };

        reinforce_outpost(reinforceOutpostProps);
    };

    const setCameraPos = (x: number, y: number, ent: any) => {
        updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {x: x,y:y});
        updateComponent(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {tile_index: getTileIndex(x,y)});

        setUIState();

        //we do this to give enough time for the state to change as if its too fast the tooltip doesnt have time to spawn
        setTimeout(() => {
            setTooltipArray.emit("setToolTipArray", [ent]);
        }, 750);
    };

    const confirmAllAttackedOutposts = async () => {
        for (let index = 0; index < ownedOutpost.length; index++) {
            const element = ownedOutpost[index];
            
            const clientOutpostEntity = getComponentValueStrict(clientComponents.ClientOutpostData, element);

            if (clientOutpostEntity.event_effected === true){
                await callSingularEventConfirm(element);
            }
        }
    };

    const callSingularEventConfirm = async (entity_id: EntityIndex) => {
        const confirmEventOutpost: ConfirmEventOutpost = {
            account: account,
            game_id: clientGameData.current_game_id,
            outpost_id: getComponentValueStrict(clientComponents.ClientOutpostData, entity_id).id,
            event_id: clientGameData.current_event_drawn,
        }

        await confirm_event_outpost(confirmEventOutpost);
    };

    return (
        <ClickWrapper className="game-page-container">

            <img className="page-img brightness-down" src="./Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />

            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"PROFILE"} rightPicture={"Icons/close_icon.png"} rightImageFunction={setUIState} htmlContentsRight={<ReinforcementCountElement style={{ marginRight: "8%" }} />} styleContainerRight={{ display: "flex", justifyContent: "flex-end", alignItems: "center" }} />

            <div style={{ width: "100%", height: "80%", position: "relative", display: "flex", flexDirection: "row" }}>
                <div style={{ width: "8%", height: "100%" }}></div>

                <div style={{ width: "84%", height: "100%" }}>
                    <div style={{ width: "100%", height: "90%", display: "flex", justifyContent: "center", alignItems: "center" }}>
                        <div className="test-query">
                            {arrOfEnt.map((ownedOutID, index) => (
                                <React.Fragment key={index}>
                                    <ListElement entityId={ownedOutID} reinforce_outpost={reinforceOutpost} currentBalance={reinforcementCount} goHereFunc={setCameraPos} phase={clientGameData.current_game_state} confirmEvent={callSingularEventConfirm} />
                                    {index < ownedOutpost.length - 1 && dividingLine}
                                </React.Fragment>
                            ))}
                        </div>
                    </div>
                    <div style={{ width: "100%", height: "10%", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        {clientGameData.current_game_state === 1 ? (<></>) :
                            (
                                <>
                                    <div className="global-button-style" style={{ padding: "5px 5px", fontSize: "1cqw" }} onClick={() => { specificSetState(MenuState.TRADES) }}>Go To Trade Section</div>
                                    {entsInEvents ? (<div className="global-button-style" style={{ padding: "5px 5px" }} onClick={() => { confirmAllAttackedOutposts() }}>Confirm All</div>) : (<></>)}
                                </>
                            )}
                    </div>
                </div>

                <div style={{ width: "8%", height: "100%" }}></div>
            </div>
        </ClickWrapper>
    );
};


//this needs to be slimmed down

interface ListElementProps {
    entityId: EntityIndex
    reinforce_outpost: any
    currentBalance: number
    phase: number
    goHereFunc: any
    confirmEvent: any
}

export const ListElement: React.FC<ListElementProps> = ({ entityId, reinforce_outpost, currentBalance, goHereFunc, phase, confirmEvent }) => {
    const [buttonIndex, setButtonIndex] = useState<number>(0)
    const [amountToReinforce, setAmountToReinforce] = useState<number>(1)
    const [heightValue, setHeight] = useState<number>(0)

    const [name, setName] = useState<string>("Name")
    const [surname, setSurname] = useState<string>("Surname")

    const [id, setId] = useState<string>("5")
    const [xCoord, setXCoord] = useState<number>(5)
    const [yCoord, setYCoord] = useState<number>(5)

    const [shieldNum, setShieldNum] = useState<number>(5)
    const [reinforcements, setReinforcements] = useState<number>(20)

    const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(24, 4, "20%");

    const {
        networkLayer: {
            network: { contractComponents, clientComponents }
        },
    } = useDojo();

    const outpostData: any = useComponentValue(contractComponents.Outpost, entityId);
    const revenantData: any = getComponentValueStrict(contractComponents.Revenant, entityId);
    const clientOutpostData: any = useComponentValue(clientComponents.ClientOutpostData, entityId);

    useEffect(() => {
        setShieldNum(outpostData.shield);
        setXCoord(outpostData.x);
        setYCoord(outpostData.y);
        setReinforcements(outpostData.lifes);
        setId(outpostData.entity_id.toString());

        setName(namesArray[revenantData.first_name_idx]);
        setSurname(surnamesArray[revenantData.last_name_idx]);
    }, [outpostData]);

    useEffect(() => {
        console.error(currentBalance);

        if (currentBalance === 0) {
            setAmountToReinforce(0);
            return;
        }
        if (amountToReinforce > currentBalance) {
            setAmountToReinforce(currentBalance);
        }
        else if (amountToReinforce < 1) {
            setAmountToReinforce(1);
        }

    }, [amountToReinforce, buttonIndex]);

    // ${clientOutpostData.event_effected && outpostData.lifes > 0 ? ' profile-page-attacked-style' : ''}

    return (
        <div ref={clickWrapperRef} className={`profile-page-grid-container ${clientOutpostData.event_effected && outpostData.lifes > 0 ? ' profile-page-attacked-style' : ''}`} style={clickWrapperStyle} onMouseEnter={() => setButtonIndex(1)} onMouseLeave={() => setButtonIndex(0)}>
            <div className="pfp">
                <img src={revenantsPicturesLinks[mapEntityToImage(clientOutpostData!.id, namesArray[revenantData.first_name_idx], 25)]} className="child-img " />
            </div>

            <div className="name" style={{ display: "flex", justifyContent: "flex-start", alignItems: "center" }}>
                <h3 style={{ textAlign: "center", fontFamily: "OL", fontWeight: "100", color: "white", fontSize: "0.9cqw", whiteSpace: "nowrap" }}>{name} {surname} </h3>
            </div>

            <div className="otp" style={{ position: "relative" }}>
                {clientOutpostData.event_effected && <div style={{ position: "absolute", top: "0", left: "0", backgroundColor: "#ff000055", height: "100%", width: "100%" }}></div>}
                <img src="test_out_pp.png" className="child-img" />
            </div>

            <div className="sh shields-grid-container" style={{ boxSizing: "border-box" }}>
                {Array.from({ length: shieldNum }).map((_, index) => (
                    <img key={index} src="Icons/SHIELD.png" className="img-full-style" />
                ))}
            </div>

            <div className="info-id-text">
                <h4 className="no-margin test-h4 info-pp-text-style">Outpost ID:</h4>
            </div>
            <div className="info-id-value">
                <h4 className="no-margin test-h4 info-pp-text-style">{id}</h4>
            </div>

            <div className="info-coord-text">
                <h4 className="no-margin test-h4 info-pp-text-style">Coordinates:</h4>
            </div>
            <div className="info-coord-value">
                <h4 className="no-margin test-h4 info-pp-text-style">X: {xCoord}, Y: {yCoord}</h4>
            </div>
            <div className="info-coord-button">
                <h4 className="no-margin test-h4 global-button-style info-pp-text-style" style={{ width: "fit-content", height: "fit-content", padding: "2px 5px", boxSizing: "border-box", margin: "0px auto" }} onClick={() => goHereFunc(xCoord, yCoord, entityId)}>Go Here</h4>
            </div>

                <div onMouseEnter={() => { setButtonIndex(3) }} onMouseLeave={() => { setButtonIndex(1) }} style={{ flex: "1", height: "100%", boxSizing: "border-box" }}>
                    <div style={{ width: "100%", height: "50%", }}> <h3 style={{ textAlign: "center", fontFamily: "OL", fontWeight: "100", color: "white", fontSize: "0.9cqw" }}>Coordinates: <br /><br />X: {xCoord}, Y: {yCoord}</h3>    </div>
                    <div style={{ width: "100%", height: "50%", display: "flex", justifyContent: "center", alignItems: "center" }}>
                        {buttonIndex === 3 && phase === 2 && <div className="global-button-style" style={{ height: "50%", padding: "5px 10px", boxSizing: "border-box", fontSize: "0.6cqw", display: "flex", justifyContent: "center", alignItems: "center" }} onClick={() => goHereFunc(xCoord, yCoord)}> <h2>Go here</h2></div>}
                    </div>
                </div>

            {outpostData.lifes > 0 &&
                <>
                    {phase === 2 ?
                        <>
                            {clientOutpostData.event_effected ?
                                <div style={{ gridRow: "3/4", gridColumn: "22/25", display: "flex" }}>
                                    <h4 className="no-margin test-h4 global-button-style info-pp-text-style" style={{ width: "fit-content", height: "fit-content", padding: "2px 5px", boxSizing: "border-box", margin: "0px auto" }} onClick={() => { confirmEvent(entityId) }}>Validate Event</h4>
                                </div>
                                :
                                <div className="action" style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gridTemplateRows: "1fr 1fr" }}>
                                    <div style={{ gridRow: "1", gridColumn: "1", display: "flex" }}>
                                        <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                            <img src="/minus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce - 1)} />
                                        </div>
                                    </div>
                                    <div style={{ gridRow: "1", gridColumn: "2", display: "flex" }}>
                                        <h4 className="no-margin test-h4 info-pp-text-style">{amountToReinforce}</h4>
                                    </div>
                                    <div style={{ gridRow: "1", gridColumn: "3", display: "flex" }}>
                                        <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                            <img src="/plus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce + 1)} />
                                        </div>
                                    </div>
                                    <div style={{ gridRow: "2", gridColumn: "1/4", display: "flex", position: "relative" }}>
                                        <h4 className="no-margin test-h4 global-button-style info-pp-text-style" style={{ width: "fit-content", height: "fit-content", padding: "2px 5px", boxSizing: "border-box", margin: "0px auto" }} onClick={() => reinforce_outpost(clientOutpostData.id, amountToReinforce)}>Reinforce</h4>
                                    </div>
                                </div>
                            }
                        </> :
                        <div className="action" style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gridTemplateRows: "1fr 1fr" }}>
                            <div style={{ gridRow: "1", gridColumn: "1", display: "flex" }}>
                                <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                    <img src="/minus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce - 1)} />
                                </div>
                            </div>
                            <div style={{ gridRow: "1", gridColumn: "2", display: "flex" }}>
                                <h4 className="no-margin test-h4 info-pp-text-style">{amountToReinforce}</h4>
                            </div>
                            <div style={{ gridRow: "1", gridColumn: "3", display: "flex" }}>
                                <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                    <img src="/plus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce + 1)} />
                                </div>
                            </div>
                            <div style={{ gridRow: "2", gridColumn: "1/4", display: "flex", position: "relative" }}>
                                <h4 className="no-margin test-h4 global-button-style info-pp-text-style" style={{ width: "fit-content", height: "fit-content", padding: "2px 5px", boxSizing: "border-box", margin: "0px auto" }} onClick={() => reinforce_outpost(clientOutpostData.id, amountToReinforce)}>Reinforce</h4>
                            </div>
                        </div>
                    }
                </>
            }
            
        </div>
    );
};


// might be an issue with the last part of this component as it might still take space but not render to check HERE






