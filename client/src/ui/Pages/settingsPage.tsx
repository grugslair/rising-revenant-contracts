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


//elements/components

//pages

/*notes
    should be divide in two sections 

    one for the hold of all of the transactions done this session, this will be a dict somewhere in the codebase with the key being the tx hash and the value being the current state
    this will all be set via a promise?

    the other section is a list of setting for the player to deal with camera speed and stuff like that, no real query needed for this one
*/
{/* <div style={{ height: "100%", width: "40%", padding: "2% 2%", boxSizing: "border-box", overflowY: "auto", scrollbarGutter: "stable both-edges", border: "2px solid var(--borderColour)" }}>
                    {clientTransactionsQuery.map((transactionId, index) => (
                        <TransactionDataElement key={index} entityId={transactionId} />
                    ))}
                </div> */}

interface SettingPageProps {
    setUIState: () => void;
}

export const SettingsPage: React.FC<SettingPageProps> = ({ setUIState }) => {

    const [checkboxChecked, setCheckboxChecked] = useState(true);
    const [switchChecked, setSwitchChecked] = useState(true);
    const [sliderValue, setSliderValue] = useState(20);

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    useEffect(() => {
        setRefreshOwnOutpostDataTimer(sliderValue);
    }, [sliderValue])

    // this needs to be custom hooked
    const clientTransactionsQuery = useEntityQuery([Has(clientComponents.ClientTransaction)]);

    return (
        <div className="game-page-container">
            <img className="page-img brightness-down" src="Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />

            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"SETTINGS"} rightPicture={"Icons/close_icon.png"} rightImageFunction={setUIState} />

            <ClickWrapper style={{ position: "relative", width: "100%", height: "75%", display: "flex", flexDirection: "row", boxSizing: "border-box", color: "white", backgroundColor: "red" }}>
                <div style={{ flex: "1.5", height: "100%", backgroundColor: "blue" }}></div>
                <div style={{ flex: "8", height: "100%", backgroundColor: "purple" }}>
                    <h1 className="test-h1-5" style={{ textDecoration: "underline", marginTop: "0px" }}>Game</h1>
                    <SettingCheckboxElement component={clientComponents.ClientGameData} variable="guest" />

                    <h1 className="test-h1-5" style={{ textDecoration: "underline" }}>Phaser</h1>
                </div>
                <div style={{ flex: "1", height: "100%", backgroundColor: "blue" }}></div>
                <div style={{ flex: "5.5", height: "100%", backgroundColor: "purple" }}>
                    <div style={{ width: "100%", height: "8%", backgroundColor: "red" }}>
                        <h1 className="test-h1-5" style={{ textDecoration: "underline", marginTop: "0px" }}>Transaction Details</h1>
                    </div>

                    <div style={{ height: "92%", width: "100%", padding: "2% 2%", boxSizing: "border-box", overflowY: "auto", scrollbarGutter: "stable both-edges", border: "2px solid var(--borderColour)" }}>
                        {clientTransactionsQuery.map((transactionId, index) => (
                            <TransactionDataElement key={index} entityId={transactionId} />
                        ))}
                    </div>
                </div>
                <div style={{ flex: "0.5", height: "100%", backgroundColor: "blue" }}></div>
            </ClickWrapper>
        </div>
    );
};


export const TransactionDataElement: React.FC<{ entityId }> = ({ entityId }) => {

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    const transactionData = useComponentValue(clientComponents.ClientTransaction, entityId);

    const openVoyager = () => {
        window.open(`https://voyager.online/tx/${transactionData!.txHash}`, '_blank');
    };

    return (
        <div style={{ position: "relative", height: "120px", width: "100%", borderRadius: "5px", marginBottom: "10px", padding: "10px 15px", color: "white", border: "2px solid var(--borderColour)", boxSizing: "border-box", display: "flex", flexDirection: "column" }}>

            <div style={{ height: "25%", width: "100%", backgroundColor: "red", display: "flex", justifyContent: "space-between", alignItems: "center" }}>

                {transactionData!.state === 1 && <h2 className="test-h2 no-margin">PENDING</h2>}
                {transactionData!.state === 2 && <h2 className="test-h2 no-margin">REJECTED</h2>}
                {transactionData!.state === 3 && <h2 className="test-h2 no-margin">PASSED</h2>}
                {transactionData!.state === 4 && <h2 className="test-h2 no-margin">ERROR</h2>}
                <Tooltip title="WEN MAINET!!!!!   (DISABLED)">
                    <div style={{ padding: "0px 5px", height: "100%", backgroundColor: "#909090" }} className="center-via-flex">
                        <h3 className="test-h3 no-margin pointer">See on Voyager</h3>
                    </div>
                </Tooltip>
            </div>
            <div style={{ height: "5%", width: "100%", backgroundColor: "yellow" }}></div>
            <div style={{ height: "70%", width: "100%", backgroundColor: "red", }}>
                <h3 className="test-h3 no-margin pointer" onClick={() => navigator.clipboard.writeText(transactionData!.txHash)} style={{ whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", margin: "2px 0px" }}>
                    {transactionData!.txHash}
                </h3>
                <h3 className="test-h3 no-margin" style={{ overflow: "hidden", textOverflow: "ellipsis" }}>
                    {transactionData!.message}
                </h3>
            </div>

        </div>
    );
};

export const SettingSliderElement: React.FC = () => {

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    return (
        <div style={{}}></div>
    );
};


interface SettingCheckboxElementProps {
    component: any,
    variable: string,
}

export const SettingCheckboxElement: React.FC<SettingCheckboxElementProps> = ({ component, variable }) => {

    const [checkbox, setCheckbox] = useState<boolean>(() => {
        return getComponentValueStrict(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]))[variable] as boolean;
    });

    useEffect(() => {
        const updateData: { [key: string]: any } = {};
        updateData[variable] = checkbox;

        updateComponent(component, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), updateData);
    }, [checkbox]);

    return (
        <ClickWrapper style={{ display: "flex", justifyContent: "space-between", flexDirection: "row", height: "fit-content", width: "100%" }}>
            <h2 className="test-h2 no-margin">Turn off warning system</h2>
            <div onClick={() => setCheckbox(!checkbox)} className="pointer" style={{ height: "clamp(0.8rem, 0.7vw + 0.7rem, 7rem)", aspectRatio: "1/1", backgroundColor: `${checkbox ? "green" : "red"}` }}></div>
        </ClickWrapper>
    );
};


