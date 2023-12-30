//libs
import React, { useState, useEffect } from "react";

//components
import { LoadingComponent } from "./loadingComponent";
import { LoginComponent } from "./loginComponent";
import { PrepPhaseManager } from "./PrepPhasePages/prepPhaseManager";
import { GamePhaseManager } from "./Pages/gamePhaseManager";

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
      {phase === Phase.LOGIN && <LoginComponent setUIState={setUIState}/>}
      {phase === Phase.LOADING && <LoadingComponent setUIState={setUIState}/>}
      {phase === Phase.PREP && <PrepPhaseManager setUIState={setUIState}/>}
      {phase === Phase.GAME && <GamePhaseManager />}

      <div style={{ position: "absolute", bottom: "10px", left: "10px", fontFamily: "OL", fontSize: "1rem", color: "white" }}>

            Date of Version: 30th Dec<br/>
            Branch: dev<br/>
            Pull: call dojo fix 4
      </div>
    </>
  );
};

export default PhaseManager;
