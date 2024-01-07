import { useEffect, useState } from "react";
import { useDojo } from "../../../hooks/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";
import { Dropdown, Space, Typography, Input, InputNumber, ConfigProvider, Checkbox, Slider } from "antd";

import { TradeEdge } from "../../../generated/graphql";

import { getComponentValueStrict } from '@latticexyz/recs';
import { fetchAllTrades } from "../../../utils";
import request from "graphql-request";
import { ReinforcementListingElement } from "./reinforcementTradeListingElement";

enum SortingMethods {
    NONE,
    COST,
    REINF,
    LOCATION,
    OUT_ID,
    SELLER_ADDR,
};

const items = [
    {
        label: 'None',
        key: "1",
    },
    {
        label: 'Price',
        key: "2",
    },
    {
        label: 'Reinforcement',
        key: "3",
    },
    // {
    //     label: 'Specific Sellers',
    //     key: "4",
    // },
];

const graphqlStructureForReinforcements = [
    `
    query {
        tradeModels(
          where: { 
            game_id: GAME_ID,
            status:1,
            LTE_VAR:MAX_VAL,
            GTE_VAR:MIN_VAL
          }
          first: NUM_DATA
          order: { direction: DIR, field: FIELD_NAME }
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
        }
      }
      
    `
    ,
    `
  query {
    tradeModels(
      where: { 
        game_id: GAME_ID,
        status:1,
        sellet: SELLER
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
    }
  }
  `
]


export const ReinforcementTradeWindow: React.FC = () => {

    const [refresh, setRefresh] = useState<boolean>(false);
    const [tradeList, setTradeList] = useState<any | undefined[]>([]);

    const [showOthersTrades, setShowOthersTrades] = useState<boolean>();   // checkboxes
    const [invertTrade, setInvertTrade] = useState<boolean>();
    const [showYourTrades, setShowYourTrades] = useState<boolean>();

    const [minValue, setMinValue] = useState<number | null>(1);
    const [maxValue, setMaxValue] = useState<number | null>(2);

    const [sliderValue, setSliderValue] = useState<[number, number]>([2, 10]);

    const [selectedSortingMethod, setSelectedSortingMethod] = useState<string>("1");

    const {
        networkLayer: {
            network: { clientComponents, graphSdk }
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {   //we dont want this
        const trades = async () => {
            const tradesModels = await fetchAllTrades(graphSdk, clientGameData.current_game_id, 1);
            return setTradeList(tradesModels?.edges);
        };
        trades();
    }, [refresh])

    // this needs to be used to refresh
    useEffect(() => {
        const intervalId = setInterval(() => {
        }, 5000);

        return () => clearInterval(intervalId);

    }, []);


    const onClick = ({ key }) => {
        setSelectedSortingMethod(key);
        setMinValue(1);
        setMaxValue(2);
    };

    const onSliderChange = (value: any) => {
        setSliderValue(value)
    };

    const createGraphQlRequestGTELTE = async (nameOfVar: string) => {
        // Extract the GraphQL structure at the specified index
        if (maxValue! <= minValue!) { return; }

        const selectedStructure = graphqlStructureForReinforcements[0];

        let graphqlRequest = "";

        const orderDirection = invertTrade ? 'DESC' : 'ASC';

        graphqlRequest = selectedStructure
            .replace('DIR', orderDirection)
            .replace('FIELD_NAME', nameOfVar.toUpperCase())
            .replace('NUM_DATA', "25")
            .replace('GAME_ID', clientGameData.current_game_id.toString())
            .replace('LTE_VAR', nameOfVar + "LTE")
            .replace('MAX_VAL', (nameOfVar === "price" ? '"' + maxValue!.toString() + '"' : maxValue!.toString()))
            .replace('GTE_VAR', nameOfVar + "GTE")
            .replace('MIN_VAL', (nameOfVar === "price" ? '"' + minValue!.toString() + '"' : minValue!.toString()));

        const endpoint = import.meta.env.VITE_PUBLIC_TORII;

        try {
            const data: any = await request(endpoint, graphqlRequest);
            setTradeList(data.tradeModels?.edges)

        } catch (error) {
            console.error('Error executing GraphQL query:', error);
            throw error;
        }
    };

    return (
        <>
            <div style={{ height: "100%", width: "9%" }}></div>
            <div style={{ backgroundColor: "#2F2F2F", height: "100%", width: "20%", border: "5px solid var(--borderColour)", boxSizing: "border-box", color: "white", borderRadius: "3px" }}>

                <div style={{ height: "15%", width: "100%", display: "flex", justifyContent: "space-between", alignItems: "center", flexDirection: "row", padding: "0px 5%", boxSizing: "border-box", gap: "10px" }}>
                    {/* <div style={{ height: "100%", width: "40%", display: "flex", justifyContent: "flex-start", alignItems: "center", fontSize: "1vw" }}>
                        <h3 className="no-margin test-h3">Sort</h3>
                    </div> */}
                    <h3 className="no-margin test-h3" style={{ width: "20%" }}>Sort</h3>
                    {/* this si for the drop down menu that actually appears */}
                    <Dropdown
                        menu={{
                            items,
                            onClick,
                        }}
                        placement="bottom"
                    >
                        {/* the drop down is for the menu that comes out */}
                        <a onClick={(e) => e.preventDefault()} className="pointer" style={{ backgroundColor: "#D0D0D0", width: "80%", height: "60%", display: "flex", justifyContent: "flex-start", alignItems: "center", borderRadius: "2px", color: "black", padding: "0px 2%", boxSizing: "border-box", fontWeight: "100", fontFamily: "OL" }}>
                            <Space style={{ width: "100%", textAlign: "center", whiteSpace: "nowrap" }} className="test-h3 no-margin">
                                {items.find(item => item.key === selectedSortingMethod.toString())?.label || 'None'}
                            </Space>
                        </a>
                    </Dropdown>
                </div>

                <div style={{ height: "85%", width: "100%", padding: "2% 5%", boxSizing: "border-box", display: "grid", gridTemplateRows: "repeat(9,1fr)", gridTemplateColumns: "repeat(2, 1fr)" }}>


                    <div style={{ gridRow: "6", gridColumn: "1/3", marginTop: "auto" }}>
                        <Checkbox onChange={(e) => { setInvertTrade(e.target.checked) }} className="test-h4" style={{ color: "white" }}>Hide other's trades</Checkbox>
                    </div>
                    <div style={{ gridRow: "7", gridColumn: "1/3", margin: "auto 0px" }}>
                        <Checkbox onChange={(e) => { setInvertTrade(e.target.checked) }} className="test-h4" style={{ color: "white" }}>Hide your trades</Checkbox>
                    </div>
                    <div style={{ gridRow: "8", gridColumn: "1/3" }}>
                        <Checkbox onChange={(e) => { setInvertTrade(e.target.checked) }} className="test-h4" style={{ color: "white" }} >Invert Order</Checkbox>
                    </div>
                    {selectedSortingMethod === "1" && <>



                        <h4 className="global-button-style no-margin test-h4" style={{ gridRow: "9", gridColumn: "1/3", height: "fit-content", width: "fit-content", marginLeft: "auto", marginTop: "auto", padding: "2px 5px" }} onClick={() => setRefresh(!refresh)}>Refresh latest trades</h4>
                    </>}

                    {selectedSortingMethod === "2" && <>
                    <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }}>
                            <h3 className="no-margin test-h3">Set Price Range</h3>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h3 style={{ textAlign: "center" }} className="no-margin test-h3">Min</h3>
                        </div>
                        <div style={{ gridRow: "2/3", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h3 style={{ textAlign: "center" }} className="no-margin test-h3">Max</h3>
                        </div>
                        <div style={{ gridRow: "3/4", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-end", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber min={1} max={maxValue!} value={minValue} onChange={setMinValue} placeholder="Min price" style={{ backgroundColor: "white", height: "70%", width: "100%", fontSize: "1rem" }} />
                        </div>
                        {/* stringMode step="0.0001" */}
                        <div style={{ gridRow: "3/4", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "flex-start", alignItems: "flex-end", padding: "0px 5%", boxSizing: "border-box" }} >
                            <InputNumber min={minValue!} max={1000} value={maxValue} onChange={setMaxValue} placeholder="Max price" style={{ backgroundColor: "white", height: "70%", width: "100%", fontSize: "1rem" }} />
                        </div>

                        <h4 className="global-button-style no-margin test-h4" style={{ gridRow: "9", gridColumn: "1/3", height: "fit-content", width: "fit-content", marginLeft: "auto", marginTop: "auto", padding: "2px 5px" }} onClick={() => setRefresh(!refresh)}>Refresh latest trades</h4>
                    </>}

                    {selectedSortingMethod === "3" && <>
                        <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }}>
                            <h3 className="no-margin test-h3">Set Reinforcement Range</h3>
                        </div>

                        <div style={{ gridRow: "2/3", gridColumn: "1/2", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h3 style={{ textAlign: "center" }} className="no-margin test-h3">Min: {sliderValue[0]}</h3>
                        </div>

                        <div style={{ gridRow: "2/3", gridColumn: "2/3", width: "100%", height: "100%", display: "flex", justifyContent: "center", alignItems: "flex-end" }}>
                            <h3 style={{ textAlign: "center" }} className="no-margin test-h3">Max: {sliderValue[1]}</h3>
                        </div>

                        <div style={{ gridRow: "3/4", gridColumn: "1/3", width: "100%", height: "100%", padding:"0px 2%", boxSizing:"border-box" }}>
                            <>
                                <Slider range value={sliderValue} min={1} max={20} onChange={onSliderChange} style={{}}/>
                            </>
                        </div>

                        <h4 className="global-button-style no-margin test-h4" style={{ gridRow: "9", gridColumn: "1/3", height: "fit-content", width: "fit-content", marginLeft: "auto", marginTop: "auto", padding: "2px 5px" }} onClick={() => setRefresh(!refresh)}>Refresh latest trades</h4>

                    </>}

                    {/* {selectedSortingMethod === "4" &&
                        <div style={{ display: "grid", gridTemplateRows: "repeat(5,1fr)", gridTemplateColumns: "repeat(2,1fr)", height: "100%", width: "100%", fontWeight: "100", fontFamily: "OL" }}>
                            <div style={{ gridRow: "1/2", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                                <h1 style={{ fontSize: "1.5rem", textAlign: "center" }}>Look for Specific Seller</h1>
                            </div>
                            <div style={{ gridRow: "2/5", gridColumn: "1/3", width: "100%", height: "100%" }}>
                                <Input.TextArea placeholder="Input the whole address you want to follow. for multiple addresses use slash `/` " onChange={(e) => setStringOfAddresses(e.target.value)} autoSize style={{ fontSize: "0.6vw", height: "100%" }} />
                            </div>

                            <div style={{ gridRow: "5/6", gridColumn: "1/3", width: "100%", height: "100%" }} className="center-via-flex">
                                <div className="global-button-style" style={{ fontSize: "1rem", padding: "5px 10px" }} onClick={() => fetchSpecificUsers()}>Refresh</div>
                            </div>
                        </div>
                    } */}

                </div>

                {/* <div style={{ height: "20%", width: "100%", display: "flex", justifyContent: "space-around", alignItems: "flex-start", flexDirection: "column", color: "white", padding: "5px 10px", boxSizing: "border-box" }}>
                    <Checkbox onChange={(e) => {setInvertTrade(e.target.checked)}} className="test-h4 no-margin" style={{color:"white"}}>Invert trades order </Checkbox>
                    <Checkbox onChange={(e) => {setInvertTrade(e.target.checked)}} className="test-h4" style={{color:"white"}}>Hide your trades</Checkbox>
                    <Checkbox onChange={(e) => {setInvertTrade(e.target.checked)}} className="test-h4" style={{color:"white"}} >Hide other's trades</Checkbox>
                </div> */}

            </div>
            <div style={{ height: "100%", width: "2%" }}></div>
            <div style={{ height: "100%", width: "60%", overflowY: "auto" }}>
                {tradeList.map((trade: TradeEdge, index: number) => {
                    return <ReinforcementListingElement trade={trade.node?.entity} key={index} />;
                })}

            </div>
            <div style={{ height: "100%", width: "9%" }}></div>
        </>
    );
}
