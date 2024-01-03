use starknet::ContractAddress;

// Trade for Revenant
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct TradeRevenant {
    #[key]
    game_id: u32,
    #[key]
    entity_id: u32,
    seller: ContractAddress,
    price: u256,
    revenant_id: u128,
    outpost_id: u128,
    buyer: ContractAddress,
    status: u32,
}

mod TradeStatus {
    const not_created: u32 = 0;
    const selling: u32 = 1;
    const sold: u32 = 2;
    const revoked: u32 = 3;
}
