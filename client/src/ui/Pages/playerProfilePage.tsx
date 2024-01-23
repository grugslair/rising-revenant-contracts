//libs
import React, { useEffect, useState } from "react";
import { getComponentValueStrict, EntityIndex, updateComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";
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
import { useResizeableHeight } from "../Hooks/gridResize";
import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";
import { getTileIndex } from "../../phaser/constants";
import { useOutpostAmountData } from "../Hooks/outpostsAmountData";

//pages


/*notes
    this could have an issue, when in event effected it could still be triggered if no health
*/


interface ProfilePageProps {
    setUIState: () => void;
    contractComponents: any;
    clientComponents: any;
    reinforce_outpost: any;
    confirm_event_outpost?: any;
    account: any;
    specificSetState?: (number: MenuState) => void;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({ setUIState, specificSetState,contractComponents,clientComponents,reinforce_outpost,confirm_event_outpost,account }) => {

    const [reinforcementCount, setReinforcementCount] = useState(0);
    const [arrOfEnt, setArrOfEnt] = useState<EntityIndex[]>([]);
    const [entsInEvents, setEntsInEvents] = useState(false);

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));
    const outpostAmountData = useOutpostAmountData(clientComponents,contractComponents);

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
        let numInEvent = 0;
        const updatedArrOfEnt = outpostAmountData.ownOutpostsQuery.reduce(
            (result: { aliveEntities: EntityIndex[]; deadEntities: EntityIndex[] }, entityId: EntityIndex) => {

                const clientOutpostEntity = getComponentValueStrict(clientComponents.ClientOutpostData, entityId);
                if (clientOutpostEntity.event_effected === true) {
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

        if (numInEvent > 0) {
            setEntsInEvents(true);
        }
        else {
            setEntsInEvents(false);
        }

        setArrOfEnt([...updatedArrOfEnt.aliveEntities, ...updatedArrOfEnt.deadEntities]);
    }, [outpostAmountData.ownOutpostsQuery]);

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
        updateComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { x: x, y: y });
        updateComponent(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), { tile_index: getTileIndex(x, y) });

        setUIState();

        //we do this to give enough time for the state to change as if its too fast the tooltip doesnt have time to spawn
        setTimeout(() => {
            setTooltipArray.emit("setToolTipArray", [ent]);
        }, 750);
    };
    const confirmAllAttackedOutposts = async () => {
        for (let index = 0; index < outpostAmountData.ownOutpostsQuery.length; index++) {
            const element = outpostAmountData.ownOutpostsQuery[index];

            const clientOutpostEntity = getComponentValueStrict(clientComponents.ClientOutpostData, element);

            if (clientOutpostEntity.event_effected === true) {
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
                                    <ListElement entityId={ownedOutID} reinforce_outpost={reinforceOutpost} currentBalance={reinforcementCount} goHereFunc={setCameraPos} phase={clientGameData.current_game_state} confirmEvent={callSingularEventConfirm} contractComponents={contractComponents} clientComponents={clientComponents}/>
                                    {index < outpostAmountData.ownOutpostsQuery.length - 1 && dividingLine}
                                </React.Fragment>
                            ))}
                        </div>
                    </div>
                    <div style={{ width: "100%", height: "10%", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        {clientGameData.current_game_state === 1 ? (<></>) :
                            (
                                <>
                                    <div className="global-button-style" style={{ padding: "5px 5px", fontSize: "1cqw" }} onClick={() => { specificSetState!(MenuState.TRADES) }}>Go To Trade Section</div>
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

//HERE this needs to be slimmed down
interface ListElementProps {
    entityId: EntityIndex;
    reinforce_outpost: any;
    currentBalance: number;
    phase: number;
    goHereFunc: any;
    confirmEvent: any;
    contractComponents: any;
    clientComponents:any;
}

export const ListElement: React.FC<ListElementProps> = ({ entityId, reinforce_outpost, currentBalance, goHereFunc, phase, confirmEvent, contractComponents, clientComponents}) => {
    const [buttonIndex, setButtonIndex] = useState<number>(0)
    const [amountToReinforce, setAmountToReinforce] = useState<number>(1)

    const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(24, 4, "100%");

    const outpostData: any = useComponentValue(contractComponents.Outpost, entityId);
    const revenantData: any = getComponentValueStrict(contractComponents.Revenant, entityId);
    const clientOutpostData: any = useComponentValue(clientComponents.ClientOutpostData, entityId);

    useEffect(() => {
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

    return (
        <div ref={clickWrapperRef} className={`profile-page-grid-container ${clientOutpostData.event_effected && outpostData.lifes > 0 ? ' profile-page-attacked-style' : ''}`} style={clickWrapperStyle} onMouseEnter={() => setButtonIndex(1)} onMouseLeave={() => setButtonIndex(0)}>
            <div className="pfp">
                <img src={revenantsPicturesLinks[mapEntityToImage(clientOutpostData!.id, namesArray[revenantData.first_name_idx], 25)]} className="child-img " />
            </div>

            <div className="name" style={{ display: "flex", justifyContent: "flex-start", alignItems: "center" }}>
                <h3 style={{ textAlign: "center", fontFamily: "OL", fontWeight: "100", color: "white", fontSize: "0.9cqw", whiteSpace: "nowrap" }}>{namesArray[revenantData.first_name_idx]} {surnamesArray[revenantData.last_name_idx]} </h3>
            </div>

            <div className="otp" style={{ position: "relative" }}>
                {clientOutpostData.event_effected && <div style={{ position: "absolute", top: "0", left: "0", backgroundColor: "#ff000055", height: "100%", width: "100%" }}></div>}
                <img src="Misc/test_out_pp.png" className="child-img" />
            </div>

            <div className="sh shields-grid-container" style={{ boxSizing: "border-box" }}>
                {Array.from({ length: outpostData.shield }).map((_, index) => (
                    <img key={index} src="Icons/SHIELD.png" className="img-full-style" />
                ))}
            </div>

            <div className="info-id-text">
                <h4 className="no-margin test-h4 info-pp-text-style">Outpost ID:</h4>
            </div>
            <div className="info-id-value">
                <h4 className="no-margin test-h4 info-pp-text-style">{Number(outpostData.entity_id).toString()}</h4>
            </div>

            <div className="info-coord-text">
                <h4 className="no-margin test-h4 info-pp-text-style">Coordinates:</h4>
            </div>
            <div className="info-coord-value">
                <h4 className="no-margin test-h4 info-pp-text-style">X: {outpostData.x}, Y: {outpostData.y}</h4>
            </div>
            <div className="info-coord-button">
                <h4 className="no-margin test-h4 global-button-style info-pp-text-style" style={{ width: "fit-content", height: "fit-content", padding: "2px 5px", boxSizing: "border-box", margin: "0px auto" }} onClick={() => goHereFunc(outpostData.x, outpostData.y, entityId)}>Go Here</h4>
            </div>

            <div style={{ gridRow: "1", gridColumn: "19/22", display: "flex" }}>
                <h4 className="no-margin test-h4 info-pp-text-style">Reinforcements:</h4>
            </div>
            <div style={{ gridRow: "2", gridColumn: "19/22", display: "flex" }}>
                <h4 className="no-margin test-h4 info-pp-text-style">{outpostData.lifes}</h4>
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
                                            <img src="Icons/minus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce - 1)} />
                                        </div>
                                    </div>
                                    <div style={{ gridRow: "1", gridColumn: "2", display: "flex" }}>
                                        <h4 className="no-margin test-h4 info-pp-text-style">{amountToReinforce}</h4>
                                    </div>
                                    <div style={{ gridRow: "1", gridColumn: "3", display: "flex" }}>
                                        <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                            <img src="Icons/plus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce + 1)} />
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
                                    <img src="Icons/minus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce - 1)} />
                                </div>
                            </div>
                            <div style={{ gridRow: "1", gridColumn: "2", display: "flex" }}>
                                <h4 className="no-margin test-h4 info-pp-text-style">{amountToReinforce}</h4>
                            </div>
                            <div style={{ gridRow: "1", gridColumn: "3", display: "flex" }}>
                                <div className="global-button-style info-pp-text-style" style={{ width: "50%", height: "50%", margin: "0px auto" }} >
                                    <img src="Icons/plus.png" alt="minus" style={{ width: "100%", height: "100%" }} onClick={() => setAmountToReinforce(amountToReinforce + 1)} />
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