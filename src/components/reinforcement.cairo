use cubit::f128::types::fixed::{Fixed, FixedTrait};
use starknet::{ContractAddress, get_block_timestamp};

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementBalance {
    #[key]
    game_id: u128,
    target_price: u128,
    start_timestamp: u64,
    count: u32,
}

