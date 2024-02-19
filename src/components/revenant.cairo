use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Revenant {
    #[key]
    game_id: u32,
    #[key]
    outpost_id: u128,
    first_name_idx: u32,
    last_name_idx: u32,
}
