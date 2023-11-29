import { GraphQLClient } from 'graphql-request';
import { GraphQLClientRequestHeaders } from 'graphql-request/build/cjs/types';
import { print } from 'graphql'
import gql from 'graphql-tag';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  ContractAddress: { input: any; output: any; }
  Cursor: { input: any; output: any; }
  DateTime: { input: any; output: any; }
  bool: { input: any; output: any; }
  felt252: { input: any; output: any; }
  u32: { input: any; output: any; }
  u64: { input: any; output: any; }
  u128: { input: any; output: any; }
};

export type Game = {
  __typename?: 'Game';
  admin?: Maybe<Scalars['ContractAddress']['output']>;
  entity?: Maybe<World__Entity>;
  erc_addr?: Maybe<Scalars['ContractAddress']['output']>;
  event_interval?: Maybe<Scalars['u64']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  preparation_phase_interval?: Maybe<Scalars['u64']['output']>;
  prize?: Maybe<Scalars['u32']['output']>;
  start_block_number?: Maybe<Scalars['u64']['output']>;
  status?: Maybe<Scalars['u32']['output']>;
};

export type GameConnection = {
  __typename?: 'GameConnection';
  edges?: Maybe<Array<Maybe<GameEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type GameEdge = {
  __typename?: 'GameEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<Game>;
};

export type GameEntityCounter = {
  __typename?: 'GameEntityCounter';
  entity?: Maybe<World__Entity>;
  event_count?: Maybe<Scalars['u32']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  outpost_count?: Maybe<Scalars['u32']['output']>;
  outpost_exists_count?: Maybe<Scalars['u32']['output']>;
  reinforcement_count?: Maybe<Scalars['u32']['output']>;
  remain_life_count?: Maybe<Scalars['u32']['output']>;
  revenant_count?: Maybe<Scalars['u32']['output']>;
  trade_count?: Maybe<Scalars['u32']['output']>;
};

export type GameEntityCounterConnection = {
  __typename?: 'GameEntityCounterConnection';
  edges?: Maybe<Array<Maybe<GameEntityCounterEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type GameEntityCounterEdge = {
  __typename?: 'GameEntityCounterEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<GameEntityCounter>;
};

export type GameEntityCounterOrder = {
  direction: OrderDirection;
  field: GameEntityCounterOrderField;
};

export enum GameEntityCounterOrderField {
  EventCount = 'EVENT_COUNT',
  GameId = 'GAME_ID',
  OutpostCount = 'OUTPOST_COUNT',
  OutpostExistsCount = 'OUTPOST_EXISTS_COUNT',
  ReinforcementCount = 'REINFORCEMENT_COUNT',
  RemainLifeCount = 'REMAIN_LIFE_COUNT',
  RevenantCount = 'REVENANT_COUNT',
  TradeCount = 'TRADE_COUNT'
}

export type GameEntityCounterWhereInput = {
  event_count?: InputMaybe<Scalars['u32']['input']>;
  event_countEQ?: InputMaybe<Scalars['u32']['input']>;
  event_countGT?: InputMaybe<Scalars['u32']['input']>;
  event_countGTE?: InputMaybe<Scalars['u32']['input']>;
  event_countLT?: InputMaybe<Scalars['u32']['input']>;
  event_countLTE?: InputMaybe<Scalars['u32']['input']>;
  event_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_count?: InputMaybe<Scalars['u32']['input']>;
  outpost_countEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_count?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countGT?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countGTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countLT?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countLTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_exists_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_count?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countEQ?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countGT?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countGTE?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countLT?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countLTE?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  remain_life_count?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countEQ?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countGT?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countGTE?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countLT?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countLTE?: InputMaybe<Scalars['u32']['input']>;
  remain_life_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  revenant_count?: InputMaybe<Scalars['u32']['input']>;
  revenant_countEQ?: InputMaybe<Scalars['u32']['input']>;
  revenant_countGT?: InputMaybe<Scalars['u32']['input']>;
  revenant_countGTE?: InputMaybe<Scalars['u32']['input']>;
  revenant_countLT?: InputMaybe<Scalars['u32']['input']>;
  revenant_countLTE?: InputMaybe<Scalars['u32']['input']>;
  revenant_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  trade_count?: InputMaybe<Scalars['u32']['input']>;
  trade_countEQ?: InputMaybe<Scalars['u32']['input']>;
  trade_countGT?: InputMaybe<Scalars['u32']['input']>;
  trade_countGTE?: InputMaybe<Scalars['u32']['input']>;
  trade_countLT?: InputMaybe<Scalars['u32']['input']>;
  trade_countLTE?: InputMaybe<Scalars['u32']['input']>;
  trade_countNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type GameOrder = {
  direction: OrderDirection;
  field: GameOrderField;
};

export enum GameOrderField {
  Admin = 'ADMIN',
  ErcAddr = 'ERC_ADDR',
  EventInterval = 'EVENT_INTERVAL',
  GameId = 'GAME_ID',
  PreparationPhaseInterval = 'PREPARATION_PHASE_INTERVAL',
  Prize = 'PRIZE',
  StartBlockNumber = 'START_BLOCK_NUMBER',
  Status = 'STATUS'
}

export type GameTracker = {
  __typename?: 'GameTracker';
  count?: Maybe<Scalars['u32']['output']>;
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u128']['output']>;
};

export type GameTrackerConnection = {
  __typename?: 'GameTrackerConnection';
  edges?: Maybe<Array<Maybe<GameTrackerEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type GameTrackerEdge = {
  __typename?: 'GameTrackerEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<GameTracker>;
};

export type GameTrackerOrder = {
  direction: OrderDirection;
  field: GameTrackerOrderField;
};

export enum GameTrackerOrderField {
  Count = 'COUNT',
  EntityId = 'ENTITY_ID'
}

export type GameTrackerWhereInput = {
  count?: InputMaybe<Scalars['u32']['input']>;
  countEQ?: InputMaybe<Scalars['u32']['input']>;
  countGT?: InputMaybe<Scalars['u32']['input']>;
  countGTE?: InputMaybe<Scalars['u32']['input']>;
  countLT?: InputMaybe<Scalars['u32']['input']>;
  countLTE?: InputMaybe<Scalars['u32']['input']>;
  countNEQ?: InputMaybe<Scalars['u32']['input']>;
  entity_id?: InputMaybe<Scalars['u128']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u128']['input']>;
  entity_idGT?: InputMaybe<Scalars['u128']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idLT?: InputMaybe<Scalars['u128']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u128']['input']>;
};

export type GameWhereInput = {
  admin?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  adminNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addr?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  erc_addrNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  event_interval?: InputMaybe<Scalars['u64']['input']>;
  event_intervalEQ?: InputMaybe<Scalars['u64']['input']>;
  event_intervalGT?: InputMaybe<Scalars['u64']['input']>;
  event_intervalGTE?: InputMaybe<Scalars['u64']['input']>;
  event_intervalLT?: InputMaybe<Scalars['u64']['input']>;
  event_intervalLTE?: InputMaybe<Scalars['u64']['input']>;
  event_intervalNEQ?: InputMaybe<Scalars['u64']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  preparation_phase_interval?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalEQ?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalGT?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalGTE?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalLT?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalLTE?: InputMaybe<Scalars['u64']['input']>;
  preparation_phase_intervalNEQ?: InputMaybe<Scalars['u64']['input']>;
  prize?: InputMaybe<Scalars['u32']['input']>;
  prizeEQ?: InputMaybe<Scalars['u32']['input']>;
  prizeGT?: InputMaybe<Scalars['u32']['input']>;
  prizeGTE?: InputMaybe<Scalars['u32']['input']>;
  prizeLT?: InputMaybe<Scalars['u32']['input']>;
  prizeLTE?: InputMaybe<Scalars['u32']['input']>;
  prizeNEQ?: InputMaybe<Scalars['u32']['input']>;
  start_block_number?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberEQ?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberGT?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberGTE?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberLT?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberLTE?: InputMaybe<Scalars['u64']['input']>;
  start_block_numberNEQ?: InputMaybe<Scalars['u64']['input']>;
  status?: InputMaybe<Scalars['u32']['input']>;
  statusEQ?: InputMaybe<Scalars['u32']['input']>;
  statusGT?: InputMaybe<Scalars['u32']['input']>;
  statusGTE?: InputMaybe<Scalars['u32']['input']>;
  statusLT?: InputMaybe<Scalars['u32']['input']>;
  statusLTE?: InputMaybe<Scalars['u32']['input']>;
  statusNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type ModelUnion = Game | GameEntityCounter | GameTracker | Outpost | OutpostPosition | PlayerInfo | ReinforcementBalance | Revenant | Trade | WorldEvent | WorldEventTracker;

export enum OrderDirection {
  Asc = 'ASC',
  Desc = 'DESC'
}

export type Outpost = {
  __typename?: 'Outpost';
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u128']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  last_affect_event_id?: Maybe<Scalars['u128']['output']>;
  lifes?: Maybe<Scalars['u32']['output']>;
  name_outpost?: Maybe<Scalars['felt252']['output']>;
  owner?: Maybe<Scalars['ContractAddress']['output']>;
  status?: Maybe<Scalars['u32']['output']>;
  x?: Maybe<Scalars['u32']['output']>;
  y?: Maybe<Scalars['u32']['output']>;
};

export type OutpostConnection = {
  __typename?: 'OutpostConnection';
  edges?: Maybe<Array<Maybe<OutpostEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type OutpostEdge = {
  __typename?: 'OutpostEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<Outpost>;
};

export type OutpostOrder = {
  direction: OrderDirection;
  field: OutpostOrderField;
};

export enum OutpostOrderField {
  EntityId = 'ENTITY_ID',
  GameId = 'GAME_ID',
  LastAffectEventId = 'LAST_AFFECT_EVENT_ID',
  Lifes = 'LIFES',
  NameOutpost = 'NAME_OUTPOST',
  Owner = 'OWNER',
  Status = 'STATUS',
  X = 'X',
  Y = 'Y'
}

export type OutpostPosition = {
  __typename?: 'OutpostPosition';
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u128']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  x?: Maybe<Scalars['u32']['output']>;
  y?: Maybe<Scalars['u32']['output']>;
};

export type OutpostPositionConnection = {
  __typename?: 'OutpostPositionConnection';
  edges?: Maybe<Array<Maybe<OutpostPositionEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type OutpostPositionEdge = {
  __typename?: 'OutpostPositionEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<OutpostPosition>;
};

export type OutpostPositionOrder = {
  direction: OrderDirection;
  field: OutpostPositionOrderField;
};

export enum OutpostPositionOrderField {
  EntityId = 'ENTITY_ID',
  GameId = 'GAME_ID',
  X = 'X',
  Y = 'Y'
}

export type OutpostPositionWhereInput = {
  entity_id?: InputMaybe<Scalars['u128']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u128']['input']>;
  entity_idGT?: InputMaybe<Scalars['u128']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idLT?: InputMaybe<Scalars['u128']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  x?: InputMaybe<Scalars['u32']['input']>;
  xEQ?: InputMaybe<Scalars['u32']['input']>;
  xGT?: InputMaybe<Scalars['u32']['input']>;
  xGTE?: InputMaybe<Scalars['u32']['input']>;
  xLT?: InputMaybe<Scalars['u32']['input']>;
  xLTE?: InputMaybe<Scalars['u32']['input']>;
  xNEQ?: InputMaybe<Scalars['u32']['input']>;
  y?: InputMaybe<Scalars['u32']['input']>;
  yEQ?: InputMaybe<Scalars['u32']['input']>;
  yGT?: InputMaybe<Scalars['u32']['input']>;
  yGTE?: InputMaybe<Scalars['u32']['input']>;
  yLT?: InputMaybe<Scalars['u32']['input']>;
  yLTE?: InputMaybe<Scalars['u32']['input']>;
  yNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type OutpostWhereInput = {
  entity_id?: InputMaybe<Scalars['u128']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u128']['input']>;
  entity_idGT?: InputMaybe<Scalars['u128']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idLT?: InputMaybe<Scalars['u128']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  last_affect_event_id?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idEQ?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idGT?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idGTE?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idLT?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idLTE?: InputMaybe<Scalars['u128']['input']>;
  last_affect_event_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  lifes?: InputMaybe<Scalars['u32']['input']>;
  lifesEQ?: InputMaybe<Scalars['u32']['input']>;
  lifesGT?: InputMaybe<Scalars['u32']['input']>;
  lifesGTE?: InputMaybe<Scalars['u32']['input']>;
  lifesLT?: InputMaybe<Scalars['u32']['input']>;
  lifesLTE?: InputMaybe<Scalars['u32']['input']>;
  lifesNEQ?: InputMaybe<Scalars['u32']['input']>;
  name_outpost?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostEQ?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostGT?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostGTE?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostLT?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostLTE?: InputMaybe<Scalars['felt252']['input']>;
  name_outpostNEQ?: InputMaybe<Scalars['felt252']['input']>;
  owner?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  status?: InputMaybe<Scalars['u32']['input']>;
  statusEQ?: InputMaybe<Scalars['u32']['input']>;
  statusGT?: InputMaybe<Scalars['u32']['input']>;
  statusGTE?: InputMaybe<Scalars['u32']['input']>;
  statusLT?: InputMaybe<Scalars['u32']['input']>;
  statusLTE?: InputMaybe<Scalars['u32']['input']>;
  statusNEQ?: InputMaybe<Scalars['u32']['input']>;
  x?: InputMaybe<Scalars['u32']['input']>;
  xEQ?: InputMaybe<Scalars['u32']['input']>;
  xGT?: InputMaybe<Scalars['u32']['input']>;
  xGTE?: InputMaybe<Scalars['u32']['input']>;
  xLT?: InputMaybe<Scalars['u32']['input']>;
  xLTE?: InputMaybe<Scalars['u32']['input']>;
  xNEQ?: InputMaybe<Scalars['u32']['input']>;
  y?: InputMaybe<Scalars['u32']['input']>;
  yEQ?: InputMaybe<Scalars['u32']['input']>;
  yGT?: InputMaybe<Scalars['u32']['input']>;
  yGTE?: InputMaybe<Scalars['u32']['input']>;
  yLT?: InputMaybe<Scalars['u32']['input']>;
  yLTE?: InputMaybe<Scalars['u32']['input']>;
  yNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type PlayerInfo = {
  __typename?: 'PlayerInfo';
  entity?: Maybe<World__Entity>;
  game_id?: Maybe<Scalars['u32']['output']>;
  inited?: Maybe<Scalars['bool']['output']>;
  outpost_count?: Maybe<Scalars['u32']['output']>;
  owner?: Maybe<Scalars['ContractAddress']['output']>;
  reinforcement_count?: Maybe<Scalars['u32']['output']>;
  revenant_count?: Maybe<Scalars['u32']['output']>;
};

export type PlayerInfoConnection = {
  __typename?: 'PlayerInfoConnection';
  edges?: Maybe<Array<Maybe<PlayerInfoEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type PlayerInfoEdge = {
  __typename?: 'PlayerInfoEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<PlayerInfo>;
};

export type PlayerInfoOrder = {
  direction: OrderDirection;
  field: PlayerInfoOrderField;
};

export enum PlayerInfoOrderField {
  GameId = 'GAME_ID',
  Inited = 'INITED',
  OutpostCount = 'OUTPOST_COUNT',
  Owner = 'OWNER',
  ReinforcementCount = 'REINFORCEMENT_COUNT',
  RevenantCount = 'REVENANT_COUNT'
}

export type PlayerInfoWhereInput = {
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  inited?: InputMaybe<Scalars['bool']['input']>;
  initedEQ?: InputMaybe<Scalars['bool']['input']>;
  initedGT?: InputMaybe<Scalars['bool']['input']>;
  initedGTE?: InputMaybe<Scalars['bool']['input']>;
  initedLT?: InputMaybe<Scalars['bool']['input']>;
  initedLTE?: InputMaybe<Scalars['bool']['input']>;
  initedNEQ?: InputMaybe<Scalars['bool']['input']>;
  outpost_count?: InputMaybe<Scalars['u32']['input']>;
  outpost_countEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  owner?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  reinforcement_count?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countEQ?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countGT?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countGTE?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countLT?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countLTE?: InputMaybe<Scalars['u32']['input']>;
  reinforcement_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  revenant_count?: InputMaybe<Scalars['u32']['input']>;
  revenant_countEQ?: InputMaybe<Scalars['u32']['input']>;
  revenant_countGT?: InputMaybe<Scalars['u32']['input']>;
  revenant_countGTE?: InputMaybe<Scalars['u32']['input']>;
  revenant_countLT?: InputMaybe<Scalars['u32']['input']>;
  revenant_countLTE?: InputMaybe<Scalars['u32']['input']>;
  revenant_countNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type ReinforcementBalance = {
  __typename?: 'ReinforcementBalance';
  count?: Maybe<Scalars['u32']['output']>;
  entity?: Maybe<World__Entity>;
  game_id?: Maybe<Scalars['u32']['output']>;
  start_timestamp?: Maybe<Scalars['u64']['output']>;
  target_price?: Maybe<Scalars['u128']['output']>;
};

export type ReinforcementBalanceConnection = {
  __typename?: 'ReinforcementBalanceConnection';
  edges?: Maybe<Array<Maybe<ReinforcementBalanceEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type ReinforcementBalanceEdge = {
  __typename?: 'ReinforcementBalanceEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<ReinforcementBalance>;
};

export type ReinforcementBalanceOrder = {
  direction: OrderDirection;
  field: ReinforcementBalanceOrderField;
};

export enum ReinforcementBalanceOrderField {
  Count = 'COUNT',
  GameId = 'GAME_ID',
  StartTimestamp = 'START_TIMESTAMP',
  TargetPrice = 'TARGET_PRICE'
}

export type ReinforcementBalanceWhereInput = {
  count?: InputMaybe<Scalars['u32']['input']>;
  countEQ?: InputMaybe<Scalars['u32']['input']>;
  countGT?: InputMaybe<Scalars['u32']['input']>;
  countGTE?: InputMaybe<Scalars['u32']['input']>;
  countLT?: InputMaybe<Scalars['u32']['input']>;
  countLTE?: InputMaybe<Scalars['u32']['input']>;
  countNEQ?: InputMaybe<Scalars['u32']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  start_timestamp?: InputMaybe<Scalars['u64']['input']>;
  start_timestampEQ?: InputMaybe<Scalars['u64']['input']>;
  start_timestampGT?: InputMaybe<Scalars['u64']['input']>;
  start_timestampGTE?: InputMaybe<Scalars['u64']['input']>;
  start_timestampLT?: InputMaybe<Scalars['u64']['input']>;
  start_timestampLTE?: InputMaybe<Scalars['u64']['input']>;
  start_timestampNEQ?: InputMaybe<Scalars['u64']['input']>;
  target_price?: InputMaybe<Scalars['u128']['input']>;
  target_priceEQ?: InputMaybe<Scalars['u128']['input']>;
  target_priceGT?: InputMaybe<Scalars['u128']['input']>;
  target_priceGTE?: InputMaybe<Scalars['u128']['input']>;
  target_priceLT?: InputMaybe<Scalars['u128']['input']>;
  target_priceLTE?: InputMaybe<Scalars['u128']['input']>;
  target_priceNEQ?: InputMaybe<Scalars['u128']['input']>;
};

export type Revenant = {
  __typename?: 'Revenant';
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u128']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  name_revenant?: Maybe<Scalars['felt252']['output']>;
  outpost_count?: Maybe<Scalars['u32']['output']>;
  owner?: Maybe<Scalars['ContractAddress']['output']>;
  status?: Maybe<Scalars['u32']['output']>;
};

export type RevenantConnection = {
  __typename?: 'RevenantConnection';
  edges?: Maybe<Array<Maybe<RevenantEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type RevenantEdge = {
  __typename?: 'RevenantEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<Revenant>;
};

export type RevenantOrder = {
  direction: OrderDirection;
  field: RevenantOrderField;
};

export enum RevenantOrderField {
  EntityId = 'ENTITY_ID',
  GameId = 'GAME_ID',
  NameRevenant = 'NAME_REVENANT',
  OutpostCount = 'OUTPOST_COUNT',
  Owner = 'OWNER',
  Status = 'STATUS'
}

export type RevenantWhereInput = {
  entity_id?: InputMaybe<Scalars['u128']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u128']['input']>;
  entity_idGT?: InputMaybe<Scalars['u128']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idLT?: InputMaybe<Scalars['u128']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  name_revenant?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantEQ?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantGT?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantGTE?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantLT?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantLTE?: InputMaybe<Scalars['felt252']['input']>;
  name_revenantNEQ?: InputMaybe<Scalars['felt252']['input']>;
  outpost_count?: InputMaybe<Scalars['u32']['input']>;
  outpost_countEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countGTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLT?: InputMaybe<Scalars['u32']['input']>;
  outpost_countLTE?: InputMaybe<Scalars['u32']['input']>;
  outpost_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  owner?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  ownerNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  status?: InputMaybe<Scalars['u32']['input']>;
  statusEQ?: InputMaybe<Scalars['u32']['input']>;
  statusGT?: InputMaybe<Scalars['u32']['input']>;
  statusGTE?: InputMaybe<Scalars['u32']['input']>;
  statusLT?: InputMaybe<Scalars['u32']['input']>;
  statusLTE?: InputMaybe<Scalars['u32']['input']>;
  statusNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type Trade = {
  __typename?: 'Trade';
  buyer?: Maybe<Scalars['ContractAddress']['output']>;
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u32']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  price?: Maybe<Scalars['u128']['output']>;
  seller?: Maybe<Scalars['ContractAddress']['output']>;
  status?: Maybe<Scalars['u32']['output']>;
};

export type TradeConnection = {
  __typename?: 'TradeConnection';
  edges?: Maybe<Array<Maybe<TradeEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type TradeEdge = {
  __typename?: 'TradeEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<Trade>;
};

export type TradeOrder = {
  direction: OrderDirection;
  field: TradeOrderField;
};

export enum TradeOrderField {
  Buyer = 'BUYER',
  EntityId = 'ENTITY_ID',
  GameId = 'GAME_ID',
  Price = 'PRICE',
  Seller = 'SELLER',
  Status = 'STATUS'
}

export type TradeWhereInput = {
  buyer?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  buyerNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  entity_id?: InputMaybe<Scalars['u32']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u32']['input']>;
  entity_idGT?: InputMaybe<Scalars['u32']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u32']['input']>;
  entity_idLT?: InputMaybe<Scalars['u32']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u32']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  price?: InputMaybe<Scalars['u128']['input']>;
  priceEQ?: InputMaybe<Scalars['u128']['input']>;
  priceGT?: InputMaybe<Scalars['u128']['input']>;
  priceGTE?: InputMaybe<Scalars['u128']['input']>;
  priceLT?: InputMaybe<Scalars['u128']['input']>;
  priceLTE?: InputMaybe<Scalars['u128']['input']>;
  priceNEQ?: InputMaybe<Scalars['u128']['input']>;
  seller?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerGT?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerGTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerLT?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerLTE?: InputMaybe<Scalars['ContractAddress']['input']>;
  sellerNEQ?: InputMaybe<Scalars['ContractAddress']['input']>;
  status?: InputMaybe<Scalars['u32']['input']>;
  statusEQ?: InputMaybe<Scalars['u32']['input']>;
  statusGT?: InputMaybe<Scalars['u32']['input']>;
  statusGTE?: InputMaybe<Scalars['u32']['input']>;
  statusLT?: InputMaybe<Scalars['u32']['input']>;
  statusLTE?: InputMaybe<Scalars['u32']['input']>;
  statusNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type WorldEvent = {
  __typename?: 'WorldEvent';
  block_number?: Maybe<Scalars['u64']['output']>;
  destroy_count?: Maybe<Scalars['u32']['output']>;
  entity?: Maybe<World__Entity>;
  entity_id?: Maybe<Scalars['u128']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  radius?: Maybe<Scalars['u32']['output']>;
  x?: Maybe<Scalars['u32']['output']>;
  y?: Maybe<Scalars['u32']['output']>;
};

export type WorldEventConnection = {
  __typename?: 'WorldEventConnection';
  edges?: Maybe<Array<Maybe<WorldEventEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type WorldEventEdge = {
  __typename?: 'WorldEventEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<WorldEvent>;
};

export type WorldEventOrder = {
  direction: OrderDirection;
  field: WorldEventOrderField;
};

export enum WorldEventOrderField {
  BlockNumber = 'BLOCK_NUMBER',
  DestroyCount = 'DESTROY_COUNT',
  EntityId = 'ENTITY_ID',
  GameId = 'GAME_ID',
  Radius = 'RADIUS',
  X = 'X',
  Y = 'Y'
}

export type WorldEventTracker = {
  __typename?: 'WorldEventTracker';
  entity?: Maybe<World__Entity>;
  event_id?: Maybe<Scalars['u128']['output']>;
  game_id?: Maybe<Scalars['u32']['output']>;
  outpost_id?: Maybe<Scalars['u128']['output']>;
};

export type WorldEventTrackerConnection = {
  __typename?: 'WorldEventTrackerConnection';
  edges?: Maybe<Array<Maybe<WorldEventTrackerEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type WorldEventTrackerEdge = {
  __typename?: 'WorldEventTrackerEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<WorldEventTracker>;
};

export type WorldEventTrackerOrder = {
  direction: OrderDirection;
  field: WorldEventTrackerOrderField;
};

export enum WorldEventTrackerOrderField {
  EventId = 'EVENT_ID',
  GameId = 'GAME_ID',
  OutpostId = 'OUTPOST_ID'
}

export type WorldEventTrackerWhereInput = {
  event_id?: InputMaybe<Scalars['u128']['input']>;
  event_idEQ?: InputMaybe<Scalars['u128']['input']>;
  event_idGT?: InputMaybe<Scalars['u128']['input']>;
  event_idGTE?: InputMaybe<Scalars['u128']['input']>;
  event_idLT?: InputMaybe<Scalars['u128']['input']>;
  event_idLTE?: InputMaybe<Scalars['u128']['input']>;
  event_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  outpost_id?: InputMaybe<Scalars['u128']['input']>;
  outpost_idEQ?: InputMaybe<Scalars['u128']['input']>;
  outpost_idGT?: InputMaybe<Scalars['u128']['input']>;
  outpost_idGTE?: InputMaybe<Scalars['u128']['input']>;
  outpost_idLT?: InputMaybe<Scalars['u128']['input']>;
  outpost_idLTE?: InputMaybe<Scalars['u128']['input']>;
  outpost_idNEQ?: InputMaybe<Scalars['u128']['input']>;
};

export type WorldEventWhereInput = {
  block_number?: InputMaybe<Scalars['u64']['input']>;
  block_numberEQ?: InputMaybe<Scalars['u64']['input']>;
  block_numberGT?: InputMaybe<Scalars['u64']['input']>;
  block_numberGTE?: InputMaybe<Scalars['u64']['input']>;
  block_numberLT?: InputMaybe<Scalars['u64']['input']>;
  block_numberLTE?: InputMaybe<Scalars['u64']['input']>;
  block_numberNEQ?: InputMaybe<Scalars['u64']['input']>;
  destroy_count?: InputMaybe<Scalars['u32']['input']>;
  destroy_countEQ?: InputMaybe<Scalars['u32']['input']>;
  destroy_countGT?: InputMaybe<Scalars['u32']['input']>;
  destroy_countGTE?: InputMaybe<Scalars['u32']['input']>;
  destroy_countLT?: InputMaybe<Scalars['u32']['input']>;
  destroy_countLTE?: InputMaybe<Scalars['u32']['input']>;
  destroy_countNEQ?: InputMaybe<Scalars['u32']['input']>;
  entity_id?: InputMaybe<Scalars['u128']['input']>;
  entity_idEQ?: InputMaybe<Scalars['u128']['input']>;
  entity_idGT?: InputMaybe<Scalars['u128']['input']>;
  entity_idGTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idLT?: InputMaybe<Scalars['u128']['input']>;
  entity_idLTE?: InputMaybe<Scalars['u128']['input']>;
  entity_idNEQ?: InputMaybe<Scalars['u128']['input']>;
  game_id?: InputMaybe<Scalars['u32']['input']>;
  game_idEQ?: InputMaybe<Scalars['u32']['input']>;
  game_idGT?: InputMaybe<Scalars['u32']['input']>;
  game_idGTE?: InputMaybe<Scalars['u32']['input']>;
  game_idLT?: InputMaybe<Scalars['u32']['input']>;
  game_idLTE?: InputMaybe<Scalars['u32']['input']>;
  game_idNEQ?: InputMaybe<Scalars['u32']['input']>;
  radius?: InputMaybe<Scalars['u32']['input']>;
  radiusEQ?: InputMaybe<Scalars['u32']['input']>;
  radiusGT?: InputMaybe<Scalars['u32']['input']>;
  radiusGTE?: InputMaybe<Scalars['u32']['input']>;
  radiusLT?: InputMaybe<Scalars['u32']['input']>;
  radiusLTE?: InputMaybe<Scalars['u32']['input']>;
  radiusNEQ?: InputMaybe<Scalars['u32']['input']>;
  x?: InputMaybe<Scalars['u32']['input']>;
  xEQ?: InputMaybe<Scalars['u32']['input']>;
  xGT?: InputMaybe<Scalars['u32']['input']>;
  xGTE?: InputMaybe<Scalars['u32']['input']>;
  xLT?: InputMaybe<Scalars['u32']['input']>;
  xLTE?: InputMaybe<Scalars['u32']['input']>;
  xNEQ?: InputMaybe<Scalars['u32']['input']>;
  y?: InputMaybe<Scalars['u32']['input']>;
  yEQ?: InputMaybe<Scalars['u32']['input']>;
  yGT?: InputMaybe<Scalars['u32']['input']>;
  yGTE?: InputMaybe<Scalars['u32']['input']>;
  yLT?: InputMaybe<Scalars['u32']['input']>;
  yLTE?: InputMaybe<Scalars['u32']['input']>;
  yNEQ?: InputMaybe<Scalars['u32']['input']>;
};

export type World__Content = {
  __typename?: 'World__Content';
  cover_uri?: Maybe<Scalars['String']['output']>;
  description?: Maybe<Scalars['String']['output']>;
  icon_uri?: Maybe<Scalars['String']['output']>;
  name?: Maybe<Scalars['String']['output']>;
  socials?: Maybe<Array<Maybe<World__Social>>>;
  website?: Maybe<Scalars['String']['output']>;
};

export type World__Entity = {
  __typename?: 'World__Entity';
  created_at?: Maybe<Scalars['DateTime']['output']>;
  event_id?: Maybe<Scalars['String']['output']>;
  id?: Maybe<Scalars['ID']['output']>;
  keys?: Maybe<Array<Maybe<Scalars['String']['output']>>>;
  model_names?: Maybe<Scalars['String']['output']>;
  models?: Maybe<Array<Maybe<ModelUnion>>>;
  updated_at?: Maybe<Scalars['DateTime']['output']>;
};

export type World__EntityConnection = {
  __typename?: 'World__EntityConnection';
  edges?: Maybe<Array<Maybe<World__EntityEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type World__EntityEdge = {
  __typename?: 'World__EntityEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<World__Entity>;
};

export type World__Event = {
  __typename?: 'World__Event';
  created_at?: Maybe<Scalars['DateTime']['output']>;
  data?: Maybe<Array<Maybe<Scalars['String']['output']>>>;
  id?: Maybe<Scalars['ID']['output']>;
  keys?: Maybe<Array<Maybe<Scalars['String']['output']>>>;
  transaction_hash?: Maybe<Scalars['String']['output']>;
};

export type World__EventConnection = {
  __typename?: 'World__EventConnection';
  edges?: Maybe<Array<Maybe<World__EventEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type World__EventEdge = {
  __typename?: 'World__EventEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<World__Event>;
};

export type World__Metadata = {
  __typename?: 'World__Metadata';
  content?: Maybe<World__Content>;
  cover_img?: Maybe<Scalars['String']['output']>;
  created_at?: Maybe<Scalars['DateTime']['output']>;
  icon_img?: Maybe<Scalars['String']['output']>;
  id?: Maybe<Scalars['ID']['output']>;
  updated_at?: Maybe<Scalars['DateTime']['output']>;
  uri?: Maybe<Scalars['String']['output']>;
};

export type World__MetadataConnection = {
  __typename?: 'World__MetadataConnection';
  edges?: Maybe<Array<Maybe<World__MetadataEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type World__MetadataEdge = {
  __typename?: 'World__MetadataEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<World__Metadata>;
};

export type World__Model = {
  __typename?: 'World__Model';
  class_hash?: Maybe<Scalars['felt252']['output']>;
  created_at?: Maybe<Scalars['DateTime']['output']>;
  id?: Maybe<Scalars['ID']['output']>;
  name?: Maybe<Scalars['String']['output']>;
  transaction_hash?: Maybe<Scalars['felt252']['output']>;
};

export type World__ModelConnection = {
  __typename?: 'World__ModelConnection';
  edges?: Maybe<Array<Maybe<World__ModelEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type World__ModelEdge = {
  __typename?: 'World__ModelEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<World__Model>;
};

export type World__Query = {
  __typename?: 'World__Query';
  entities?: Maybe<World__EntityConnection>;
  entity: World__Entity;
  events?: Maybe<World__EventConnection>;
  gameModels?: Maybe<GameConnection>;
  gameentitycounterModels?: Maybe<GameEntityCounterConnection>;
  gametrackerModels?: Maybe<GameTrackerConnection>;
  metadatas?: Maybe<World__MetadataConnection>;
  model: World__Model;
  models?: Maybe<World__ModelConnection>;
  outpostModels?: Maybe<OutpostConnection>;
  outpostpositionModels?: Maybe<OutpostPositionConnection>;
  playerinfoModels?: Maybe<PlayerInfoConnection>;
  reinforcementbalanceModels?: Maybe<ReinforcementBalanceConnection>;
  revenantModels?: Maybe<RevenantConnection>;
  tradeModels?: Maybe<TradeConnection>;
  transaction: World__Transaction;
  transactions?: Maybe<World__TransactionConnection>;
  worldeventModels?: Maybe<WorldEventConnection>;
  worldeventtrackerModels?: Maybe<WorldEventTrackerConnection>;
};


export type World__QueryEntitiesArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  keys?: InputMaybe<Array<InputMaybe<Scalars['String']['input']>>>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type World__QueryEntityArgs = {
  id: Scalars['ID']['input'];
};


export type World__QueryEventsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  keys?: InputMaybe<Array<InputMaybe<Scalars['String']['input']>>>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type World__QueryGameModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<GameOrder>;
  where?: InputMaybe<GameWhereInput>;
};


export type World__QueryGameentitycounterModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<GameEntityCounterOrder>;
  where?: InputMaybe<GameEntityCounterWhereInput>;
};


export type World__QueryGametrackerModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<GameTrackerOrder>;
  where?: InputMaybe<GameTrackerWhereInput>;
};


export type World__QueryMetadatasArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type World__QueryModelArgs = {
  id: Scalars['ID']['input'];
};


export type World__QueryModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type World__QueryOutpostModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<OutpostOrder>;
  where?: InputMaybe<OutpostWhereInput>;
};


export type World__QueryOutpostpositionModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<OutpostPositionOrder>;
  where?: InputMaybe<OutpostPositionWhereInput>;
};


export type World__QueryPlayerinfoModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<PlayerInfoOrder>;
  where?: InputMaybe<PlayerInfoWhereInput>;
};


export type World__QueryReinforcementbalanceModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<ReinforcementBalanceOrder>;
  where?: InputMaybe<ReinforcementBalanceWhereInput>;
};


export type World__QueryRevenantModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<RevenantOrder>;
  where?: InputMaybe<RevenantWhereInput>;
};


export type World__QueryTradeModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<TradeOrder>;
  where?: InputMaybe<TradeWhereInput>;
};


export type World__QueryTransactionArgs = {
  id: Scalars['ID']['input'];
};


export type World__QueryTransactionsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type World__QueryWorldeventModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<WorldEventOrder>;
  where?: InputMaybe<WorldEventWhereInput>;
};


export type World__QueryWorldeventtrackerModelsArgs = {
  after?: InputMaybe<Scalars['Cursor']['input']>;
  before?: InputMaybe<Scalars['Cursor']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  order?: InputMaybe<WorldEventTrackerOrder>;
  where?: InputMaybe<WorldEventTrackerWhereInput>;
};

export type World__Social = {
  __typename?: 'World__Social';
  name?: Maybe<Scalars['String']['output']>;
  url?: Maybe<Scalars['String']['output']>;
};

export type World__Subscription = {
  __typename?: 'World__Subscription';
  entityUpdated: World__Entity;
  eventEmitted: World__Event;
  modelRegistered: World__Model;
};


export type World__SubscriptionEntityUpdatedArgs = {
  id?: InputMaybe<Scalars['ID']['input']>;
};


export type World__SubscriptionEventEmittedArgs = {
  keys?: InputMaybe<Array<InputMaybe<Scalars['String']['input']>>>;
};


export type World__SubscriptionModelRegisteredArgs = {
  id?: InputMaybe<Scalars['ID']['input']>;
};

export type World__Transaction = {
  __typename?: 'World__Transaction';
  calldata?: Maybe<Array<Maybe<Scalars['felt252']['output']>>>;
  created_at?: Maybe<Scalars['DateTime']['output']>;
  id?: Maybe<Scalars['ID']['output']>;
  max_fee?: Maybe<Scalars['felt252']['output']>;
  nonce?: Maybe<Scalars['felt252']['output']>;
  sender_address?: Maybe<Scalars['felt252']['output']>;
  signature?: Maybe<Array<Maybe<Scalars['felt252']['output']>>>;
  transaction_hash?: Maybe<Scalars['felt252']['output']>;
};

export type World__TransactionConnection = {
  __typename?: 'World__TransactionConnection';
  edges?: Maybe<Array<Maybe<World__TransactionEdge>>>;
  total_count: Scalars['Int']['output'];
};

export type World__TransactionEdge = {
  __typename?: 'World__TransactionEdge';
  cursor?: Maybe<Scalars['Cursor']['output']>;
  node?: Maybe<World__Transaction>;
};

export type GetGameTrackerNewQueryVariables = Exact<{
  entity_id: Scalars['u128']['input'];
}>;


export type GetGameTrackerNewQuery = { __typename?: 'World__Query', gametrackerModels?: { __typename?: 'GameTrackerConnection', edges?: Array<{ __typename?: 'GameTrackerEdge', node?: { __typename?: 'GameTracker', entity?: { __typename?: 'World__Entity', keys?: Array<string | null> | null, models?: Array<{ __typename: 'Game' } | { __typename: 'GameEntityCounter' } | { __typename: 'GameTracker', entity_id?: any | null, count?: any | null } | { __typename: 'Outpost' } | { __typename: 'OutpostPosition' } | { __typename: 'PlayerInfo' } | { __typename: 'ReinforcementBalance' } | { __typename: 'Revenant' } | { __typename: 'Trade' } | { __typename: 'WorldEvent' } | { __typename: 'WorldEventTracker' } | null> | null } | null } | null } | null> | null } | null };

export type GetReinforcementNewQueryVariables = Exact<{
  game_id: Scalars['u32']['input'];
  owner: Scalars['ContractAddress']['input'];
}>;


export type GetReinforcementNewQuery = { __typename?: 'World__Query', playerinfoModels?: { __typename?: 'PlayerInfoConnection', edges?: Array<{ __typename?: 'PlayerInfoEdge', node?: { __typename?: 'PlayerInfo', entity?: { __typename?: 'World__Entity', keys?: Array<string | null> | null, models?: Array<{ __typename: 'Game' } | { __typename: 'GameEntityCounter' } | { __typename: 'GameTracker' } | { __typename: 'Outpost' } | { __typename: 'OutpostPosition' } | { __typename: 'PlayerInfo', game_id?: any | null, owner?: any | null, revenant_count?: any | null, outpost_count?: any | null, reinforcement_count?: any | null, inited?: any | null } | { __typename: 'ReinforcementBalance' } | { __typename: 'Revenant' } | { __typename: 'Trade' } | { __typename: 'WorldEvent' } | { __typename: 'WorldEventTracker' } | null> | null } | null } | null } | null> | null } | null };

export type GetAllEventsQueryVariables = Exact<{
  game_id: Scalars['u32']['input'];
  eventsNumber: Scalars['Int']['input'];
}>;


export type GetAllEventsQuery = { __typename?: 'World__Query', worldeventModels?: { __typename?: 'WorldEventConnection', edges?: Array<{ __typename?: 'WorldEventEdge', node?: { __typename?: 'WorldEvent', entity?: { __typename?: 'World__Entity', keys?: Array<string | null> | null, models?: Array<{ __typename: 'Game' } | { __typename: 'GameEntityCounter' } | { __typename: 'GameTracker' } | { __typename: 'Outpost' } | { __typename: 'OutpostPosition' } | { __typename: 'PlayerInfo' } | { __typename: 'ReinforcementBalance' } | { __typename: 'Revenant' } | { __typename: 'Trade' } | { __typename: 'WorldEvent', game_id?: any | null, entity_id?: any | null, x?: any | null, y?: any | null, radius?: any | null, destroy_count?: any | null, block_number?: any | null } | { __typename: 'WorldEventTracker' } | null> | null } | null } | null } | null> | null } | null };

export type GetGameEntityCounterQueryVariables = Exact<{
  game_id: Scalars['u32']['input'];
}>;


export type GetGameEntityCounterQuery = { __typename?: 'World__Query', gameentitycounterModels?: { __typename?: 'GameEntityCounterConnection', edges?: Array<{ __typename?: 'GameEntityCounterEdge', node?: { __typename?: 'GameEntityCounter', entity?: { __typename?: 'World__Entity', keys?: Array<string | null> | null, models?: Array<{ __typename: 'Game' } | { __typename: 'GameEntityCounter', game_id?: any | null, revenant_count?: any | null, outpost_count?: any | null, event_count?: any | null, outpost_exists_count?: any | null, remain_life_count?: any | null, reinforcement_count?: any | null, trade_count?: any | null } | { __typename: 'GameTracker' } | { __typename: 'Outpost' } | { __typename: 'OutpostPosition' } | { __typename: 'PlayerInfo' } | { __typename: 'ReinforcementBalance' } | { __typename: 'Revenant' } | { __typename: 'Trade' } | { __typename: 'WorldEvent' } | { __typename: 'WorldEventTracker' } | null> | null } | null } | null } | null> | null } | null };

export type FetchEverythingNewQueryVariables = Exact<{
  game_id: Scalars['String']['input'];
}>;


export type FetchEverythingNewQuery = { __typename?: 'World__Query', entities?: { __typename?: 'World__EntityConnection', edges?: Array<{ __typename?: 'World__EntityEdge', node?: { __typename?: 'World__Entity', keys?: Array<string | null> | null, models?: Array<{ __typename: 'Game', game_id?: any | null, admin?: any | null, start_block_number?: any | null, prize?: any | null, preparation_phase_interval?: any | null, event_interval?: any | null, erc_addr?: any | null, status?: any | null } | { __typename: 'GameEntityCounter', game_id?: any | null, revenant_count?: any | null, outpost_count?: any | null, event_count?: any | null, outpost_exists_count?: any | null, remain_life_count?: any | null, reinforcement_count?: any | null, trade_count?: any | null } | { __typename: 'GameTracker' } | { __typename: 'Outpost', game_id?: any | null, entity_id?: any | null, owner?: any | null, name_outpost?: any | null, x?: any | null, y?: any | null, lifes?: any | null, status?: any | null, last_affect_event_id?: any | null } | { __typename: 'OutpostPosition' } | { __typename: 'PlayerInfo' } | { __typename: 'ReinforcementBalance' } | { __typename: 'Revenant', game_id?: any | null, entity_id?: any | null, owner?: any | null, name_revenant?: any | null, outpost_count?: any | null, status?: any | null } | { __typename: 'Trade' } | { __typename: 'WorldEvent', game_id?: any | null, entity_id?: any | null, x?: any | null, y?: any | null, radius?: any | null, destroy_count?: any | null, block_number?: any | null } | { __typename: 'WorldEventTracker' } | null> | null } | null } | null> | null } | null };


export const GetGameTrackerNewDocument = gql`
    query getGameTrackerNew($entity_id: u128!) {
  gametrackerModels(where: {entity_id: $entity_id}) {
    edges {
      node {
        entity {
          keys
          models {
            __typename
            ... on GameTracker {
              entity_id
              count
            }
          }
        }
      }
    }
  }
}
    `;
export const GetReinforcementNewDocument = gql`
    query getReinforcementNew($game_id: u32!, $owner: ContractAddress!) {
  playerinfoModels(where: {game_id: $game_id, owner: $owner}) {
    edges {
      node {
        entity {
          keys
          models {
            __typename
            ... on PlayerInfo {
              game_id
              owner
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
    `;
export const GetAllEventsDocument = gql`
    query getAllEvents($game_id: u32!, $eventsNumber: Int!) {
  worldeventModels(first: $eventsNumber, where: {game_id: $game_id}) {
    edges {
      node {
        entity {
          keys
          models {
            __typename
            ... on WorldEvent {
              game_id
              entity_id
              x
              y
              radius
              destroy_count
              block_number
            }
          }
        }
      }
    }
  }
}
    `;
export const GetGameEntityCounterDocument = gql`
    query getGameEntityCounter($game_id: u32!) {
  gameentitycounterModels(where: {game_id: $game_id}) {
    edges {
      node {
        entity {
          keys
          models {
            __typename
            ... on GameEntityCounter {
              game_id
              revenant_count
              outpost_count
              event_count
              outpost_exists_count
              remain_life_count
              reinforcement_count
              trade_count
            }
          }
        }
      }
    }
  }
}
    `;
export const FetchEverythingNewDocument = gql`
    query fetchEverythingNew($game_id: String!) {
  entities(keys: [$game_id]) {
    edges {
      node {
        keys
        models {
          __typename
          ... on WorldEvent {
            game_id
            entity_id
            x
            y
            radius
            destroy_count
            block_number
          }
          ... on Revenant {
            game_id
            entity_id
            owner
            name_revenant
            outpost_count
            status
          }
          ... on Outpost {
            game_id
            entity_id
            owner
            name_outpost
            x
            y
            lifes
            status
            last_affect_event_id
          }
          ... on Game {
            game_id
            admin
            start_block_number
            prize
            preparation_phase_interval
            event_interval
            erc_addr
            status
          }
          ... on GameEntityCounter {
            game_id
            revenant_count
            outpost_count
            event_count
            outpost_exists_count
            remain_life_count
            reinforcement_count
            trade_count
          }
        }
      }
    }
  }
}
    `;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string, operationType?: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName, _operationType) => action();
const GetGameTrackerNewDocumentString = print(GetGameTrackerNewDocument);
const GetReinforcementNewDocumentString = print(GetReinforcementNewDocument);
const GetAllEventsDocumentString = print(GetAllEventsDocument);
const GetGameEntityCounterDocumentString = print(GetGameEntityCounterDocument);
const FetchEverythingNewDocumentString = print(FetchEverythingNewDocument);
export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    getGameTrackerNew(variables: GetGameTrackerNewQueryVariables, requestHeaders?: GraphQLClientRequestHeaders): Promise<{ data: GetGameTrackerNewQuery; extensions?: any; headers: Dom.Headers; status: number; }> {
        return withWrapper((wrappedRequestHeaders) => client.rawRequest<GetGameTrackerNewQuery>(GetGameTrackerNewDocumentString, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getGameTrackerNew', 'query');
    },
    getReinforcementNew(variables: GetReinforcementNewQueryVariables, requestHeaders?: GraphQLClientRequestHeaders): Promise<{ data: GetReinforcementNewQuery; extensions?: any; headers: Dom.Headers; status: number; }> {
        return withWrapper((wrappedRequestHeaders) => client.rawRequest<GetReinforcementNewQuery>(GetReinforcementNewDocumentString, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getReinforcementNew', 'query');
    },
    getAllEvents(variables: GetAllEventsQueryVariables, requestHeaders?: GraphQLClientRequestHeaders): Promise<{ data: GetAllEventsQuery; extensions?: any; headers: Dom.Headers; status: number; }> {
        return withWrapper((wrappedRequestHeaders) => client.rawRequest<GetAllEventsQuery>(GetAllEventsDocumentString, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getAllEvents', 'query');
    },
    getGameEntityCounter(variables: GetGameEntityCounterQueryVariables, requestHeaders?: GraphQLClientRequestHeaders): Promise<{ data: GetGameEntityCounterQuery; extensions?: any; headers: Dom.Headers; status: number; }> {
        return withWrapper((wrappedRequestHeaders) => client.rawRequest<GetGameEntityCounterQuery>(GetGameEntityCounterDocumentString, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'getGameEntityCounter', 'query');
    },
    fetchEverythingNew(variables: FetchEverythingNewQueryVariables, requestHeaders?: GraphQLClientRequestHeaders): Promise<{ data: FetchEverythingNewQuery; extensions?: any; headers: Dom.Headers; status: number; }> {
        return withWrapper((wrappedRequestHeaders) => client.rawRequest<FetchEverythingNewQuery>(FetchEverythingNewDocumentString, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'fetchEverythingNew', 'query');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;