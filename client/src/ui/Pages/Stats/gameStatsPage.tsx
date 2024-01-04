//libs
import React, { useEffect, useState } from "react";
import { MenuState } from "../gamePhaseManager";
import { Dropdown, Space, Typography, Input, InputNumber, ConfigProvider } from "antd";
import { DownOutlined, UpOutlined } from '@ant-design/icons';
import {getComponentValueStrict} from "@latticexyz/recs";
import { Maybe } from "graphql/jsutils/Maybe";
import { request } from 'graphql-request';
import { useComponentValue , useEntityQuery} from '@latticexyz/react';

//styles
import "./StatsPageStyle.css";
import "../../../App.css"

//elements/components
import { ClickWrapper } from "../../clickWrapper";
import PageTitleElement from "../../Elements/pageTitleElement";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GAME_CONFIG_ID } from "../../../utils/settingsConstants";
import { useDojo } from "../../../hooks/useDojo";
import { GameEntityCounter, Outpost, OutpostEdge, PlayerInfo, PlayerInfoEdge, World__Entity } from "../../../generated/graphql";
import { truncateString } from "../../../utils";
import { Tooltip } from "@mui/material";

//pages

/*notes
    this will have 3 lists, each list can be refreshed and sorted

    the lists might be best to keep them not as elements but just do them here

    with graphql we can sort within the query so that might be the best way to do it
    query {
  getEntities(sortBy: "variableToSort", sortOrder: "ASC") {
    id
    name
    variableToSort
  }
}

    but this is to look into

    the lists will be strongest outpost which will be based on the lifes it has (this will be a query)
    if the user wants to sort the other way then maybe we need to get rid of everythign that has 0 lifes and then sort the rest

    major lords which will be based on the amount of outposts they have (this will not be a query instead just a normal loop)

    the lords with the most reinforcements sent to them (this will be a query)

    the lists can be their own comps

there is a specific query to call and to test so to makethe whole sorting on the databsae instead of the client side
*/


enum StatsState {
    TABLE,
    OVERALL
} 

interface StatsPageProps {
    setMenuState: React.Dispatch<React.SetStateAction<MenuState>>;
}

export const StatsPage: React.FC<StatsPageProps> = ({ setMenuState }) => {

    const [statsState, setStatsState] = useState<StatsState>(StatsState.TABLE);

    const closePage = () => {
        setMenuState(MenuState.NONE);
    };

    return (
        <ClickWrapper className="game-page-container">

            <img className="page-img brightness-down" src="./assets/Page_Bg/STATS_PAGE_BG.png" alt="testPic" />

            <PageTitleElement name={"STATISTICS"} rightPicture={"close_icon.svg"} closeFunction={closePage}></PageTitleElement>

            <div style={{ width: "100%", height: "5%", position: "relative"}}></div>

            <ClickWrapper style={{ display: "flex", flexDirection: "row", gap: "3%", position: "relative", width: "100%", height: "10%", fontSize: "1.6cqw"}}>
                
                    <div onClick={() => setStatsState(StatsState.TABLE)} style={{ opacity: statsState !== StatsState.TABLE ? 0.5 : 1, display: "flex", justifyContent: "flex-end", flex: "1" }}>
                        <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>TABLE OF DATA</div>
                    </div>

                <div  style={{ opacity: statsState !== StatsState.OVERALL  ? 0.5 : 1, display: "flex", justifyContent: "flex-start", flex: "1" }}>
                    <Tooltip title = "COMING SOON">
                    <div className="global-button-style" style={{ textAlign: "center", backgroundColor: "#2C2C2C", display: "flex", justifyContent: "center", alignItems: "center", padding: "2px 20px", width: "50%", boxSizing: "border-box", height: "fit-content", fontFamily: "Zelda", fontWeight: "100" }}>OVERALL GAME DATA</div>
                    </Tooltip>
                </div>
               
            </ClickWrapper>


            <ClickWrapper style={{ width: "100%", height: "75%", position: "relative", display: "flex", justifyContent: "space-between", flexDirection: "row" }}>
                {statsState === StatsState.TABLE && <StatsTable />}
                {statsState === StatsState.OVERALL && <OverallGameDataTable />}
            </ClickWrapper>

        </ClickWrapper>
    );
};



const OverallGameDataTable: React.FC = () => {

    const {
        networkLayer: {
          network: {  clientComponents, contractComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    const GameEntityCounter: GameEntityCounter = useComponentValue(contractComponents.GameEntityCounter,getEntityIdFromKeys([BigInt(clientGameData.current_game_id)]));

    return (
        <div style={{height:"90%", width:"95%", marginLeft:"2.5%", display:"grid", gridTemplateRows:"1fr 1fr", gridTemplateColumns:"1fr 1fr"}}>
           <div style={{gridRow:"1/2", gridColumn:"1/2", height:"100%", width:"100%", display:"grid", gridTemplateRows:"1fr 1fr", gridTemplateColumns:"1fr 1fr 1fr"}}>
                <h2 style={{gridRow:"1/2", gridColumn:"1/4"}} className="center-via-flex">Outpost</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"1/2"}} className="center-via-flex">Alive</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"3/4"}} className="center-via-flex">Dead</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"2/3"}} className="center-via-flex">Remaining</h2>
           </div>

           <div style={{gridRow:"1/2", gridColumn:"2/3", height:"100%", width:"100%", display:"grid", gridTemplateRows:"1fr 1fr", gridTemplateColumns:"1fr 1fr 1fr"}}>
                <h2 style={{gridRow:"1/2", gridColumn:"1/4"}} className="center-via-flex">Trades</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"1/2"}} className="center-via-flex">Sold</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"3/4"}} className="center-via-flex">Revoked</h2>
           </div>

           <div style={{gridRow:"2/3", gridColumn:"1/2", height:"100%", width:"100%",   display:"grid", gridTemplateRows:"1fr 1fr", gridTemplateColumns:"1fr 1fr 1fr"}}>
                <h2 style={{gridRow:"1/2", gridColumn:"1/4"}} className="center-via-flex">Reinforcements</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"1/2"}} className="center-via-flex">In outposts</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"3/4"}} className="center-via-flex">In Wallets</h2>
                <h2 style={{gridRow:"2/3", gridColumn:"2/3"}} className="center-via-flex">In Trades</h2>
           </div>

           <div style={{gridRow:"2/3", gridColumn:"2/3", height:"100%", width:"100%",  display:"flex", justifyContent:"center", flexDirection:"column", alignItems:"center"}} >
                <h2>Num of players</h2>
                <h2>jackpot</h2>
           </div>
        </div>
    )
}




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



const graphqlStructure = [
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

const StatsTable: React.FC = () => {

    const [directionSorting, setDirectionSorting] = useState<boolean>(true);    //false is ASC      true is DESC
    const [dataList, setDataList] = useState<any | undefined[]>([]);
    const [dataPoints, setDataPoints] = useState<number | null>(25);

    const [category, setCategory] = useState<string>("1");
    const [savedLastQuery, setSavedLastQuery] = useState<string | null>();

    const [selectedSortingIndex, setSelectedSortingMethod] = useState<number>(0);

    const onClick = ({ key }) => {
        setDataList([])
        setCategory(key);
        setSelectedSortingMethod(0);
        setDirectionSorting(true);
    };

    const {
        networkLayer: {
          network: {  clientComponents },
        },
    } = useDojo();

    const clientGameData = getComponentValueStrict(clientComponents.ClientGameData, getEntityIdFromKeys([BigInt(GAME_CONFIG_ID)]));

    useEffect(() => {
        createGraphQlRequest(0, "SCORE","playerinfoModels"); 
        setSelectedSortingMethod(1);
    }, []);

    const createGraphQlRequest = async (indexOfStructure: number, nameOfVar: string, modelName: string) => {
        // Extract the GraphQL structure at the specified index
        const selectedStructure = graphqlStructure[indexOfStructure];
      
        // Define the direction based on the boolean value
        const orderDirection = directionSorting ? 'DESC' : 'ASC';

        setDirectionSorting(!directionSorting)
      
        // add the others
        const graphqlRequest = selectedStructure
          .replace('DIR', orderDirection)
          .replace('VAR_NAME', nameOfVar)
          .replace('NUM_DATA', dataPoints!.toString())
          .replace('GAME_ID', clientGameData.current_game_id.toString());
        
        const endpoint = import.meta.env.VITE_PUBLIC_TORII; 

        console.error(graphqlRequest);

        try {
            const data: any = await request(endpoint, graphqlRequest);
            setDataList(data[modelName].edges)

            setSavedLastQuery(graphqlRequest);
        
        } catch (error) {
            console.error('Error executing GraphQL query:', error);
            throw error;
        }
    };

    const refreshPage = async () => {
        if (savedLastQuery === null || savedLastQuery === undefined) {return;}

        const endpoint = import.meta.env.VITE_PUBLIC_TORII; 

        try {
            const data: any = await request(endpoint, savedLastQuery);
            setDataList(data.playerinfoModels.edges)
        
        } catch (error) {
            console.error('Error executing GraphQL query:', error);
            throw error;
        }
    }
    
    return (
        <ClickWrapper style={{height:"100%", width:"90%", marginLeft:"5%",  display:"flex", flexDirection:"column", fontSize:"1.5rem", color:"white"}}>

            <div style={{ width:"100%", height:"10%",display:"flex", justifyContent:"center", alignItems:"center", flexDirection:"row", scrollbarGutter:"stable"}}>
                <div style={{height:"100%", width:"15%"}} className="center-via-flex">
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
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex pointer" onClick={() => {createGraphQlRequest(0, "SCORE","playerinfoModels"); setSelectedSortingMethod(1);}}> Contribution Score { selectedSortingIndex === 1  &&  <>{directionSorting ? <DownOutlined/> : <UpOutlined/>}</>} </Space>
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex pointer" onClick={() => {createGraphQlRequest(0, "OUTPOST_COUNT","playerinfoModels"); setSelectedSortingMethod(2);}}> Revenants Count { selectedSortingIndex === 2  &&  <>{directionSorting ? <DownOutlined/> : <UpOutlined/>}</>} </Space>
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex pointer" onClick={() => {createGraphQlRequest(0, "REINFORCEMENT_COUNT","playerinfoModels");  setSelectedSortingMethod(3);}}> Reinforcements in wallet  { selectedSortingIndex === 3  &&  <>{directionSorting ? <DownOutlined/> : <UpOutlined/>}</>} </Space>
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex"> Trades up </Space>
                </>}

                {category === "2" && <>
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex pointer" onClick={() => {createGraphQlRequest(1, "LIFES","outpostModels"); setSelectedSortingMethod(1);}}> Reinforcements { selectedSortingIndex === 1  &&  <>{directionSorting ? <DownOutlined/> : <UpOutlined/>}</>} </Space>
                        <Space style={{flex:"1", height:"100%"}} className="center-via-flex pointer" onClick={() => {createGraphQlRequest(1, "SHIELD","outpostModels"); setSelectedSortingMethod(2);}}> Shields { selectedSortingIndex === 2  &&  <>{directionSorting ? <DownOutlined/> : <UpOutlined/>}</>} </Space>
                        <div style={{flex:"1", height:"100%"}} className="center-via-flex">Position</div>
                        <div style={{flex:"1", height:"100%"}} className="center-via-flex">Owner</div>
                        <div style={{flex:"1", height:"100%"}} className="center-via-flex">Selling?</div>
                </>}

                {category === "3" && <>
                        <div style={{flex:"1", height:"100%"}} className="center-via-flex">Coming soon!!!</div>
                </>}

            </div>

                <div style={{ width:"100%", height:"75%", overflowY:"auto", scrollbarGutter:"stable"}}>

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

                    {/* {category === "3" && <>
                        {dataList.map((trade: TradeEdge, index: number) => {
                            return <ReinforcementListingElement trade={trade.node?.entity} key={index} />;
                        })}
                    </>} */}
                </div>

                <div style={{ width:"100%", height:"15%",display:"flex", justifyContent:"space-between", alignItems:"center"}}>
                    <div className="global-button-style" style={{ textAlign: "center", fontSize:"1.5rem", padding:"5px 10px" }} onClick={refreshPage}>Refresh Data</div>
                        <Space >
                            MAX DATA POINTS
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
        <ClickWrapper style={{width:"100%", height:"100px",  marginBottom:"5px", display:"flex", flexDirection:"row"}}>
            <div style={{height:"100%", width:"15%"}} onClick={() => navigator.clipboard.writeText(playerInfoModel.owner)} className="center-via-flex pointer">{truncateString(playerInfoModel.owner,10)}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`${playerInfoModel.score}`}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`${playerInfoModel.revenant_count}`}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`${playerInfoModel.reinforcement_count}`}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">coming soon!!</div>
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
        <ClickWrapper style={{width:"100%", height:"100px", marginBottom:"5px", display:"flex", flexDirection:"row"}}>
            <div style={{height:"100%", width:"15%"}} className="center-via-flex pointer">Outpost Id: {Number(outpostModel.entity_id).toString()}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`${outpostModel.lifes}`}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`${outpostModel.shield}`}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`X:${outpostModel.x} || Y:${outpostModel.y}`}</div>
            <div style={{height:"100%", flex:"1"}} onClick={() => navigator.clipboard.writeText(outpostModel.owner)} className="center-via-flex pointer">{truncateString(outpostModel.owner,5)}</div>
            <div style={{height:"100%", flex:"1"}} className="center-via-flex">{`coming soon`}</div>
        </ClickWrapper >
    );
};



