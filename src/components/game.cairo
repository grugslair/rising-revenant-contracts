use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};
use risingrevenant::utils::random::{Random, RandomTrait};
use dojo::model::{Model};

#[derive(Copy, Drop, Serde, Introspect)]
struct Dimensions {
    x: u32,
    y: u32
}

#[derive(Copy, Drop, Serde, Introspect)]
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

#[derive(Copy, Drop, Serde)]
struct PositionGenerator {
    random: Random,
    map_dims: Dimensions
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct GamePhases {
    #[key]
    game_id: u128,
    status: u8,
    preparation_block_number: u64,
    play_block_number: u64,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct GameMap {
    #[key]
    game_id: u128,
    dimensions: Dimensions,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct GameERC20 {
    #[key]
    game_id: u128,
    address: ContractAddress,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct GameTradeTax {
    #[key]
    game_id: u128,
    trade_tax_percent: u8,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct GamePotConsts {
    #[key]
    game_id: u128,
    pot_address: ContractAddress, // The contract that houses the prize pool can, by default, use the contract where the revenant_action is located.
    dev_percent: u8, // 10
    confirmation_percent: u8, // 10
    ltr_percent: u8, // 5
}

// Components to check ---------------------------------------------------------------------
#[dojo::model]
#[derive(Copy, Drop, Serde)]
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
#[dojo::model]
#[derive(Copy, Drop, Serde)]
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


#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum GamePhase {
    NotCreated,
    Created,
    Preparing,
    Playing,
    Ended,
}

#[generate_trait]
impl GamePhasesImpl of GamePhasesTrait {
    fn get_preparation_blocks<T, +TryInto<u64, T>>(self: GamePhases) -> T {
        (self.play_block_number - self.preparation_block_number).try_into().unwrap()
    }
}
