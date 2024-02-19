use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct PlayerInfo {
    #[key]
    game_id: u32,
    #[key]
    player_id: ContractAddress,
    score: u32,
    score_claim_status: bool,
    earned_prize: u128,
    outpost_count: u32,
    reinforcements_available_count: u32,
    init: bool,
}

