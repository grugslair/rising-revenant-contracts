use cubit::f128::types::fixed::{Fixed, FixedTrait};
use starknet::{ContractAddress, get_block_timestamp};

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementMarket {
    #[key]
    game_id: u128,
    target_price: u128,
    start_timestamp: u64,
    decay_constant: u128,
    max_sellable: u32,
    count: u32,
}

