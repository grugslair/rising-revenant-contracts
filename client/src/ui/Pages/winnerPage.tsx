import React, { useEffect } from "react";

import "./PagesStyles/WinnerPageStyles.css";

import { MenuState } from "./gamePhaseManager";
import { ClickWrapper } from "../clickWrapper";
import { useDojo } from "../../hooks/useDojo";

import { HasValue,  getComponentValueStrict, Has } from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";


interface WinnerPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const WinnerPage: React.FC<WinnerPageProps> = ({ setMenuState }) => 
{
    const [winningAddress, setWinningAddress] = React.useState<string>("");

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    const {
        account : { account },
        networkLayer: {
            network: { contractComponents },
        },
    } = useDojo();


  const outpostDeadQuery = useEntityQuery([HasValue(contractComponents.Outpost, { lifes: 0 })]);
  const totalOutposts = useEntityQuery([Has(contractComponents.Outpost)]);

  console.error("outpostDeadQuery", outpostDeadQuery);
    console.error("totalOutposts", totalOutposts);

  useEffect(() => {

    const difference: string[] = totalOutposts.filter(item => !outpostDeadQuery.includes(item));

    const outpostComp = getComponentValueStrict(contractComponents.Outpost, getEntityIdFromKeys([BigInt( difference[0])]));

    setWinningAddress(outpostComp.owner);

  }, []);



  const shareOnTwitter = () => {
    const message = 'I just won!';
    const twitterShareUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(message)}`;
    window.open(twitterShareUrl, '_blank');
  };

    return (
        <div className="winner-page-container">
                <div className="content-container">
                    <h3>Address: {winningAddress}</h3>
                    {winningAddress === account.address ?   <h1>YOU ARE THE RISING REVENANT</h1> : <h1>IS THE RISING REVENANT</h1>}
                    <ClickWrapper className="button-style">Claim your jackpot</ClickWrapper>
                </div>

                {winningAddress === account.address && <div className="share-text" onMouseDown={() => {shareOnTwitter()}}>
                    <h2>Share on</h2>
                    <img src="https://upload.wikimedia.org/wikipedia/commons/c/ce/X_logo_2023.svg"></img>
                </div>}
        </div>
    )
}
