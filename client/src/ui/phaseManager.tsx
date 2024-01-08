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

  const setUIState = (state: Phase) => {
    setPhase(state);
  }

  return (
    <>
      {phase === Phase.LOGIN && <LoginComponent setUIState={setUIState} />}
      {phase === Phase.LOADING && <LoadingComponent setUIState={setUIState} />}
      {phase === Phase.PREP && <PrepPhaseManager setUIState={setUIState} />}
      {phase === Phase.GAME && <GamePhaseManager />}

      <div style={{ position: "absolute", bottom: "10px", left: "10px", fontFamily: "OL", fontSize: "0.7vw", color: "white" }}>
        Date of Version: 8th Jan<br />
        Branch: main<br />
        Pull: demo test 6 no debug
      </div>

      <ClickWrapper style={{ position: "absolute", bottom: "10px", right: "10px", fontFamily: "OL", color: "white" }}>
        <h2 className="global-button-style no-margin test-h2" style={{ padding: "2px 5px" }} onClick={() => window.open('https://docs.google.com/forms/d/e/1FAIpQLSc7HVQCyTLgAgbP1sIDhg7O0Dfz9Lrk9ZYnSGnljPj6lJv1zA/viewform', '_blank')}>
          Give Feedback
        </h2>
      </ClickWrapper>
    </>
  );
};

export default PhaseManager;
