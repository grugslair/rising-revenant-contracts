import React, { useEffect} from "react";
import { GAME_CONFIG_ID, MAP_HEIGHT, MAP_WIDTH } from "../utils/settingsConstants";

import { ClickWrapper } from "./clickWrapper";
import { Phase } from "./phaseManager";
import { useDojo } from "../hooks/useDojo";
import { truncateString } from "../utils";
import { setComponent } from "@latticexyz/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { getTileIndex } from "../phaser/constants";
import { useResizeableHeight } from "./Hooks/gridResize";

interface LoginPageProps {
  setUIState: React.Dispatch<Phase>;
}

export const LoginComponent: React.FC<LoginPageProps> = ({ setUIState }) => {

  const { clickWrapperRef, clickWrapperStyle } = useResizeableHeight(4, 6, "20%");

  //for now we use a burner account
  const {
    account: { account, create, isDeploying, clear, select, list },
    networkLayer: {
      network: { clientComponents },
    },
  } = useDojo();


  function handleTransactionError() {
    clear();
    create();
    console.error('Error fetching transaction receipt');
  }

  useEffect(() => {
    const handleRejection = (event) => {
      const error = event.reason;

      if (error && error.message && error.message.includes('Error fetching transaction receipt')) {
        handleTransactionError();
      }
    };
    window.addEventListener('unhandledrejection', handleRejection);
    return () => {
      window.removeEventListener('unhandledrejection', handleRejection);
    };
  }, []);


  const createGameClient = (guest: boolean) => {

    setComponent(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
      current_game_state: 1,
      current_game_id: 1,
      current_block_number: 1,
      guest: guest,
      current_event_drawn: 0,
      transaction_count: 0,
    })

    setComponent(clientComponents.ClientSettings, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
      volume:50
    })

    setComponent(clientComponents.ClientClickPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
      xFromOrigin: 1,
      yFromOrigin: 1,
      xFromMiddle: 1,
      yFromMiddle: 1,
    })

    setComponent(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
      x: MAP_WIDTH / 2,
      y: MAP_HEIGHT / 2,
    })

    const index = getTileIndex(MAP_WIDTH / 2, MAP_HEIGHT / 2);
    setComponent(clientComponents.EntityTileIndex, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]), {
      tile_index: index
    })

    setUIState(Phase.LOADING);
  }

  return (
    <>
      <div style={{
        width: "100%",
        height: "100%",
        filter: "blur(10px)"
      }}>
        <img src="assets/rev_map_big.png" style={{ width: "200%", aspectRatio: "2/1", transform: "translate(-25%, -20%)" }}></img>
      </div>

      <div ref={clickWrapperRef} style={{
        ...clickWrapperStyle,
        backgroundColor: "#00000055",
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
          <h1 className="no-margin test-h1" style={{ fontFamily: "Zelda", color: "white", whiteSpace: "nowrap" }}>Rising Revenant</h1>
        </div>
        <div style={{ gridRow: "2/5", gridColumn: "1/5" }}>
          <img src="Misc/login_revenant_pic.png" style={{ height: "100%", width: "100%", borderRadius: "10px" }}></img>
        </div>
        <ClickWrapper style={{ gridRow: "5/7", gridColumn: "1/5", flexDirection: "column", padding: "5% 10px" }} className="center-via-flex">

          <div style={{ flex: "1" }} className="center-via-flex">
            {account.address === import.meta.env.VITE_PUBLIC_MASTER_ADDRESS ?
              <h2 className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{ fontFamily: "OL", fontWeight: "100", padding: "5px 10px" }} onClick={create}>
                {isDeploying ? "Deploying wallet" : "Create wallet"}
              </h2>
              :
              <h2 className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{ fontFamily: "OL", fontWeight: "100", padding: "5px 10px" }} onClick={() => { createGameClient(false) }}>
                Wallet Login {truncateString(account.address, 5)}
              </h2>
            }
          </div>

          {/* <div style={{ flex: "0.5", textAlign: "center", color: "white" }} className="center-via-flex"> <h3 className="no-margin test-h4">or</h3></div> */}

          <div style={{ flex: "1" }} className="center-via-flex">
            {/* <h2 className="global-button-style invert-colors  invert-colors no-margin test-h2" style={{ fontFamily: "OL", fontWeight: "100", padding: "5px 10px" }}>
              Guest Login</h2> */}
          </div>
        </ClickWrapper >
      </div >

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
      }} className="opacity-login-screen">
        <div style={{ gridColumn: "1 / span 1", gridRow: "1 / span 1", position: "relative" }} className="center-via-flex">
          <div className="global-button-style invert-colors " style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box" }} onClick={create}>
            {isDeploying ? "deploying burner" : "create burner"}
          </div>
        </div>
        <div style={{ gridColumn: "2 / span 1", gridRow: "1 / span 1", position: "relative" }} className="center-via-flex">
          <div className="global-button-style invert-colors " style={{ fontSize: "1vw", fontFamily: "OL", fontWeight: "100", boxSizing: "border-box" }} onClick={clear}>
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
