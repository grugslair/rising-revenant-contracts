import React, { useEffect, useState } from "react";
import { MenuState } from "../Pages/gamePhaseManager";
import { HasValue, getComponentValueStrict, getComponentValue } from "@latticexyz/recs";

import "./ComponentsStyles/NavBarStyles.css";

import { ClickWrapper } from "../clickWrapper";
import { PrepPhaseStages } from "../PrepPhasePages/prepPhaseManager";
import { useDojo } from "../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../utils/settingsConstants";
import { Tooltip } from "@mui/material";

interface NavbarProps {
  menuState: MenuState;
  setMenuState: (menuState: MenuState) => void;
  clientComponents:any;
}

//Create own tooltip HERE

export const NavbarComponent: React.FC<NavbarProps> = ({ menuState, setMenuState,clientComponents }) => {

  const handleIconClick = (selectedState: MenuState) => {
    if (menuState === selectedState) {
      setMenuState(MenuState.NONE);
    } else {
      setMenuState(selectedState);
    }
  };

  const guest = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)])).guest;

  return (
    <ClickWrapper className="navbar-container">

      {guest ?
        <Tooltip title="PROFILE (DISABLED)" placement="left">
          <div className={`navbar-icon not-active`} style={{ filter: "brightness(70%) grayscale(70%)" }}>
            <img src="Navbar_icons/PROFILE.png" alt="" />
          </div>
        </Tooltip>
        :
        <Tooltip title="PROFILE" placement="left">
          <div className={`navbar-icon ${menuState === MenuState.PROFILE ? "active" : "not-active"}`} onClick={() => handleIconClick(MenuState.PROFILE)}>
            <img src="Navbar_icons/PROFILE.png" alt="" />
          </div>
        </Tooltip>
      }


      <Tooltip title="TRADES" placement="left">
        <div onClick={() => handleIconClick(MenuState.TRADES)} className={`navbar-icon ${menuState === MenuState.TRADES ? "active" : "not-active"}`}>
          <img src="Navbar_icons/TRADES.png" alt="" />
        </div>
      </Tooltip>

      <Tooltip title="STATISTICS" placement="left">
        <div className={`navbar-icon ${menuState === MenuState.STATS ? "active" : "not-active"}`} onClick={() => handleIconClick(MenuState.STATS)}>
          <img src="Navbar_icons/STATISTICS.png" alt="" />
        </div>
      </Tooltip>

      <Tooltip title="RULES" placement="left">
        <div className={`navbar-icon ${menuState === MenuState.RULES ? "active" : "not-active"}`} onClick={() => handleIconClick(MenuState.RULES)}>
          <img src="Navbar_icons/RULES.png" alt="" />
        </div>
      </Tooltip>


      <Tooltip title="SETTINGS" placement="left">
        <div onClick={() => handleIconClick(MenuState.SETTINGS)} className={`navbar-icon ${menuState === MenuState.SETTINGS ? "active" : "not-active"}`}>
          <img src="Navbar_icons/SETTINGS.png" alt="" />
        </div>
      </Tooltip>
    </ClickWrapper>
  );
};

interface PrepPhaseNavbarProps {
  currentMenuState: PrepPhaseStages;
  lastSavedState: PrepPhaseStages;
  setMenuState: (menuState: PrepPhaseStages) => void;
}

export const PrepPhaseNavbarComponent: React.FC<PrepPhaseNavbarProps> = ({ currentMenuState, lastSavedState, setMenuState }) => {

  const {
    networkLayer: {
      network: { clientComponents }
    },
  } = useDojo();

  const handleIconClick = (selectedState: PrepPhaseStages) => {
    if (currentMenuState === selectedState) {
      setMenuState(lastSavedState);
    } else {
      setMenuState(selectedState);
    }
  };

  const guest = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)])).guest;

  return (
    <ClickWrapper className="navbar-container">

      {guest ?
        <Tooltip title="PROFILE (DISABLED)" placement="left">
          <div className={`navbar-icon not-active`} style={{ filter: "brightness(50%) grayscale(50%)" }}>
            <img src="Navbar_icons/PROFILE.png" alt="" />
          </div>
        </Tooltip>
        :
        <Tooltip title="PROFILE" placement="left">
          <div className={`navbar-icon ${currentMenuState === PrepPhaseStages.PROFILE ? "active" : "not-active"}`} onClick={() => handleIconClick(PrepPhaseStages.PROFILE)}>
            <img src="Navbar_icons/PROFILE.png" alt="" />
          </div>
        </Tooltip>
      }
      <Tooltip title="RULES" placement="left">
        <div className={`navbar-icon ${currentMenuState === PrepPhaseStages.RULES ? "active" : "not-active"}`} onClick={() => handleIconClick(PrepPhaseStages.RULES)}>
          <img src="Navbar_icons/RULES.png" alt="" />
        </div>
      </Tooltip>
      <Tooltip title="SETTINGS" placement="left">
        <div className={`navbar-icon ${currentMenuState === PrepPhaseStages.SETTINGS ? "active" : "not-active"}`} onClick={() => handleIconClick(PrepPhaseStages.SETTINGS)}>
          <img src="Navbar_icons/SETTINGS.png" alt="" />
        </div>
      </Tooltip>

      <div className={`navbar-icon-off `} >
      </div>
      <div className={`navbar-icon-off `} >
      </div>
    </ClickWrapper>
  );
};