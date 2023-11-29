import React, { useState } from "react";
import { PrepPhaseStages } from "./prepPhaseManager";

import "./PagesStyles/BuyingPageStyle.css"

// import { PurchaseReinforcementProps } from "../../dojo/types";
import { ClickWrapper } from "../clickWrapper";
// import { useDojo } from "../../hooks/useDojo";

import CounterElement from "../Elements/counterElement";


import { toast } from 'react-toastify';


interface BuyReinforcementsPageProps {
    setMenuState: React.Dispatch<PrepPhaseStages>;
}

const notify = (message: string) => toast(message, {
    position: "top-left",
    autoClose: 5000,
    hideProgressBar: false,
    closeOnClick: true,
    pauseOnHover: true,
    draggable: true,
    progress: undefined,
    theme: "dark",
});

export const BuyReinforcementPage: React.FC<BuyReinforcementsPageProps> = ({ setMenuState }) => {
    const [reinforcementNumber, setReinforcementNumber] = useState(2);
    const [priceOfReinforcements, setPriceOfReinforcements] = useState(5);

    // const {
    //     account: { account },
    //     networkLayer: {
    //         systemCalls: { purchase_reinforcement },
    //     },
    // } = useDojo()

    const buyReinforcements = async (num: number) => {

        // const purchaseReinforcementProps: PurchaseReinforcementProps = {
        //     account: account,
        //     game_id: 1,
        //     count: num,
        // }

        // await purchase_reinforcement(purchaseReinforcementProps);
    }

    return (
        <div className="br-page-container">
            <img className="br-page-container-img " src="./assets/Page_Bg/REINFORCEMENTS_PAGE_BG.png"  alt="testPic" />
            <ClickWrapper className="main-content">
                <h2 className="main-content-header">REINFORCE YOUR OUTPOST</h2>
                <CounterElement value={reinforcementNumber} setValue={setReinforcementNumber} />
                <div className="global-button-style"  style={{ padding:"5px 10px",  fontSize:"1.3cqw" }}onMouseDown={() => { buyReinforcements(reinforcementNumber) }}> Reinforce (Tot: {priceOfReinforcements * reinforcementNumber} $LORDS)</div>
            </ClickWrapper>
            <div className="footer-text-section" >
                <div className="price-text"> 1 Reinforcement = {priceOfReinforcements} $LORDS</div>
                <ClickWrapper onMouseDown={() => {setMenuState(PrepPhaseStages.WAIT_PHASE_OVER);}} className="global-button-style forward-button"
                style={{ padding:"5px 10px",  fontSize:"1.3cqw" }} > Continue 

            <img className="embedded-text-icon" src="Icons/Symbols/right_arrow.svg" alt="Sort Data" onMouseDown={() => {}} /> 
                </ClickWrapper>
            </div>
            <ClickWrapper onMouseDown={() => {setMenuState(PrepPhaseStages.BUY_REVS);}} className="global-button-style" 
            style={{position:"absolute", left:"5%", top:"2%",display:"flex", padding:"5px 10px",  fontSize:"1.3cqw" }}> 
            
            <img className="embedded-text-icon" src="Icons/Symbols/left_arrow.svg" alt="Sort Data" onMouseDown={() => {}} /> 
                Summon more Revenants
            </ClickWrapper>

        </div>
    )
}
