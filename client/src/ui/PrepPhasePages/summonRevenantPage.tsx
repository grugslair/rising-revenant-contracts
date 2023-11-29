import React, { useEffect, useState } from "react";
import { useDojo } from "../../hooks/useDojo";
import { CreateGameProps, CreateRevenantProps } from "../../dojo/types";
import { PrepPhaseStages } from "./prepPhaseManager";

import { HasValue, EntityIndex, getComponentValueStrict, setComponent } from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";

import "./PagesStyles/BuyingPageStyle.css"

import { ClickWrapper } from "../clickWrapper";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG } from "../../phaser/constants";

import CounterElement from "../Elements/counterElement";

interface BuyRevenantPageProps {
    setMenuState: React.Dispatch<PrepPhaseStages>;
}


const IMAGES = ["./revenants/1.png", "./revenants/2.png", "./revenants/3.png", "./revenants/4.png", "./revenants/5.png"]

export const BuyRevenantPage: React.FC<BuyRevenantPageProps> = ({ setMenuState }) => {
    const [revenantNumber, setRevenantNumber] = useState(5);
    const [revenantCost, setRevenantCost] = useState(10);

    const [backgroundImage, setBackgroundImage] = useState("");

    const [ownReveants, setOwnRevenants] = useState(2);  // this is to delete just for debug purposr

    // const {
    //     account: { account },
    //     networkLayer: {
    //         network: { contractComponents, clientComponents },
    //         systemCalls: { create_revenant },
    //     },
    // } = useDojo();

    // at the start choose from the random images to load in 
    useEffect(() => {
        const randomImage = IMAGES[Math.floor(Math.random() * IMAGES.length)];
        setBackgroundImage(`${randomImage}`);
      }, []);

    const summonRev = async (num : number) => {
        // const gameTrackerComp = getComponentValueStrict(
        //   contractComponents.GameTracker,
        //   getEntityIdFromKeys([BigInt(GAME_CONFIG)])
        // );
        // const game_id: number = gameTrackerComp.count;

        // const gameEntityCounter = getComponentValueStrict(
        //   contractComponents.GameEntityCounter,
        //   getEntityIdFromKeys([BigInt(game_id)])
        // );
        // const rev_counter: number = gameEntityCounter.outpost_count;

        // for (let index = 0; index < num; index++) {
        //     const createRevProps: CreateRevenantProps = {
        //         account: account,
        //         game_id: game_id,
        //         name: "Revenant " + rev_counter,
        //       };  

        //       await create_revenant(createRevProps);
        // }

        setMenuState(PrepPhaseStages.WAIT_TRANSACTION);
      };

    // const ownReveants = useEntityQuery([HasValue(contractComponents.Outpost, { owner: account.address })]);

    return (
        <div className="summon-revenant-page-container" >
            <img className="br-page-container-img" src={`${backgroundImage}`}  alt="testPic" />
            <ClickWrapper className="main-content">
                <h2 className="main-content-header" style={{fontSize:"2.5cqw"}}>SUMMON A REVENANT</h2>

                <CounterElement value={revenantNumber} setValue={setRevenantNumber}/>

                <div className="global-button-style" style={{fontSize:"1.3cqw", padding:"5px 10px"}} onMouseDown={() => {summonRev(revenantNumber)}}>Summon (Tot: {revenantNumber * revenantCost} $Lords)</div>
            </ClickWrapper>
            <div className="footer-text-section" >
                <div className="price-text"> 1 Revenant = {revenantCost} $LORDS</div>
                <ClickWrapper onMouseDown={() => {setMenuState(PrepPhaseStages.BUY_REIN);}} className="global-button-style forward-button" 
                style={{padding:"5px 10px", fontSize:"1.3cqw"}}
                > Buy Reinforcements 

                <img className="embedded-text-icon" src="Icons/Symbols/right_arrow.svg" alt="Sort Data" onMouseDown={() => {}} /> 
                </ClickWrapper>
            </div>
        </div>
    )
}
