use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PlayerInfo {
    #[key]
    game_id: u128,
    #[key]
    player_id: ContractAddress,
    outpost_count: u32,
    reinforcements_available_count: u32,
    init: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PlayerContribution {
    #[key]
    game_id: u128,
    #[key]
    player_id: ContractAddress,
    score: u256,
    claimed: bool,
}

