//libs
import React, { useState } from "react";
import { MenuState } from "./gamePhaseManager";

//styles
import "./PagesStyles/RulesPageStyles.css"
import PageTitleElement, { ImagesPosition } from "../Elements/pageTitleElement";
import { ClickWrapper } from "../clickWrapper";

//elements/components

//pages

/*notes
should just be a block of text with the rules not really much to do here
only issue might be with the set menu state
*/
enum RulesState {
    PREP = 0,
    GAME = 1,
    CONTRIB = 2,
    FINAL = 3,
}

interface RulesPageProps {
    setUIState: () => void;
}

export const RulesPage: React.FC<RulesPageProps> = ({ setUIState }) => {
    //could query game phase at start
    const [rulesState, setRulesState] = useState<RulesState>(RulesState.PREP);

    return (
        <div className="game-page-container">
            <img className="page-img brightness-down" src="./Page_Bg/RULES_PAGE_BG.png" alt="testPic" />
            
            <PageTitleElement imagePosition={ImagesPosition.RIGHT} name={"RULES"} rightPicture={"Icons/close_icon.png"} rightImageFunction={setUIState} />

            <ClickWrapper style={{ display: "grid",  gridTemplateColumns:"1fr 1fr", gridTemplateRows:"1fr 1fr", gap: "10px", position: "relative", width: "60%", height: "15%", marginLeft:"20%", boxSizing: "border-box" }}>
                <div className="global-button-style center-via-flex" style={{ gridRow:"1", gridColumn:"1" }} >
                    <h2 className="test-h2 no-margin" onClick={() => { setRulesState(RulesState.PREP) }} style={{ opacity: rulesState !== RulesState.PREP ? 0.5 : 1, textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "0px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>PREP PHASE</h2>
                </div >
                <div className="global-button-style center-via-flex"  style={{ gridRow:"1", gridColumn:"2" }}>
                    <h2 className="test-h2 no-margin" onClick={() => { setRulesState(RulesState.GAME) }} style={{ opacity: rulesState !== RulesState.GAME ? 0.5 : 1, textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "0px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>GAME PHASE</h2>
                </div>
                <div className="global-button-style center-via-flex"  style={{ gridRow:"2", gridColumn:"2" }}>
                    <h2 className="test-h2 no-margin" onClick={() => { setRulesState(RulesState.FINAL) }} style={{ opacity: rulesState !== RulesState.FINAL ? 0.5 : 1, textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "0px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>FINAL REWARD</h2>
                </div>
                <div className="global-button-style center-via-flex"  style={{ gridRow:"2", gridColumn:"1" }}>
                    <h2 className="test-h2 no-margin" onClick={() => { setRulesState(RulesState.CONTRIB) }} style={{ opacity: rulesState !== RulesState.CONTRIB ? 0.5 : 1, textAlign: "center", display: "flex", justifyContent: "center", alignItems: "center", padding: "0px 20px", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>CONTRIBUTION</h2>
                </div>
            </ClickWrapper>


            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>
            <ClickWrapper style={{ width: "100%", height: "65%", position: "relative"}} className="center-via-flex" >

                    <div style={{height: "90%",width:"5%"}} className="center-via-flex">
                        {rulesState !== RulesState.PREP && <img style={{width:"75%", aspectRatio:"1/1"}} onClick={() => {setRulesState(prevState => prevState - 1)}} className="pointer" src="Icons/left-arrow.png"></img>}
                    </div>
                <div style={{ width: "60%", height: "100%", color: "white", fontFamily: "OL", display:"flex", flexDirection:"row", justifyContent:"center"}}>

                    <div style={{height: "90%",width:"90%", color: "white", fontFamily: "OL", overflowY: "auto", scrollbarGutter: "stable", paddingRight: "5px"}}>
                    {rulesState === RulesState.PREP && (<>
                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Summoning the Revenants:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3"> Players begin by summoning Revenants, powerful entities, through a mystical expenditure of $LORDS. Each successful summoning not only brings forth a Revenant but also establishes an Outpost around the game map.</h3>

                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Building Outposts:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">These bastions of power will initially have 1 health. Following a Revenant's summoning, players may fortify these Outposts in the following phase.</h3>

                        <h2 style={{ marginBottom: "0px", fontWeight: "bold" , textDecoration:"underline" }} className="test-h2">Fortifying Outposts:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">Outposts, symbols of your burgeoning empire, can be bolstered up to 20 times in their lifetime. The extent of reinforcements directly influences the Outpost’s defense, manifested in the number of shields it wields:<br />
                            1-2 reinforcements: Unshielded<br />
                            3-5 reinforcements: 1 shield<br />
                            6-9 reinforcements: 2 shields<br />
                            9-13 reinforcements: 3 shields<br />
                            14-19 reinforcements: 4 shields<br />
                            20 reinforcements: 5 shields</h3>

                        <h2 style={{ marginBottom: "0px", fontWeight: "bold" , textDecoration:"underline" }} className="test-h2">The Anticipation Screen:</h2>
                        <h3 style={{ marginTop: "0px"}} className="test-h3">Post-preparation, players enter a phase of strategic anticipation. Here, the summoning of new Revenants and bolstering of Outposts continues, setting the stage for the impending Main Phase.</h3>
                    </>)}

                    {rulesState === RulesState.GAME && (<>
                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Commencing the Main Phase:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3"> Following the initial phase, the game escalates into a whirlwind of action, marked by attacks and disorder.</h3>

                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"   }} className="test-h2">Diverse Attacks:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">Players must confront challenges ranging from cataclysmic natural disasters to the fiery wrath of dragons and the cunning onslaught of goblins.</h3>

                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Endurance of Outposts:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3"> The resilience of an Outpost is key, with its survival odds escalating with every reinforcement. The ultimate ambition? To stand as the last Rising Revenant.</h3>
                    </>)}

                    {rulesState === RulesState.FINAL && (<>
                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"   }} className="test-h2">Final Rewards:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">The Ultimate Prize: The games transactions feed into a colossal final jackpot, destined for the sole Revenant who outlasts all others.</h3>
                        <h2></h2>
                        <h2 style={{ marginBottom: "0px" , fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Economic Dynamics of "Rising Revenant":</h2>
                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline"   }} className="test-h2">Preparation Phase:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">75% of $LORDS channeled into the final jackpot <br /> 10% allocated to transaction confirmation <br /> 15% as a creator tribute</h3>

                        <h2 style={{ marginBottom: "0px" , fontWeight: "bold", textDecoration:"underline"  }} className="test-h2">Main Phase:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3"> 90% of $LORDS flows to the trader <br /> 5% augments the final jackpot <br /> 5% reserved as a lasting reward for the enduring players</h3>

                        <h2 style={{ marginBottom: "0px" , fontWeight: "bold", textDecoration:"underline"  }} className="test-h2"></h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3">These rules are your compass in the world of "Rising Revenant," guiding you through a labyrinth of summoning, defense, and cunning trade to claim the crown of the ultimate survivor.</h3>
                    </>)}

                    {rulesState === RulesState.CONTRIB && (<>
                        <h2 style={{ marginBottom: "0px", fontWeight: "bold", textDecoration:"underline" }} className="test-h2">Contribution:</h2>
                        <h3 style={{ marginTop: "0px" }} className="test-h3"> In our game, "contribution" refers to a player's active engagement in verifying in-game events on the blockchain. Contributors, who validate at least one event, become eligible for a share of the "contribution jackpot", which is separate from the main prize upon the game's conclusion.</h3>
                    </>)}
                    </div>
                   
                  
                </div>
                <div style={{height: "90%",width:"5%"}} className="center-via-flex">
                        {rulesState !== RulesState.FINAL && <img style={{width:"75%", aspectRatio:"1/1"}} onClick={() => {setRulesState(prevState => prevState + 1)}} src="Icons/right-arrow.png" className="pointer"></img>}
                    </div>
            </ClickWrapper>
            <div style={{ width: "100%", height: "5%", position: "relative" }}></div>
        </div>
    )
}