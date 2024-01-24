//libs
import React, { useState, useEffect } from "react";
import { useEntityQuery, useComponentValue } from '@latticexyz/react';
import {
    Has,
    getComponentValueStrict,
    updateComponent
} from "@latticexyz/recs";
import PageTitleElement, { ImagesPosition } from "../Elements/pageTitleElement";
import { ClickWrapper } from "../clickWrapper";
import { Tooltip } from "@mui/material";
import { GAME_CONFIG_ID, setRefreshOwnOutpostDataTimer } from "../../utils/settingsConstants";
import { useDojo } from "../../hooks/useDojo";

//styles
import "./PagesStyles/SettingPageStyle.css";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import CustomSlider from "../Elements/sliderElement";


//elements/components

//pages

/*notes
    should be divide in two sections 

    one for the hold of all of the transactions done this session, this will be a dict somewhere in the codebase with the key being the tx hash and the value being the current state
    this will all be set via a promise?

    the other section is a list of setting for the player to deal with camera speed and stuff like that, no real query needed for this one
*/


interface SettingPageProps {
    setUIState: () => void;
    clientComponents: any;
    contractComponents: any;
}

export const SettingsPage: React.FC<SettingPageProps> = ({ setUIState, clientComponents, contractComponents }) => {


    const clientTransactionsQuery = useEntityQuery([Has(clientComponents.ClientTransaction)], {
        updateOnValueChange: false,
    });

    return (
        <div className="game-page-container">
            <img className="page-img brightness-down" src="Page_Bg/SETTINGS_PAGE_BG.png" alt="testPic" />

            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"SETTINGS"} rightPicture={"Icons/close_icon.png"} rightImageFunction={setUIState} />

            <ClickWrapper style={{ position: "relative", width: "100%", height: "75%", display: "flex", flexDirection: "row", boxSizing: "border-box", color: "white" }}>
                <div style={{ flex: "1.5", height: "100%" }}></div>

                <div style={{ flex: "8", display: "grid", gridTemplateColumns: "1fr", gridGap: "30px", height: "100%", overflowY: "auto", scrollbarGutter: "stable both-edges", paddingRight: "1%" }}>
                    <h1 className="test-h1-5" style={{ textDecoration: "underline", height: "fit-content", marginTop:"0px", marginBottom: "10px", gridRow: "span 1" }}>Game</h1>
                    <SettingCheckboxElement component={clientComponents.ClientGameData} variable="guest" text="Turn off warning system" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Volume" />
                    <SettingCheckboxElement component={clientComponents.ClientGameData} variable="guest" text="Update interval" />
                    <h1 className="test-h1-5" style={{ textDecoration: "underline", height: "110%", marginBottom: "10px", gridRow: "span 2" }}>Phaser</h1>
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Camera Speed" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Zoom Multiplier" />
                    <SettingCheckboxElement component={clientComponents.ClientOutpostViewSettings} variable="hide_others_outposts" text="Hide other's outposts" />
                    <SettingCheckboxElement component={clientComponents.ClientOutpostViewSettings} variable="hide_dead_ones" text="Hide dead ones" />
                    <SettingCheckboxElement component={clientComponents.ClientOutpostViewSettings} variable="show_your_everywhere" text="Show yours everywhere" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Increase the chunk loading size" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Increase view range" />
                    <SettingCheckboxElement component={clientComponents.ClientGameData} variable="guest" text="Take out anim on outposts" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Max amount of revs visible" />
                    <SettingCheckboxElement component={clientComponents.ClientGameData} variable="guest" text="Invert drag" />
                    <SettingSliderElement component={clientComponents.ClientSettings} variable="volume" minVal={0} maxVal={100} text="Drag speed" />
                </div>
                <div style={{ flex: "1", height: "100%" }}></div>
                <div style={{ flex: "5.5", height: "100%" }}>
                    <div style={{ width: "100%", height: "8%" }}>
                        <h1 className="test-h1-5" style={{ textDecoration: "underline", marginTop: "0px" }}>Transaction Details</h1>
                    </div>

                    <div style={{ height: "92%", width: "100%", padding: "3% 2%", boxSizing: "border-box", overflowY: "auto", scrollbarGutter: "stable both-edges", border: "2px solid var(--borderColour)" }}>
                        {clientTransactionsQuery.map((transactionId, index) => (
                            <TransactionDataElement key={index} entityId={transactionId} clientComponents={clientComponents} />
                        ))}
                    </div>
                </div>
                <div style={{ flex: "0.5", height: "100%" }}></div>
            </ClickWrapper>
        </div>
    );
};


export const TransactionDataElement: React.FC<{ entityId, clientComponents }> = ({ entityId, clientComponents }) => {

    const transactionData = useComponentValue(clientComponents.ClientTransaction, entityId);

    const openVoyager = () => {
        window.open(`https://voyager.online/tx/${transactionData!.txHash}`, '_blank');
    };

    return (
        <div style={{ position: "relative", height: "140px", width: "100%", borderRadius: "5px", marginBottom: "15px", padding: "10px 15px", color: "white", border: "2px solid var(--borderColour)", boxSizing: "border-box", display: "flex", flexDirection: "column" }}>

            <div style={{ height: "25%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center" }}>

                {transactionData!.state === 1 && <h2 className="test-h2 no-margin">PENDING</h2>}
                {transactionData!.state === 2 && <h2 className="test-h2 no-margin">REJECTED</h2>}
                {transactionData!.state === 3 && <h2 className="test-h2 no-margin">PASSED</h2>}
                {transactionData!.state === 4 && <h2 className="test-h2 no-margin">ERROR</h2>}
                <Tooltip title="WEN MAINNET!!!!!   (DISABLED)">
                    <div style={{ padding: "0px 5px", height: "100%", backgroundColor: "#909090" }} className="center-via-flex">
                        <h3 className="test-h3 no-margin pointer">See on Voyager</h3>
                    </div>
                </Tooltip>
            </div>
            <div style={{ height: "5%", width: "100%" }}></div>
            <div style={{ height: "70%", width: "100%" }}>
                <h3 className="test-h3 no-margin pointer" onClick={() => navigator.clipboard.writeText(transactionData!.txHash)} style={{ whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", margin: "2px 0px" }}>
                    {transactionData!.txHash}
                </h3>
                <h3 className="test-h3 no-margin" style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "pre-line" }}>
                    {transactionData!.message}
                </h3>
            </div>

        </div>
    );
};




interface SettingSliderElementProps {
    containerStyle?: React.CSSProperties;
    component: any,
    variable: string,
    minVal: number,
    maxVal: number,
    text: string,
}

export const SettingSliderElement: React.FC<SettingSliderElementProps> = ({ component, variable, minVal, maxVal, text, containerStyle }) => {

    const [sliderValue, setSliderValue] = useState<number>(getComponentValueStrict(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]))[variable] as number);
    const [isSliderDragging, setIsSliderDragging] = useState(false);

    const handleSliderChange = (value: number) => {
        setSliderValue(value);
    };

    useEffect(() => {
        const updateData: { [key: string]: any } = {};
        updateData[variable] = sliderValue;

        updateComponent(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), updateData);
    }, [isSliderDragging])

    return (
        // settings-option-hover
        <ClickWrapper className="" style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexDirection: "row", height: "fit-content", width: "100%", ...containerStyle }}>
            <h2 className="test-h2 no-margin">{text}</h2>
            <CustomSlider
                minValue={minVal}
                maxValue={maxVal}
                startingValue={sliderValue}
                onChange={handleSliderChange}
                containerStyle={{ width: "100px", height: "clamp(0.5rem, 0.5vw + 0.5rem, 4rem)", display: "flex", justifyContent: "center", alignItems: "center" }}
                trackStyle={{ width: "100%", height: "60%", background: "linear-gradient(to bottom, white 25%, gray 100%)", borderRadius: "5px" }}
                buttonStyle={{ height: "100%", width: "15%", backgroundColor: "black", border: "2px solid white", borderRadius: "10px", boxSizing: "border-box" }}
                precision={0}
                showVal={true}
                onDrag={(isDragging) => setIsSliderDragging(isDragging)}

            />
        </ClickWrapper>
    );
};


interface SettingCheckboxElementProps {
    containerStyle?: React.CSSProperties;
    component: any,
    variable: string,
    text: string,
}
export const SettingCheckboxElement: React.FC<SettingCheckboxElementProps> = ({ component, variable, text, containerStyle }) => {

    const [checkbox, setCheckbox] = useState<boolean>(() => {
        return getComponentValueStrict(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]))[variable] as boolean;
    });

    useEffect(() => {
        const updateData: { [key: string]: any } = {};
        updateData[variable] = checkbox;

        updateComponent(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), updateData);
    }, [checkbox]);

    return (
        // settings-option-hover
        <ClickWrapper className="" style={{ display: "flex", justifyContent: "space-between", alignItems:"center", flexDirection: "row", height: "fit-content", width: "100%", ...containerStyle }}>
            <h2 className="test-h2 no-margin" >{text}</h2>
            <div onClick={() => setCheckbox(!checkbox)} className="pointer center-via-flex" style={{ height: "clamp(0.8rem, 0.7vw + 0.7rem, 7rem)", aspectRatio: "1/1", borderRadius: "5px", background: "linear-gradient(to bottom, white 25%, gray 100%)" }} >
                {checkbox && <img src="Icons/tick.svg" alt="" style={{ width: "100%", height: "100%", margin: "10%", boxSizing: "border-box" }} />}
            </div>
        </ClickWrapper>
    );
};


