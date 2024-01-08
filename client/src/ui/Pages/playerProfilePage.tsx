//libs
import React, { useEffect, useState } from "react";
import { HasValue, getComponentValueStrict, getComponentValue, EntityIndex, Has } from "@latticexyz/recs";
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
import { namesArray, setClientCameraComponent, surnamesArray } from "../../utils";
import { ReinforcementCountElement } from "../Elements/reinfrocementBalanceElement";
import { MenuState } from "./gamePhaseManager";
import { useResizeableHeight } from "../loginComponent";
import { setTooltipArray } from "../../phaser/systems/eventSystems/eventEmitter";

//pages


/*notes
this component should first query all the outposts that are owned from the player and then send each to the outpostElement type (that has yet to be made) like from the 
examples

needs functionality to move the camera to a certain location and ability to call reinforce dojo function and go to the trade page
*/


interface ProfilePageProps {
    setUIState: () => void;
    specificSetState?: (MenuState) => void;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({ setUIState, specificSetState }) => {

    const [reinforcementCount, setReinforcementCount] = useState(0);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents },
            systemCalls: { reinforce_outpost, confirm_event_outpost }
        },
    } = useDojo();

    const ownedOutpost = useEntityQuery([HasValue(contractComponents.Outpost, { owner: account.address })]);
    const ownedAndInEvent = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true, event_effected: true })]);

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]))

    const dividingLine: JSX.Element = (
        <div className="divider" ></div>
    )

    useEffect(() => {

        if (playerInfo !== undefined) {
            setReinforcementCount(playerInfo.reinforcement_count);
        }

    }, [playerInfo]);


    const reinforceOutpost = (outpost_id: any, count: number) => {

        const reinforceOutpostProps: ReinforceOutpostProps = {
            account: account,
            game_id: clientGameData.current_game_id,
            count: count,
            outpost_id: outpost_id,
        };

        reinforce_outpost(reinforceOutpostProps);
    }

    const setCameraPos = (x: number, y: number, ent: any) => {
        setClientCameraComponent(x, y, clientComponents);
        setUIState();

        //we do this to give enough time for the state to change as if its too fast the tooltip doesnt have time to spawn
        setTimeout(() => {
            setTooltipArray.emit("setToolTipArray", [ent]);
        }, 750);
    };

    const confirmAllAttackedOutposts = async () => {
        for (let index = 0; index < ownedAndInEvent.length; index++) {
            const element = ownedAndInEvent[index];

            await callSingularEventConfirm(element);
        }
    }

    const callSingularEventConfirm = async (entity_id: EntityIndex) => {
        const confirmEventOutpost: ConfirmEventOutpost = {
            account: account,
            game_id: clientGameData.current_game_id,
            outpost_id: getComponentValueStrict(clientComponents.ClientOutpostData, entity_id).id,
            event_id: clientGameData.current_event_drawn,
        }

        await confirm_event_outpost(confirmEventOutpost);
    }

    return (
        <ClickWrapper className="game-page-container">

            <img className="page-img brightness-down" src="./assets/Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />

            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"PROFILE"} rightPicture={"close_icon.png"} rightImageFunction={setUIState} htmlContentsRight={<ReinforcementCountElement style={{marginRight:"8%"}}/>} styleContainerRight={{display:"flex", justifyContent:"flex-end" , alignItems:"center"}}/>

            <div style={{ width: "100%", height: "80%", position: "relative", display: "flex", flexDirection: "row" }}>
                <div style={{ width: "8%", height: "100%" }}></div>

                <div style={{ width: "84%", height: "100%" }}>
                    <div style={{ width: "100%", height: "90%", display: "flex", justifyContent: "center", alignItems: "center" }}>
                        <div className="test-query">
                            {ownedOutpost.map((ownedOutID, index) => (
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
                                    {ownedAndInEvent.length > 0 ? (<div className="global-button-style" style={{ padding: "5px 5px" }} onClick={() => { confirmAllAttackedOutposts() }}>Confirm All</div>) : (<></>)}
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

// HERE all these use states can be delete and just put one for the rev and outpost data no need for this many

export const ListElement: React.FC<ListElementProps> = ({ entityId, reinforce_outpost, currentBalance, goHereFunc, phase, confirmEvent }) => {
    const [buttonIndex, setButtonIndex] = useState<number>(0)
    const [amountToReinforce, setAmountToReinforce] = useState<number>(1)

    const [name, setName] = useState<string>("Name")
    const [surname, setSurname] = useState<string>("Surname")

    const [id, setId] = useState<string>("5")
    const [xCoord, setXCoord] = useState<number>(5)
    const [yCoord, setYCoord] = useState<number>(5)

    const [shieldNum, setShieldNum] = useState<number>(5)
    const [reinforcements, setReinforcements] = useState<number>(20)

    const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(24, 4, "99%");

    const {
        networkLayer: {
            network: { contractComponents, clientComponents }
        },
    } = useDojo();

    const outpostData = useComponentValue(contractComponents.Outpost, entityId);
    const revenantData = getComponentValueStrict(contractComponents.Revenant, entityId);
    const clientOutpostData = useComponentValue(clientComponents.ClientOutpostData, entityId);

    useEffect(() => {
        setShieldNum(outpostData.shield);
        setXCoord(outpostData.x);
        setYCoord(outpostData.y);
        setReinforcements(outpostData.lifes);
        setId(outpostData.entity_id.toString());

        setName(namesArray[revenantData.first_name_idx]);
        setSurname(surnamesArray[revenantData.last_name_idx]);
    }, [outpostData,useComponentValue]);

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

    // ${clientOutpostData.event_effected && outpostData.lifes > 0 ? ' profile-page-attacked-style' : ''}

    return (
        <div ref={clickWrapperRef} className={`profile-page-grid-container`} style={clickWrapperStyle} onMouseEnter={() => setButtonIndex(1)} onMouseLeave={() => setButtonIndex(0)}>
            <div className="pfp">
                <img src="Rev_PFP_11.png" className="child-img " />
            </div>

            <div className="name" style={{ display: "flex", justifyContent: "flex-start", alignItems: "center", overflowX: "visible" }}>
                <h3 className="no-margin test-h4" style={{ textAlign: "center", fontFamily: "OL", color: "white", whiteSpace: "nowrap" }}>{name} {surname} </h3>
            </div>

            <div className="otp" style={{ position: "relative" }}>
                {clientOutpostData.event_effected && <div style={{ position: "absolute", top: "0", left: "0", backgroundColor: "#ff000055", height: "100%", width: "100%" }}></div>}
                <img src="test_out_pp.png" className="child-img" />
            </div>

            <div className="sh shields-grid-container" style={{ boxSizing: "border-box" }}>
                {Array.from({ length: shieldNum }).map((_, index) => (
                    <img key={index} src="SHIELD.png" className="img-full-style" />
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

            <div className="info-reinf-text">
                <h4 className="no-margin test-h4 info-pp-text-style">Reinforcements:</h4>
            </div>
            <div className="info-reinf-value">
                <h4 className="no-margin test-h4 info-pp-text-style">{reinforcements}</h4>
            </div>

            {outpostData.lifes > 0 && phase === 2 &&
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
                </>
            }
        </div>
    );
};


// might be an issue with the last part of this component as it might still take space but not render to check HERE






