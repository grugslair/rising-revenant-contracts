use starknet::ContractAddress;

// Trade for reinforcement
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct TradeReinforcement {
    #[key]
    game_id: u32,
    #[key]
    entity_id: u32,
    seller: ContractAddress,
    price: u128,
    count: u32,
    buyer: ContractAddress,
    status: u8,
}

mod TradeStatus {
    const not_created: u8 = 0;
    const selling: u8 = 1;
    const sold: u8 = 2;
    const revoked: u8 = 3;
}