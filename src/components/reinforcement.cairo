use cubit::f128::types::fixed::{Fixed, FixedTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};
use starknet::{ContractAddress, get_block_timestamp};

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct ReinforcementBalance {
    #[key]
    game_id: u32,
    target_price: u128,
    start_timestamp: u64,
    count: u32,
}

