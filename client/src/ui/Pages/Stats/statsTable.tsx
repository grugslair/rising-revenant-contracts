//libs
import React, { useEffect, useState } from "react";
import { Dropdown, Space, InputNumber } from "antd";
import { DownOutlined, UpOutlined } from '@ant-design/icons';
import { Maybe } from "graphql/jsutils/Maybe";
import { request } from 'graphql-request';
import { getComponentValueStrict } from "@latticexyz/recs";

//styles
import "./StatsPageStyle.css";
import "../../../App.css"

//elements/components
import { ClickWrapper } from "../../clickWrapper";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";
import { useDojo } from "../../../hooks/useDojo";
import { Outpost, OutpostEdge, PlayerInfo, PlayerInfoEdge, World__Entity } from "../../../generated/graphql";
import { truncateString } from "../../../utils";

const items = [
    {
        label: 'Sort by Players',
        key: "1",
    },
    {
        label: 'Sort by Outposts',
        key: "2",
    },
    {
        label: 'sort by Revenants',
        key: "3",
    },
];

const mainGraphqlStructure = [
    `
query {
    playerinfoModels(
      where: { game_id: GAME_ID }
      first: NUM_DATA
      order: { direction: DIR , field: VAR_NAME }
    ) {
      edges {
        node {
          entity {
            keys
            models {
              __typename
              ... on PlayerInfo {
                game_id
                owner
                score
                score_claim_status
                earned_prize
                revenant_count
                outpost_count
                reinforcement_count
                inited
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
    outpostModels(
      where: { game_id: GAME_ID }
      first: NUM_DATA
      order: { direction: DIR , field: VAR_NAME }
    ) {
      edges {
        node {
          entity {
            keys
            models {
              __typename
              ... on Outpost {
                game_id
                entity_id
                owner
                name_outpost
                x
                y
                lifes
                shield
                reinforcement_count
                status
                last_affect_event_id
              }
            }
          }
        }
      }
    }
  }
`
]


export const StatsTable: React.FC = () => {

    const [directionSorting, setDirectionSorting] = useState<boolean>(true);    //false is ASC      true is DESC
    const [dataList, setDataList] = useState<any | undefined[]>([]);
    const [dataPoints, setDataPoints] = useState<number | null>(25);

    const [category, setCategory] = useState<string>("1");
    const [savedLastQuery, setSavedLastQuery] = useState<string[]>();

    const [selectedSortingIndex, setSelectedSortingMethod] = useState<number>(0);

    const onClick = ({ key }) => {
        setDataList([])
        setCategory(key);
        setSelectedSortingMethod(0);
        setDirectionSorting(true);

        switch (key) {
            case "1":
                createGraphQlRequest(0, "SCORE", "playerinfoModels");
                break;

            case "2":
                createGraphQlRequest(1, "LIFES", "outpostModels");
                break;

            // case "3":

            //     break;

            default:
                break;
        }
    };

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {
        createGraphQlRequest(0, "SCORE", "playerinfoModels");
        setSelectedSortingMethod(1);
    }, []);

    const createGraphQlRequest = async (indexOfStructure: number, nameOfVar: string, modelName: string) => {
        const selectedStructure = mainGraphqlStructure[indexOfStructure];

        const orderDirection = directionSorting ? 'DESC' : 'ASC';

        setDirectionSorting(!directionSorting)

        const graphqlRequest = selectedStructure
            .replace('DIR', orderDirection)
            .replace('VAR_NAME', nameOfVar)
            .replace('NUM_DATA', dataPoints!.toString())
            .replace('GAME_ID', clientGameData.current_game_id.toString());

        setSavedLastQuery([graphqlRequest, modelName]);
    };

    useEffect(() => {
        createGraphQLQuery();

        const intervalId = setInterval(() => {
            createGraphQLQuery();
        }, 10000);

        return () => clearInterval(intervalId);
    }, [savedLastQuery]);

    const createGraphQLQuery = async () => {
        if (savedLastQuery![0] === null || savedLastQuery![1] === null) { return; }
        if (savedLastQuery![0] === "" || savedLastQuery![1] === "") { return; }

        const endpoint = import.meta.env.VITE_PUBLIC_TORII;

        try {
            const data: any = await request(endpoint, savedLastQuery![0]);
            setDataList(data[savedLastQuery![1]].edges)

        } catch (error) {
            console.error('Error executing GraphQL query:', error);
            throw error;
        }
    }

    return (
        <ClickWrapper style={{ height: "100%", width: "90%", marginLeft: "5%", display: "flex", flexDirection: "column", fontSize: "1.5rem", color: "white" }}>

            <div style={{ width: "100%", height: "10%", display: "flex", justifyContent: "center", alignItems: "center", flexDirection: "row", scrollbarGutter: "stable" }}>
                <div style={{ height: "100%", width: "15%" }} className="center-via-flex">
                    <Dropdown
                        menu={{
                            items,
                            onClick,
                        }}
                        placement="bottom"
                    >
                        {/* the drop down is for the menu that comes out */}
                        <a onClick={(e) => e.preventDefault()} className="pointer" style={{ backgroundColor: "#D0D0D0", width: "90%", height: "80%", display: "flex", justifyContent: "flex-start", alignItems: "center", borderRadius: "4px", color: "black", padding: "1% 2%", boxSizing: "border-box", fontWeight: "100", fontFamily: "OL" }}>
                            <Space style={{ width: "100%", fontSize: "1rem", }}>
                                {items.find(item => item.key === category.toString())?.label || 'None'}
                            </Space>
                        </a>
                    </Dropdown>
                </div>

                {category === "1" && <>
                    <Space style={{ flex: "1", height: "100%", whiteSpace:"nowrap"  }} className="center-via-flex pointer test-h2" onClick={() => { createGraphQlRequest(0, "SCORE", "playerinfoModels"); setSelectedSortingMethod(1); }}> Contribution Score {selectedSortingIndex === 1 && <>{directionSorting ? <DownOutlined /> : <UpOutlined />}</>} </Space>
                    <Space style={{ flex: "1", height: "100%", whiteSpace:"nowrap"  }} className="center-via-flex pointer test-h2" onClick={() => { createGraphQlRequest(0, "OUTPOST_COUNT", "playerinfoModels"); setSelectedSortingMethod(2); }}> Revenants Count {selectedSortingIndex === 2 && <>{directionSorting ? <DownOutlined /> : <UpOutlined />}</>} </Space>
                    <Space style={{ flex: "1", height: "100%" , whiteSpace:"nowrap" }} className="center-via-flex pointer test-h2" onClick={() => { createGraphQlRequest(0, "REINFORCEMENT_COUNT", "playerinfoModels"); setSelectedSortingMethod(3); }}> Reinforcements  {selectedSortingIndex === 3 && <>{directionSorting ? <DownOutlined /> : <UpOutlined />}</>} </Space>
                    <Space style={{ flex: "1", height: "100%", whiteSpace:"nowrap" }} className="center-via-flex test-h2"> Trades up </Space>
                </>}

                {category === "2" && <>
                    <Space style={{ flex: "1", height: "100%" }} className="center-via-flex pointer test-h2" onClick={() => { createGraphQlRequest(1, "LIFES", "outpostModels"); setSelectedSortingMethod(1); }}> Reinforcements {selectedSortingIndex === 1 && <>{directionSorting ? <DownOutlined /> : <UpOutlined />}</>} </Space>
                    <Space style={{ flex: "1", height: "100%" }} className="center-via-flex pointer test-h2" onClick={() => { createGraphQlRequest(1, "SHIELD", "outpostModels"); setSelectedSortingMethod(2); }}> Shields {selectedSortingIndex === 2 && <>{directionSorting ? <DownOutlined /> : <UpOutlined />}</>} </Space>
                    <div style={{ flex: "1", height: "100%" }} className="center-via-flex test-h2">Position</div>
                    <div style={{ flex: "1", height: "100%" }} className="center-via-flex test-h2">Owner</div>
                    <div style={{ flex: "1", height: "100%" }} className="center-via-flex test-h2">Selling?</div>
                </>}

                {category === "3" && <>
                    <div style={{ flex: "1", height: "100%" }} className="center-via-flex test-h2">Coming soon!!!</div>
                </>}

            </div>

            <div style={{ width: "100%", height: "65%", overflowY: "auto", scrollbarGutter: "stable" }}>

                {category === "1" && <>
                    {dataList.map((playerInfo: PlayerInfoEdge, index: number) => {
                        return <PlayerInfoElement playerinfo={playerInfo.node?.entity} key={index} />;
                    })}
                </>}

                {category === "2" && <>
                    {dataList.map((outpost: OutpostEdge, index: number) => {
                        return <OutpostElement outpost={outpost.node?.entity} key={index} />;
                    })}
                </>}

            </div>
            <div style={{ width: "100%", height: "5%" }}> </div>

            <div style={{ width: "100%", height: "10%", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div className="global-button-style invert-colors " style={{ textAlign: "center", fontSize: "1.5rem", padding: "5px 10px" }} onClick={() => setSavedLastQuery(savedLastQuery)}>Refresh Data</div>
                <Space >
                    Number of data points
                    <InputNumber min={2} max={100} value={dataPoints} onChange={setDataPoints} style={{ width: "100%", height: "45%", fontSize: "1.5rem" }} />
                </Space>
            </div>
        </ClickWrapper>
    )
}


const PlayerInfoElement = ({ playerinfo }: { playerinfo: Maybe<World__Entity> | undefined }) => {
    const playerInfoModel = playerinfo?.models?.find((m) => m?.__typename == 'PlayerInfo') as PlayerInfo;

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    const clientGameDate = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    return (
        <ClickWrapper style={{ width: "100%", height: "100px", marginBottom: "5px", display: "flex", flexDirection: "row" }}>
            <div style={{ height: "100%", width: "15%" }} onClick={() => navigator.clipboard.writeText(playerInfoModel.owner)} className="center-via-flex pointer test-h3">{truncateString(playerInfoModel.owner, 10)}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">{`${playerInfoModel.score}`}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">{`${playerInfoModel.revenant_count}`}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">{`${playerInfoModel.reinforcement_count}`}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">coming soon!!</div>
        </ClickWrapper >
    );
};

const OutpostElement = ({ outpost }: { outpost: Maybe<World__Entity> | undefined }) => {
    const outpostModel = outpost?.models?.find((m) => m?.__typename == 'Outpost') as Outpost;

    const {
        networkLayer: {
            network: { clientComponents },
        },
    } = useDojo();

    const clientGameDate = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    return (
        <ClickWrapper style={{ width: "100%", height: "100px", marginBottom: "5px", display: "flex", flexDirection: "row" }}>
            <div style={{ height: "100%", width: "15%" }} className="center-via-flex pointer test-h3">Outpost Id: {Number(outpostModel.entity_id).toString()}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">{`${outpostModel.lifes}`}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">{`${outpostModel.shield}`}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3 ">{`X:${outpostModel.x} || Y:${outpostModel.y}`}</div>
            <div style={{ height: "100%", flex: "1" }} onClick={() => navigator.clipboard.writeText(outpostModel.owner)} className="center-via-flex pointer test-h3">{truncateString(outpostModel.owner, 5)}</div>
            <div style={{ height: "100%", flex: "1" }} className="center-via-flex test-h3">coming soon</div>
        </ClickWrapper >
    );
};



