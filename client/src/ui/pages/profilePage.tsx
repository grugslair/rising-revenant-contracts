import React, { useEffect, useState } from "react";

import "./PagesStyles/ProfilePageStyles.css";

import { MenuState } from "./gamePhaseManager";

import { HasValue, getComponentValueStrict,getComponentValue } from "@latticexyz/recs";

import { useEntityQuery } from "@latticexyz/react";

import { useDojo } from "../../hooks/useDojo";

import { ConfirmEventOutpost, ReinforceOutpostProps } from "../../dojo/types";
import { setComponentQuick } from "../../dojo/testCalls";
import { GAME_CONFIG } from "../../phaser/constants";
import { ClickWrapper } from "../clickWrapper";
import { getEntityIdFromKeys } from "@dojoengine/utils";


interface ProfilePageProps {
  setMenuState?: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({ setMenuState}) => {
  // const closePage = () => {
  //   setMenuState(MenuState.NONE);
  // };

  const [text, setText] = useState("");
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

//   const {
//     account: { account },
//     networkLayer: {
//       systemCalls: { reinforce_outpost, confirm_event_outpost },
//       network: { clientComponents, contractComponents },
//     },
//   } = useDojo();

//   const selectedOutposts = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { owned: true })]);
//   const allOutpostinEventAdminBot = useEntityQuery([HasValue(clientComponents.ClientOutpostData, { event_effected: true })]);
//   const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));

//   const moveCameraHere = (x: number, y: number) => {

//     const clientCameraComp = getComponentValueStrict(clientComponents.ClientCameraPosition, getEntityIdFromKeys([BigInt(GAME_CONFIG)]));
    
//     setComponentQuick({"x": x, "y": y, "tile_index": clientCameraComp.tile_index},[getEntityIdFromKeys([BigInt(GAME_CONFIG)])], "ClientCameraPosition", clientComponents);
//   }

//   const reinforceOutpost = (outpost_id: any) => {

//     const reinforceOutpostProps: ReinforceOutpostProps = {
//       account: account,
//       game_id: clientGameData.current_game_id,
//       outpost_id: outpost_id,
//     };

//     reinforce_outpost(reinforceOutpostProps);
//   }

//   const confirmEvent = async (id : number) => {

//     const gameTrackerData = getComponentValueStrict(contractComponents.GameEntityCounter, getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

//     const confirmEventProps: ConfirmEventOutpost = {
//       account: account,
//       game_id: clientGameData.current_game_id,
//       event_id: gameTrackerData.event_count,
//       outpost_id: id,
//     };

//     await confirm_event_outpost(confirmEventProps);
// }

//   const confirmAll = async () => {
//     for (let index = 0; index < selectedOutposts.length; index++) {
//       const element = selectedOutposts[index];

//       console.error(element)

//       const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
//       const outpostData = getComponentValueStrict(contractComponents.Outpost, element);
      
//       console.log(clientOutpostData)
      

//       if (clientOutpostData.event_effected === true  && outpostData.lifes > 0)
//       {
        
//         await confirmEvent(clientOutpostData.id);
//       }
    
//     }
//   }

//   const adminKillAll = async () => {
//     for (let index = 0; index < allOutpostinEventAdminBot.length; index++) {
//       const element = selectedOutposts[index];

//       console.error(element)

//       const clientOutpostData = getComponentValueStrict(clientComponents.ClientOutpostData, element);
//       const outpostData = getComponentValueStrict(contractComponents.Outpost, element);
      
//       console.log(clientOutpostData)
      

//       if (clientOutpostData.event_effected === true  && outpostData.lifes > 0)
//       {
        
//         await confirmEvent(clientOutpostData.id);
//       }
//     }

//   }


//   useEffect(() => {
//     const handleKeyPress = (event: KeyboardEvent) => {
//       if (event.key === 'l') {
//         adminKillAll();
//       }
//     };

//     window.addEventListener('keydown', handleKeyPress);

//     return () => {
//       window.removeEventListener('keydown', handleKeyPress);
//     };
//   }, []);

//   const playerInfo = getComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account_add)]));

  return (
    <div className="profile-page-container">
      <img className="page-img" src="./assets/Page_Bg/PROFILE_PAGE_BG.png" alt="testPic" />
      <div className="title-section">
        <h2>PROFILE</h2>
        <div className="title-cart-section">
          <h1>
            {" "}
            {/* <img src="LOGO_WHITE.png" className="test-embed" alt=""></img> {playerInfo === undefined ? 0 : playerInfo.reinforcement_count} */}
            <img src="LOGO_WHITE.png" className="test-embed" alt=""></img> {0}
          </h1>
          <h3>Reinforcement available</h3>
        </div>
      </div>
      <div className="info-section">
        <div className="table-section">
          <div className="table-container">
            <div className="table-title-container">
              <h2>Outpost ID</h2>
              <h2>Position</h2>
              <h2>Reinforcements</h2>
              <div style={{ backgroundColor: "black", flex: "1.5" }}></div>
            </div>
            <ClickWrapper className="table-items-container">
              {/*  this should be an element */}
              {/* {selectedOutposts.map((outpost: any, index: number) => (
                <div
                  key={index}
                  className="item-container-profile"
                  onMouseEnter={() => setHoveredIndex(index)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  <h2 onMouseEnter={() => setText("")}>{getComponentValueStrict(clientComponents.ClientOutpostData, outpost).id}</h2>
                  <h2
                    onMouseDown={() => {
                      moveCameraHere(getComponentValueStrict(contractComponents.Outpost, outpost).x, getComponentValueStrict(contractComponents.Outpost, outpost).y);
                      setHoveredIndex(null);
                    }}
                    onMouseEnter={() => setText("Go Here")}
                  >
                    X: {getComponentValueStrict(contractComponents.Outpost, outpost).x}, Y:{" "}
                    {getComponentValueStrict(contractComponents.Outpost, outpost).y}
                  </h2>
                  <h2
                    onMouseDown={() => {
                      reinforceOutpost(getComponentValueStrict(clientComponents.ClientOutpostData, outpost).id);
                      setHoveredIndex(null);
                    }}
                    onMouseEnter={() => setText("Reinforce")}
                  >
                    {getComponentValueStrict(contractComponents.Outpost, outpost).lifes}
                  </h2>
                  <div className="item-button" style={{ opacity: hoveredIndex === index ? 1 : 0 }}>
                    {text}
                  </div>
                </div>
              ))} */}
               <div
                  key={0}
                  className="item-container-profile"
                  onMouseEnter={() => setHoveredIndex(0)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  <h2 onMouseEnter={() => setText("")}>{0}</h2>
                  
                  <h2 onMouseEnter={() => setText("Go Here")}>
                    X: {1832}, Y:{5342}
                  </h2>

                  <h2
                    onMouseDown={() => {}}
                    onMouseEnter={() => setText("Reinforce")} >
                      {2}
                  </h2>

                  <div className="item-button" style={{ opacity: hoveredIndex === 0 ? 1 : 0 }}>
                    {text}
                  </div>
                </div>

                <div
                  key={1}
                  className="item-container-profile"
                  onMouseEnter={() => setHoveredIndex(1)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  <h2 onMouseEnter={() => setText("")}>{1}</h2>
                  
                  <h2 onMouseEnter={() => setText("Go Here")}>
                    X: {1832}, Y:{5342}
                  </h2>

                  <h2
                    onMouseDown={() => {}}
                    onMouseEnter={() => setText("Reinforce")} >
                      {2}
                  </h2>

                  <div className="item-button" style={{ opacity: hoveredIndex === 1 ? 1 : 0 }}>
                    {text}
                  </div>
                </div>

                <div
                  key={2}
                  className="item-container-profile"
                  onMouseEnter={() => setHoveredIndex(2)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  <h2 onMouseEnter={() => setText("")}>{2}</h2>
                  
                  <h2 onMouseEnter={() => setText("Go Here")}>
                    X: {1832}, Y:{5342}
                  </h2>

                  <h2
                    onMouseDown={() => {}}
                    onMouseEnter={() => setText("Reinforce")} >
                      {2}
                  </h2>

                  <div className="item-button" style={{ opacity: hoveredIndex === 2 ? 1 : 0 }}>
                    {text}
                  </div>
                </div>

            </ClickWrapper>
          </div>
        </div>
        <div className="buy-section">
          <div className="button-style-profile">Buy Reinforcements (Disabled)</div>
          <ClickWrapper className="button-style-profile" onMouseDown={() => {}}>Destory All</ClickWrapper>
        </div>
      </div>
    </div>
  );
};
