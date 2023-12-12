//libs
import React, { useEffect, useState } from "react";
import { MenuState } from "./gamePhaseManager";
import { HasValue, getComponentValueStrict, getComponentValue, EntityIndex,Has } from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";
import { useDojo } from "../../hooks/useDojo";
import { ConfirmEventOutpost, ReinforceOutpostProps } from "../../dojo/types";
import { GAME_CONFIG } from "../../phaser/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";

//styles
import "./PagesStyles/ProfilePageStyles.css";


//elements/components
import { ClickWrapper } from "../clickWrapper";
import PageTitleElement from "../Elements/pageTitleElement";
import { decimalToHexadecimal, namesArray, setClientCameraComponent, surnamesArray } from "../../utils";

//pages


/*notes
this component should first query all the outposts that are owned from the player and then send each to the outpostElement type (that has yet to be made) like from the 
examples

needs functionality to move the camera to a certain location and ability to call reinforce dojo function and go to the trade page
*/


// HERE this needs to be put into a grid system not flex

interface ProfilePageProps {
    setUIState: () => void;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({ setUIState }) => {

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents },
            systemCalls: {reinforce_outpost}
        },
    } = useDojo();

    const ownedOutpost = useEntityQuery([HasValue(contractComponents.Outpost, { owner: account.address })]);

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
    const playerInfo = getComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]));

    //test embed needs to be standardized 
    const reinforcementsBalanceDiv = (
        <div className="title-cart-section">
            <h1>
                <img src="reinforcements_logo.png" className="test-embed" alt="" />
                {playerInfo.reinforcement_count || "NaN"}
            </h1>
            <h3>Reinforcement available</h3>
        </div>
    );

    const dividingLine: JSX.Element = (
        <div className="divider"></div>
    )

    const reinforceOutpost = (outpost_id: any) => {

        const reinforceOutpostProps: ReinforceOutpostProps = {
          account: account,
          game_id: clientGameData.current_game_id,
          outpost_id: outpost_id,
        };
    
        reinforce_outpost(reinforceOutpostProps);
    }

    return (
        <ClickWrapper className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />

            <PageTitleElement name={"PROFILE"} rightPicture={"close_icon.svg"} closeFunction={setUIState} right_html_element={reinforcementsBalanceDiv} />

            <div style={{ width: "100%", height: "90%", position: "relative", display: "flex", flexDirection: "row" }}>
                <div style={{ width: "8%", height: "100%" }}></div>

                <div style={{ width: "84%", height: "100%" }}>
                    <div style={{ width: "100%", height: "90%", display: "flex", justifyContent: "center", alignItems: "center" }}>
                        <div style={{ width: "100%", height: "90%", overflowY: "scroll", scrollbarGutter: "stable", paddingTop: "10px" }}>
                            {ownedOutpost.map((ownedOutID, index) => (
                                <React.Fragment key={index}>
                                    <ListElement entityId={getComponentValueStrict(contractComponents.Outpost, ownedOutID).entity_id} contractComponents={contractComponents} clientComponents={clientComponents} reinforce_outpost={reinforceOutpost}/>
                                    {index < ownedOutpost.length - 1 && dividingLine}
                                </React.Fragment>
                            ))}
                        </div>
                    </div>
                    <div style={{ width: "100%", height: "10%", display: "flex", justifyContent: "flex-start", alignItems: "center" }}>
                        <div className="global-button-style" style={{ padding: "5px 5px" }}>Buy Reinforcements</div>
                    </div>
                </div>

                <div style={{ width: "8%", height: "100%" }}></div>
            </div>
        </ClickWrapper>
    );
};


interface ListElementProps {
    entityId: EntityIndex
    contractComponents: any
    clientComponents: any
    reinforce_outpost:any
}

// the data section is probably to change as the click is only for the text but there is a gap between the texts also the code is duplicated should be one singular div
export const ListElement: React.FC<ListElementProps> = ({ entityId, contractComponents, clientComponents, reinforce_outpost }) => {
    const [buttonText, setButtonText] = useState<string>("")

    const [name, setName] = useState<string>("Name")
    const [surname, setSurname] = useState<string>("Surname")

    const [id, setId] = useState<number>(5)
    const [xCoord, setXCoord] = useState<number>(5)
    const [yCoord, setYCoord] = useState<number>(5)

    const [shieldNum, setShieldNum] = useState<number>(2)
    const [reinforcements, setReinforcements] = useState<number>(20)

    // for future reference, this will trigger the useffect if the entity is changed
    const outpostCompQuery = useEntityQuery([HasValue(contractComponents.Outpost, { entity_id: BigInt(entityId)})]);

    useEffect(() => {
        const clientOutpostData = getComponentValue(clientComponents.ClientOutpostData, outpostCompQuery[0]);
        const contractOutpostData = getComponentValue(contractComponents.Outpost, outpostCompQuery[0]);
        const contractRevenantData = getComponentValue(contractComponents.Revenant, outpostCompQuery[0]);
        
        setName(namesArray[contractRevenantData.first_name_idx])
        setSurname(surnamesArray[contractRevenantData.last_name_idx])

        setId(clientOutpostData.id);

        setXCoord(contractOutpostData.x);
        setYCoord(contractOutpostData.y);

        const reinforcements = contractOutpostData.lifes;
        setReinforcements(reinforcements);

        if (reinforcements < 3) {
            setShieldNum(0);
        } else if (reinforcements <= 5) {
            setShieldNum(1);
        } else if (reinforcements <= 9) {
            setShieldNum(2);
        } else if (reinforcements <= 13) {
            setShieldNum(3);
        } else if (reinforcements <= 19) {
            setShieldNum(4);
        } else {
            setShieldNum(5);
        }
    }, [outpostCompQuery])
    

    return (
        <ClickWrapper className="list-item-container">
            {/* picture */}
            <div className="profile-picture-container">
                <div className="profile-picture-box">
                    <div className="child-container2">
                        <img src="test_rev_pp.png" className="img-full-style" />
                    </div>
                </div>
                <div className="profile-picture-name-box">{name} {surname}</div>
            </div>

            {/* outpost pic */}
            <div className="outpost-pic-container">
                <div className="outpost-pic-box">
                    <div className="outpost-pic">
                        <img src="test_out_pp.png" className="child-img" />
                    </div>
                </div>
                <div className="shields-container">
                    <div className="shield-box">
                        <div className="shields-grid-container">
                            {Array.from({ length: shieldNum }).map((_, index) => (
                                <img key={index} src="reinforcements_logo.png" className="img-full-style" />
                            ))}
                        </div>
                    </div>
                    <div style={{ width: "40%" }}></div>
                </div>
            </div>

            {/* data */}
            <div className="parent-container" onMouseLeave={() => setButtonText("")} style={{ fontWeight: "100" }}>
                <div className="row-data-container" style={{ fontSize: "0.9cqw" }}>
                    <h4 onMouseEnter={() => setButtonText("")}>Outpost ID:</h4>
                    <h4 onMouseEnter={() => setButtonText("Go here")}  onClick={() => {setClientCameraComponent(xCoord, yCoord,clientComponents)}}   className="pointer">Coordinates:</h4>
                    <h4 onMouseEnter={() => setButtonText("Reinforce")} className="pointer" onClick={() => {reinforce_outpost(id)}}>Reinforcements:</h4>
                </div>
                <div className="row-data-container" style={{ fontSize: "1cqw" }}>
                    <h4 onMouseEnter={() => setButtonText("")}>{id}</h4>
                    <h4 onMouseEnter={() => setButtonText("Go here")} className="pointer" onClick={() => {setClientCameraComponent(xCoord, yCoord,clientComponents)}} >X: {xCoord}, Y: {yCoord}</h4>
                    <h4 onMouseEnter={() => setButtonText("Reinforce")} className="pointer" onClick={() => {reinforce_outpost(id)}}>{reinforcements}</h4>
                </div>
                <div style={{ height: "34%" }}> </div>
            </div>

            {/* tooltip */}
            <div style={{ height: "100%", width: "20%", display: "flex", justifyContent: "center", alignItems: "center", flex: "0.7" }}>
                {buttonText !== "" && <div className="global-button-style" style={{ padding: "5px 5px" }}>{buttonText}</div>}
            </div>

        </ClickWrapper>
    );
};





