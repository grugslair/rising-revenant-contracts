import React from "react";
import { GAME_CONFIG } from "../phaser/constants";

import { setComponent, Components, ComponentValue } from "@latticexyz/recs";

import { ClickWrapper } from "./clickWrapper";
import { Phase } from "./phaseManager";
import { useDojo } from "../hooks/useDojo";
import { setClientGameComponent } from "../utils";

interface LoginPageProps {
  setUIState: React.Dispatch<Phase>;
}

// this needs to set the and prob create the client game comp at least

export const LoginComponent: React.FC<LoginPageProps> = ({ setUIState }) => {

  const handleButtonClick = () => {
    setUIState(Phase.LOADING);
  };

  const {
    networkLayer: {
      network: { clientComponents },
    },
  } = useDojo();

  const createGameClient = async (guest: boolean) => {
    setClientGameComponent(1, 1, 1,guest, clientComponents);
  }

  return (
    <ClickWrapper className="centered-div" style={{ display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "column", gap: "20px" }}>
      <div className="global-button-style" style={{ fontSize: "3rem" }} onClick={() => {createGameClient(true); handleButtonClick()}}>
        Wallet Login
      </div>
      <div className="global-button-style" style={{ fontSize: "3rem" }} onClick={() => {createGameClient(false); handleButtonClick()}}>
        Guest Login
      </div>
    </ClickWrapper>
  );
};
