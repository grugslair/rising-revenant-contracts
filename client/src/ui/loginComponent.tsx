import React from "react";
import { ClickWrapper } from "./clickWrapper";
import { Phase } from "./phaseManager";

interface LoginPageProps {
  setUIState: React.Dispatch<Phase>;
}

export const LoginComponent: React.FC<LoginPageProps> = ({ setUIState }) => {

  const handleButtonClick = () => {
    setUIState(Phase.LOADING);
  };

  return (
    <ClickWrapper className="centered-div" style={{ display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "column", gap: "20px" }}>
      <div className="global-button-style" style={{ fontSize: "3rem" }} onClick={handleButtonClick}>
        Wallet Login
      </div>
      <div className="global-button-style" style={{ fontSize: "3rem" }} onClick={handleButtonClick}>
        Guest Login
      </div>
    </ClickWrapper>
  );
};
