const OUTPOST_INIT_LIFE: u32 = 1;
// the max of outpost count for each revenant is 1. 
// const OUTPOST_MAX_COUNT: u32 = 1;
// Outposts, can be bolstered up to 20 times in their lifetime
const OUTPOST_MAX_REINFORCEMENT: u32 = 20;

const MAX_OUTPOSTS: u32 = 20;
const OUTPOST_PRICE: u256 = 10_000_000_000_000_000_000;

const REINFORCEMENT_TARGET_PRICE: u128 = 10_000_000_000;
const REINFORCEMENT_MAX_SELLABLE: u32 = 1_000_000_000;
const REINFORCEMENT_DECAY_CONSTANT: u128 = 571849066284996100; // 0.031

const REINFORCEMENT_INIT_COUNT: u32 = 0;
const REINFORCEMENT_LIFE_INCREASE: u32 = 1;

const EVENT_RADIUS_START: u32 = 155;
const EVENT_RADIUS_INCREASE: u32 = 15;

// The reward score offered for destory a outpost
const VERIFY_OUTPOST_SCORE: u32 = 5;

const MAP_WIDTH: u32 = 10240;
const MAP_HEIGHT: u32 = 5164;

// Game pot defaults 
const DEV_PERCENT: u8 = 10;
const CONFIRMATION_PERCENT: u8 = 10;
const LTR_PERCENT: u8 = 5;

const GAME_TRADE_TAX_PERCENT: u8 = 10;

