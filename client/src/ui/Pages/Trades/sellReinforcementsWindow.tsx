import request from "graphql-request";
import { useEffect, useState } from "react";
import { getCount } from "../../../utils";
import { CreateTradeForReinf } from "../../../dojo/types";
import CounterElement from "../../Elements/counterElement";
import { ConfigProvider, InputNumber } from "antd";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "../../../hooks/useDojo";

import {useComponentValue} from "@latticexyz/react";
import {getComponentValueStrict} from "@latticexyz/recs";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";

export const SellReinforcementTradeWindow: React.FC = () => {

    const [numberValue, setNumberValue] = useState<number | null>(1);
    const [amountToSell, setAmountToSell] = useState<number>(0);

    const [numberOfCurrentTrades, setNumberOfCurrentTrades] = useState<number>(-1);

    const {
        account: { account },
        networkLayer: {
            network: { contractComponents, clientComponents },
            systemCalls: { create_trade_reinf }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]))
    const playerInfo = useComponentValue(contractComponents.PlayerInfo, getEntityIdFromKeys([BigInt(clientGameData.current_game_id), BigInt(account.address)]))

    useEffect(() => {

        if (playerInfo === undefined) { return; }

        if (amountToSell < 0) {
            setAmountToSell(0)
            return;
        }

        if (amountToSell > playerInfo.reinforcement_count) {
            setAmountToSell(playerInfo.reinforcement_count);
        }

    }, [account, playerInfo, amountToSell])


    useEffect(() => {

        if (playerInfo === undefined) { return; }

        if (amountToSell < 0) {
            setAmountToSell(0)
            return;
        }

        if (amountToSell > playerInfo.reinforcement_count) {
            setAmountToSell(playerInfo.reinforcement_count);
        }

    }, [account, playerInfo, amountToSell])

    useEffect(() => {
        const fetchData = async () => {
            const graphqlRequest = `query {
            tradeModels(
              where: {
                game_id: 1,
                status: 1,
              }
            ) {
              edges {
                node {
                  entity {
                    keys
                    models {
                      __typename
                      ... on Trade {
                        game_id
              entity_id
              seller
              price
              count
              buyer
              status
                      }
                    }
                  }
                }
              }
              total_count
            }
          }`;

            const endpoint = import.meta.env.VITE_PUBLIC_TORII;

            try {
                const data = await request(endpoint, graphqlRequest);
                setNumberOfCurrentTrades(getCount(data, "tradeModels"))
            } catch (error) {
                console.error('Error executing GraphQL query:', error);
                throw error;
            }
        };
        
        fetchData();
    }, []);


    const confirmCreationOfOrder = async () => {

        const createTradeProp: CreateTradeForReinf = {
            account: account,
            game_id: clientGameData.current_game_id,
            count: amountToSell,
            price: numberValue!,
        };

        await create_trade_reinf(createTradeProp);
    };

    //HERE THE NUMBER IS CUT OFF A BIT AT THE TOP AND PROB SHOULD NOT BE FREELY GOING UP LIKE THIS NEEDS A CLAMP

    return (
        <>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ height: "100%", width: "40%" }}>
                <img src="./assets/Page_Bg/REINFORCEMENT_PAGE_BG.png" style={{ height: "100%", width: "100%" }}></img>
            </div>
            <div style={{ height: "100%", width: "10%" }}></div>
            <div style={{ height: "100%", width: "20%", display: "flex", flexDirection: "column", color: "white" }}>

                <div style={{ flex: "1", display: "flex", justifyContent: "flex-start", flexDirection: "column" }}>
                    <h3 className="no-margin test-h3" style={{  whiteSpace: "nowrap" }}>Sell Reinforcements</h3>
                    <CounterElement value={amountToSell} setValue={setAmountToSell} containerStyleAddition={{ maxWidth: "75%", height: "40%", marginBottom: "9%" }} additionalButtonStyleAdd={{ width: "15%" }} textAddtionalStyle={{ fontSize:"1rem"}} />
                </div>

                <div style={{ flex: "1", display: "flex", justifyContent: "center", flexDirection: "column" }}>
                    <h3 className="no-margin test-h3" style={{ whiteSpace: "nowrap", height: "50%" }}>Set Price</h3>
                    <ConfigProvider
                        theme={{
                            token: {
                                colorText: "white",
                            },
                        }}>
                        <InputNumber min={1} max={50} value={numberValue} onChange={setNumberValue} className="test-h2" style={{ backgroundColor: "#131313", color: "white", borderColor: "#2D2D2D", width: "60%", height: "45%" }} />
                    </ConfigProvider>
                </div>

                <div style={{ flex: "1", display: "flex", justifyContent: "flex-end", flexDirection: "column", alignContent: "flex-end" }}>
                    <h3 className="no-margin test-h4" style={{  whiteSpace: "nowrap", height: "20%" }}>Current Active Trades: {numberOfCurrentTrades}</h3>
                    <div className="global-button-style no-margin test-h2" style={{ padding: "5px 10px", maxWidth: "fit-content" }} onClick={confirmCreationOfOrder}>Confirm</div>
                </div>
            </div>

            <div style={{ height: "100%", width: "20%" }}></div>
        </>
    )
}