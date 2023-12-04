import React, { useEffect } from "react";

import { Phase } from "./phaseManager";
import { useDojo } from "../hooks/useDojo";

interface LoadingPageProps {
  setUIState: React.Dispatch<Phase>;
}

export const LoadingComponent: React.FC<LoadingPageProps> = ({ setUIState }) =>{

  //https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel/preload
  // this is to preload

  // this will have the vid of the loading thing in the middle
  // this will first load in the phase of the game which will then dictate what actually gets loaded in

  // if in phase prep only load in the users outposts and the player data

  //else load in everything

  const {
    account: { account },
    networkLayer: {
      network: { contractComponents, clientComponents },
    },
  } = useDojo();


  const loadingFunction = async () => {
    //first of all fetch the game counter
    

    //for debug purposes this is where we create the game if necessary 


    //then fetch the game comp

    //game entity comp


    // depending on the phase load in the correct stuff

  }

  useEffect(() => {
    loadingFunction();
  }, []);

  // this is just a test do delete when in actual build
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
