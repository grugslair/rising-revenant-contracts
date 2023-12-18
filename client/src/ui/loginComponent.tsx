import React, { useEffect } from "react";
import { MAP_HEIGHT, MAP_WIDTH } from "../phaser/constants";

import { ClickWrapper } from "./clickWrapper";
import { Phase } from "./phaseManager";
import { useDojo } from "../hooks/useDojo";
import { setClientCameraComponent, setClientCameraEntityIndex, setClientClickPositionComponent, setClientGameComponent } from "../utils";

interface LoginPageProps {
  setUIState: React.Dispatch<Phase>;
}

// this needs to set the and prob create the client game comp at least

export const LoginComponent: React.FC<LoginPageProps> = ({ setUIState }) => {

  //for now we use a burner account
  const {
    account: { account, create, isDeploying, clear },
    networkLayer: {
      network: { clientComponents },
    },
  } = useDojo();


  // //testing stuff to delete in the future
  // useEffect(() => {

  //   console.log("\n\n\n\n\n\n");
  //   console.error(isDeploying);
  //   console.log("\n\n\n\n\n\n");

  // }, [isDeploying]);

  //checking if there is already another account, to delete in the future
  // useEffect(() => {

  //   const isLocalStorageEmptyGeneral = Object.keys(localStorage).length === 0;

  //   if (isLocalStorageEmptyGeneral === false) {
  //     createGameClient(false);
  //     setUIState(Phase.LOADING);
  //   }

  // }, []);

  //create the client game comp for the start of the loading
  const createGameClient = async (guest: boolean) => {
    setClientGameComponent(1, 1, 1, guest, 0, clientComponents);
    setClientClickPositionComponent(1, 1, 1, 1, clientComponents);
    setClientCameraComponent(MAP_WIDTH / 2, MAP_HEIGHT / 2, clientComponents);
    setClientCameraEntityIndex(MAP_WIDTH / 2, MAP_HEIGHT / 2, clientComponents)
  }

  return (
    <ClickWrapper className="centered-div" style={{ display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "column", gap: "20px" }}>
      <div style={{ fontFamily: "Zelda", fontWeight: "100", backgroundColor: "white", padding: "5px 10px", fontSize: "3.5cqw", borderRadius: "5px", textAlign: "center", marginBottom: "20px" }}>
        Rising Revenant
      </div>
      <div className="global-button-style" style={{ fontSize: "2.4cqw", padding: "5px 10px", fontFamily: "OL", fontWeight: "100" }} onClick={() => { createGameClient(false); setUIState(Phase.LOADING); }}>
        Wallet Login
      </div>
      <div className="global-button-style" style={{ fontSize: "2.4cqw", padding: "5px 10px", fontFamily: "OL", fontWeight: "100" }} onClick={() => { createGameClient(true); setUIState(Phase.LOADING); }}>
        Guest Login
      </div>

      <div className="global-button-style" style={{ fontSize: "2.4cqw", padding: "5px 10px", fontFamily: "OL", fontWeight: "100" }} onClick={create }>
        activate burner
      </div>
      <div className="global-button-style" style={{ fontSize: "2.4cqw", padding: "5px 10px", fontFamily: "OL", fontWeight: "100" }} onClick={clear}>
        delete burners
      </div>
      <img src="LOGO_WHITE.png" style={{ width: "20%", height: "20%", marginTop: "20px" }} />
    </ClickWrapper>
  );
};
