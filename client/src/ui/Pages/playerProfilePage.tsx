//libs
import React, { useEffect, useRef, useState } from "react";
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
                        <div className="test-query">
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

export const ListElement: React.FC<ListElementProps> = ({ entityId, contractComponents, clientComponents, reinforce_outpost }) => {
    const [buttonIndex, setButtonIndex] = useState<number>(0)
    const [amountToReinforce, setAmountToReinforce] = useState<number>(1)
    const [heightValue, setHeight] = useState<number>(0)


    const [name, setName] = useState<string>("Name")
    const [surname, setSurname] = useState<string>("Surname")

    const [id, setId] = useState<number>(5)
    const [xCoord, setXCoord] = useState<number>(5)
    const [yCoord, setYCoord] = useState<number>(5)

    const [shieldNum, setShieldNum] = useState<number>(5)
    const [reinforcements, setReinforcements] = useState<number>(20)

    const clickWrapperRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        // Update the height value based on the width of ClickWrapper
        const updateHeight = () => {
            if (clickWrapperRef.current) {
                setHeight((clickWrapperRef.current.offsetWidth / 24) * 4);

            }
        };

        // Attach the updateHeight function to the window resize event
        window.addEventListener('resize', updateHeight);

        // Initial update
        updateHeight();

        // Cleanup the event listener on component unmount
        return () => {
            window.removeEventListener('resize', updateHeight);
        };
    }, []);

    useEffect(() => {console.log(heightValue)}, [heightValue])


    const clickWrapperStyle: React.CSSProperties = {
        height: `${heightValue}px`, // Use pixels for height
        width: '99%', // Set width to 100%
    };

    return (
        <div ref={clickWrapperRef} className="grid-container" style={clickWrapperStyle} onMouseEnter={() => setButtonIndex(1)} onMouseLeave={() => setButtonIndex(0)}>
            <div className="pfp">
                <img src="Rev_PFP_11.png" className="child-img" />
            </div>
            <div className="name" style={{display:"flex", justifyContent:"flex-start", alignItems:"center"}}> <h3 style={{ textAlign:"center", fontFamily:"OL", fontWeight:"100", color:"white", fontSize:"0.9cqw", whiteSpace:"nowrap"}}>{name} {surname}</h3></div>
            <div className="otp">
                <img src="test_out_pp.png" className="child-img" />
            </div>
            <div className="sh shields-grid-container" style={{padding:"px", boxSizing:"border-box"}}>
                             {Array.from({ length: shieldNum }).map((_, index) => (
                                <img key={index} src="SHIELD.png" className="img-full-style" />
                            ))}
            </div>
            <div className="info" style={{display:"flex"}}>
                <div  style={{flex:"1", height:"100%", boxSizing:"border-box"}}>
                    <div  style={{width:"100%", height:"50%", }}> <h3 style={{textAlign:"center", fontFamily:"OL", fontWeight:"100", color:"white", fontSize:"0.9cqw"}}>Outpost ID: <br/><br/> 4</h3>   </div>
                    <div  style={{width:"100%", height:"50%",}}></div>
                </div>
                <div onMouseEnter={() => {setButtonIndex(3)}} onMouseLeave={() => {setButtonIndex(1)}} style={{flex:"1", height:"100%",  boxSizing:"border-box"}}>
                    <div  style={{width:"100%", height:"50%", }}> <h3 style={{ textAlign:"center", fontFamily:"OL", fontWeight:"100", color:"white", fontSize:"0.9cqw"}}>Coordinates: <br/><br/>X: 5312, Y: 5736</h3>    </div>
                    <div  style={{width:"100%", height:"50%",  display:"flex", justifyContent:"center", alignItems:"center"}}> 
                        {buttonIndex === 3 && <div className="global-button-style" style={{height:"50%", padding:"5px 10px", boxSizing:"border-box",fontSize:"0.6cqw", display:"flex", justifyContent:"center", alignItems:"center"}}> <h2>Go here</h2></div> }
                    </div>
                </div>
                <div onMouseEnter={() => {setButtonIndex(4)}} onMouseLeave={() => {setButtonIndex(1)}} style={{flex:"1", height:"100%", boxSizing:"border-box"}}>
                    <div  style={{width:"100%", height:"50%",}}><h3 style={{ textAlign:"center", fontFamily:"OL", fontWeight:"100", color:"white", fontSize:"0.9cqw"}}>Reinforcements: <br/><br/>20</h3> </div>
                    <div  style={{width:"100%", height:"50%", display:"flex", justifyContent:"center", alignItems:"center",flexDirection:"column"}}>
                        {buttonIndex === 4 && ( <>
                               <div style={{height:"50%", width:"100%",padding:"5%" , display:"flex", justifyContent:"space-around", alignItems:"center"}}>
                               <div className="global-button-style" style={{height:"100%", textAlign:"center",  boxSizing:"border-box"}}>
                                   <img src="/minus.png" alt="minus" style={{width: "100%", height: "100%"}}/>
                               </div>
                               <h2 style={{color:"white", fontSize:"2cqw"}}>{amountToReinforce}</h2>
                               <div className="global-button-style" style={{height:"100%", textAlign:"center",  boxSizing:"border-box"}}>
                                   <img src="/plus.png" alt="plus" style={{width: "100%", height: "100%"}}/>
                               </div>
                           </div>
                           <div className="global-button-style" style={{height:"50%", textAlign:"center", padding:"5px 10px", boxSizing:"border-box", fontSize:"0.6cqw", display:"flex", justifyContent:"center", alignItems:"center"}}>  <h2>Reinforce</h2></div>
                           </>)}
                      </div>
                </div>
            </div>
            <div className="sell" style={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                {buttonIndex !== 0 && <div className="global-button-style" style={{padding:"5px 10px", fontSize:"0.9cqw"}}>SELL</div>}
            </div>
        </div>
    );
};






