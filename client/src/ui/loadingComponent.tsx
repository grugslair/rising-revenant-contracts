import React, { useEffect } from "react";

import { Phase } from "./phaseManager";

interface LoadingPageProps {
  setUIState: React.Dispatch<Phase>;
}

export const LoadingComponent: React.FC<LoadingPageProps> = ({ setUIState }) =>{

  // this will have the vid of the loading thing in the middle
  // this will first load in the phase of the game which will then dictate what actually gets loaded in

  useEffect(() => {
    const timer = setTimeout(() => {
      setUIState(Phase.PREP);
    }, 5000);

    return () => {
      clearTimeout(timer);
    };
  }, []);

  return (
    <div className="centered-div" style={{width:"100%", height:"100%", display: "flex", justifyContent: "center", alignItems: "center" }}>
      <video
        autoPlay
        loop
        muted
        style={{ maxWidth: "100%", maxHeight: "100%" }}
      >
        <source src="videos/LoadingAnim.webm" type="video/webm" />
      </video>
    </div>
  );
};
