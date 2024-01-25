//libs
import React, { useState, useEffect } from "react";

//components
import { LoadingComponent } from "./loadingComponent";
import { LoginComponent } from "./loginComponent";
import { PrepPhaseManager } from "./PrepPhasePages/prepPhaseManager";
import { GamePhaseManager } from "./Pages/gamePhaseManager";
import { ClickWrapper } from "./clickWrapper";

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

  //fps counter
  const [fps, setFPS] = useState<number>(0);
  useEffect(() => {
    let frames = 0;
    let lastTimestamp = performance.now();

    const updateFPS = () => {
      const currentTimestamp = performance.now();
      const elapsed = currentTimestamp - lastTimestamp;

      frames += 1;

      if (elapsed >= 1000) {
        const newFPS = Math.round((frames * 1000) / elapsed);
        setFPS(newFPS);
        frames = 0;
        lastTimestamp = currentTimestamp;
      }

      requestAnimationFrame(updateFPS);
    };

    const animationFrameId = requestAnimationFrame(updateFPS);

    return () => cancelAnimationFrame(animationFrameId);
  }, []);

  // this makes sure the context menu doesnt pop up
  useEffect(() => {
    const disableContextMenu = (e: Event) => {
      e.preventDefault();
    };

    document.addEventListener('contextmenu', disableContextMenu);

    return () => {
      document.removeEventListener('contextmenu', disableContextMenu);
    };
  }, []);


  return (
    <>
      {phase === Phase.LOGIN && <LoginComponent setUIState={setUIState}/>}
      {phase === Phase.LOADING && <LoadingComponent setUIState={setUIState}/>}
      {phase === Phase.PREP && <PrepPhaseManager setUIState={setUIState}/>}
      {phase === Phase.GAME && <GamePhaseManager />}

      <ClickWrapper style={{ position: "absolute", bottom: "5px", left: "5px", fontFamily: "OL", fontSize: "0.5vw", color: "white" }} className="opacity-login-screen">
        Date of Version: 25th Jan<br />
        Branch: dev<br />
        Pull: demo test 2: trades fix<br />
        FPS: {fps}
      </ClickWrapper>

      <ClickWrapper style={{ position: "absolute", bottom: "10px", right: "10px", fontFamily: "OL", color: "white" }}>
        <h2 className="global-button-style invert-colors no-margin test-h3" style={{ padding: "2px 5px" }} onClick={() => window.open('https://docs.google.com/forms/d/e/1FAIpQLSc7HVQCyTLgAgbP1sIDhg7O0Dfz9Lrk9ZYnSGnljPj6lJv1zA/viewform', '_blank')}>
          Give Feedback
        </h2>
      </ClickWrapper>
    </>
  );
};

export default PhaseManager;
