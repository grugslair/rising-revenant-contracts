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

  const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(4,6, "20%");

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
        backgroundColor: "#000000aa",
        position: "absolute",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
        borderRadius: "5px",
        border: "var(--borderRadius) solid var(--borderColour)",
        boxSizing: "border-box",
        display: "grid",
        gridTemplateRows: "repeat(6,1fr)",
        gridTemplateColumns: "repeat(4,1fr)",
        padding: "10px",
        gap: "2px",
      }}>
        <div style={{ gridRow: "1", gridColumn: "1/5" }} className="center-via-flex">
          <h1 className="no-margin test-h1" style={{ fontFamily: "Zelda", color: "white", whiteSpace:"nowrap"}}>Rising Revenant</h1>
        </div>
        <div style={{ gridRow: "2/5", gridColumn: "1/5"}}>
          <img src="login_revenant_pic.png" style={{ height: "100%", width: "100%", borderRadius:"10px" }}></img>
        </div>
        <ClickWrapper style={{ gridRow: "5/7", gridColumn: "1/5", flexDirection: "column", padding:"5% 10px" }} className="center-via-flex">
          
          <div style={{ flex: "1" }} className="center-via-flex">
            <h2 className="global-button-style no-margin test-h2" style={{ fontFamily: "OL", fontWeight: "100", padding:"5px 10px" }} onClick={() => { createGameClient(false)}}>
              Wallet Login {truncateString(account.address, 5)}
            </h2>
          </div>

          <div style={{ flex: "0.5", textAlign: "center", color:"white" }} className="center-via-flex"> <h3 className="no-margin test-h5">or</h3></div>
          
          <div style={{ flex: "1" }} className="center-via-flex">
            <h2 className="global-button-style no-margin test-h2" style={{ fontFamily: "OL", fontWeight: "100", padding:"5px 10px" }} onClick={() => { createGameClient(true)}}>
              Guest Login
            </h2>
          </div>

        </ClickWrapper>
      </div>

      {/* <div  style={{
        backgroundColor: "white",
        position: "absolute",
        top: "50%",
        left: "25%",
        transform: "translate(-50%, -50%)",
        borderRadius: "5px",
        border: "10px solid var(--borderColour)",
        boxSizing: "border-box",
      }}>
        <div className="test-h1">This is a test h1</div>
        <div className="test-h1-5">This is a test h1.5</div>
        <div className="test-h2">This is a test h2</div>
        <div className="test-h3">This is a test h3</div>
        <div className="test-h4">This is a test h4</div>
        <div className="test-h5">This is a test h5</div>
      </div> */}

      <ClickWrapper style={{
        height: "10%",
        width: "20%",
        position: "absolute",
        top: "100%",
        left: "50%",
        transform: "translate(-50%, -110%)",
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


export const useResizeableHeight = (colNum: number, rowNum: number, setWidht: string) => {
  const clickWrapperRef = useRef<HTMLDivElement>(null);
  const [heightValue, setHeight] = useState<number>(0);

  useEffect(() => {
    const updateHeight = () => {
      if (clickWrapperRef.current) {
        setHeight((clickWrapperRef.current.offsetWidth / colNum) * rowNum);
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
    width:setWidht
  };

  return { clickWrapperRef, clickWrapperStyle };
};