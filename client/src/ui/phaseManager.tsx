//libs
import React, { useState, useEffect } from "react";

//components
import { LoadingComponent } from "./loadingComponent";
import { LoginComponent } from "./loginComponent";
import { PrepPhaseManager } from "./PrepPhasePages/prepPhaseManager";
import { GamePhaseManager } from "./Pages/gamePhaseManager";
import { ClickWrapper } from "./clickWrapper";

//notes
/*
    This component will render different pages based on the current phase.
    It may involve loading screens for certain phases.

    // i think this should have a timer if in the prep phase to see if it should go in the next phase
    something along the lines of checking the block count anyway
*/

export enum Phase {
  LOGIN,
  LOADING,
  PREP,
  GAME,
}

export const PhaseManager = () => {
  const [phase, setPhase] = useState<Phase>(Phase.LOGIN);
  const [soundOn, setSoundOn] = useState<Boolean>(true);

  const setUIState = (state: Phase) => {
    setPhase(state);
  }

  const playClickSound = () => {
    if (soundOn) {
      const audio = new Audio("/sounds/click.wav");
      audio.currentTime = 0;
      audio.play();
    }
  };

  useEffect(() => {
    document.addEventListener('click', playClickSound);
    return () => {
      document.removeEventListener('click', playClickSound);
    };
  }, [soundOn]);

  return (
    <>
      {phase === Phase.LOGIN && <LoginComponent setUIState={setUIState} />}
      {phase === Phase.LOADING && <LoadingComponent setUIState={setUIState} />}
      {phase === Phase.PREP && <PrepPhaseManager setUIState={setUIState} />}
      {phase === Phase.GAME && <GamePhaseManager />}

      <div style={{ position: "absolute", bottom: "10px", left: "10px", fontFamily: "OL", fontSize: "0.7vw", color: "white" }}>
        Date of Version: 6th Jan<br />
        Branch: main<br />
        Pull: Refresh of trades and stats 
      </div>

      <ClickWrapper style={{ position: "absolute", bottom: "10px", right: "10px", fontFamily: "OL", color: "white" }}>
        <h2 className="global-button-style no-margin test-h2" style={{ padding: "2px 5px" }} onClick={() => window.open('https://docs.google.com/forms/d/e/1FAIpQLSc7HVQCyTLgAgbP1sIDhg7O0Dfz9Lrk9ZYnSGnljPj6lJv1zA/viewform', '_blank')}>
          Give Feedback
        </h2>
      </ClickWrapper>

      {/* <div style={{ position: "absolute", top: "0px", left: "0px" }}>
          <img src="unmuted.png" alt="" style={{width:"100%", height:"100%"}} />
      </div> */}
    </>
  );
};

export default PhaseManager;
