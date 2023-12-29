import React, { useEffect, useRef, useState } from "react";
import { MAP_HEIGHT, MAP_WIDTH } from "../utils/settingsConstants";

import { ClickWrapper } from "./clickWrapper";
import { Phase } from "./phaseManager";
import { useDojo } from "../hooks/useDojo";
import { setClientCameraComponent, setClientCameraEntityIndex, setClientClickPositionComponent, setClientGameComponent, truncateString } from "../utils";


interface LoginPageProps {
  setUIState: React.Dispatch<Phase>;
}

export const LoginComponent: React.FC<LoginPageProps> = ({ setUIState }) => {

  const clickWrapperRef = useRef<HTMLDivElement>(null);
  const [heightValue, setHeight] = useState<number>(0)

  //for now we use a burner account
  const {
    account: { account, create, isDeploying, clear, select, list },
    networkLayer: {
      network: { clientComponents },
    },
  } = useDojo();

  //create the client game comp for the start of the loading
  const createGameClient = async (guest: boolean) => {
    setClientGameComponent(1, 1, 1, guest, 0, clientComponents);
    setClientClickPositionComponent(1, 1, 1, 1, clientComponents);
    setClientCameraComponent(MAP_WIDTH / 2, MAP_HEIGHT / 2, clientComponents);
    setClientCameraEntityIndex(MAP_WIDTH / 2, MAP_HEIGHT / 2, clientComponents);
    setUIState(Phase.LOADING);
  }

  useEffect(() => {
    const updateHeight = () => {
      if (clickWrapperRef.current) {
        setHeight((clickWrapperRef.current.offsetWidth / 8) * 8);
      }
    };

    window.addEventListener('resize', updateHeight);

    updateHeight();

    return () => {
      window.removeEventListener('resize', updateHeight);
    };
  }, []);

  const clickWrapperStyle: React.CSSProperties = {
    height: `${heightValue}px`,
    width: '30%',
  };

  return (
    <>
      <div style={{
        width: "100%",
        height: "100%",
        backgroundImage: "url('map_Island.png')",
        backgroundSize: "200% 200%",
        backgroundPosition: "center",
        filter: "blur(10px)"
      }} className="center-via-flex">
      </div>

      <div ref={clickWrapperRef} style={{
        ...clickWrapperStyle,
        backgroundColor: "#00000055",
        position: "absolute",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        borderRadius: "5px",
        border: "10px solid var(--borderColour)",
        boxSizing: "border-box",
        display: "grid",
        gridTemplateRows: "repeat(8,1fr)",
        gridTemplateColumns: "repeat(8,1fr)",
        padding: "10px 20px",
        gap: "2px",
      }}>
        <div style={{ gridRow: "1", gridColumn: "1/9" }} className="center-via-flex">
          <h2 style={{ fontFamily: "Zelda", fontSize: "2vw", color: "white" }}>Rising Revenant</h2>
        </div>
        <div style={{ gridRow: "2/6", gridColumn: "1/9", backgroundColor: "green" }}>
          <img src="test_out_pp.png" style={{ height: "100%", width: "100%" }}></img>
        </div>
        <ClickWrapper style={{ gridRow: "6/9", gridColumn: "1/9", flexDirection: "column", padding:"5% 10px" }} className="center-via-flex">
          <div style={{ flex: "1" }} className="center-via-flex">
            <div className="global-button-style" style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box", padding:"5px 10px" }} onClick={() => { createGameClient(false)}}>
              Wallet Login {truncateString(account.address,5)}
            </div>
          </div>
          <h3 style={{ flex: "0.5", textAlign: "center", color:"white" }} className="center-via-flex">or</h3>
          <div style={{ flex: "1" }} className="center-via-flex">
            <div className="global-button-style" style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box", padding:"5px 10px" }} onClick={() => { createGameClient(true)}}>
              Guest Login
            </div>
          </div>
        </ClickWrapper>
      </div>

      <ClickWrapper style={{
        height: "10%",
        width: "20%",
        position: "absolute",
        top: "80%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        display: "grid",
        gridTemplateRows: "50% 50%",
        gridTemplateColumns: "50% 50%",
      }}>
        <div style={{ gridColumn: "1 / span 1", gridRow: "1 / span 1", position: "relative" }} className="center-via-flex">
          <div className="global-button-style" style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box" }} onClick={create}>
            {isDeploying ? "deploying burner" : "create burner"}
          </div>
        </div>
        <div style={{ gridColumn: "2 / span 1", gridRow: "1 / span 1", position: "relative" }} className="center-via-flex">
          <div className="global-button-style" style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box" }} onClick={clear}>
            delete burners
          </div>
        </div>
        <div style={{ gridColumn: "1 / span 2", gridRow: "2 / span 1", position: "relative", width: "100%" }} className="center-via-flex">
          <select style={{ width: "100%" }} onChange={(e) => select(e.target.value)}>
            {list().map((account, index) => {
              return (
                <option value={account.address} key={index}>
                  {account.address}
                </option>
              );
            })}
            i
          </select>
        </div>

      </ClickWrapper>
    </>
  );
};
