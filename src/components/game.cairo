use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};
use risingrevenant::utils::random::{Random, RandomTrait};
use dojo::database::introspect::Introspect;
use dojo::model::{Model};


#[derive(Copy, Drop, Print, Serde, SerdeLen, Introspect)]
struct Dimensions {
    x: u32,
    y: u32
}

#[derive(Copy, Drop, Print, Serde, SerdeLen, Introspect)]
struct Position {
    x: u32,
    y: u32,
}

#[generate_trait]
impl PositionImpl of PositionTrait {
    fn new_random(mut random: Random, map_dims: Dimensions) -> Position {
        Position { x: random.next_capped(map_dims.x), y: random.next_capped(map_dims.y) }
    }
}

#[derive(Copy, Drop, Serde, SerdeLen)]
struct PositionGenerator {
    random: Random,
    map_dims: Dimensions
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct CurrentGame {
    #[key]
    owner: ContractAddress,
    game_id: u128,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GamePhases {
    #[key]
    game_id: u128,
    status: u8,
    preparation_block_number: u64,
    play_block_number: u64,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameMap {
    #[key]
    game_id: u128,
    dimensions: Dimensions,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameERC20 {
    #[key]
    game_id: u128,
    address: ContractAddress, // The ERC20 token address for increasing reinforcement
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameTradeTax {
    #[key]
    game_id: u128,
    trade_tax_percent: u8,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GamePotConsts {
    #[key]
    game_id: u128,
    pot_address: ContractAddress, // The contract that houses the prize pool can, by default, use the contract where the revenant_action is located.
    dev_percent: u8, // 10
    confirmation_percent: u8, // 10
    ltr_percent: u8, // 5
}

// Components to check ---------------------------------------------------------------------
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameState {
    #[key]
    game_id: u128,
    outpost_created_count: u32,
    outpost_remaining_count: u32,
    remain_life_count: u32,
    reinforcement_count: u32,
    contribution_score_total: u256,
}

// Game pot
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GamePot {
    #[key]
    game_id: u128,
    total_pot: u256,
    winners_pot: u256,
    confirmation_pot: u256,
    ltr_pot: u256,
    dev_pot: u256,
    claimed: bool,
}


#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct DevWallet {
    #[key]
    game_id: u128,
    #[key]
    owner: ContractAddress,
    balance: u256,
    init: bool,
}

mod GameStatus {
    const not_created: u8 = 0;
    const created: u8 = 1;
    const ended: u8 = 2;
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Print)]
enum GamePhase {
    NotCreated,
    Created,
    Preparing,
    Playing,
    Ended,
}

