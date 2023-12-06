use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct PlayerInfo {
    #[key]
    game_id: u32,
    #[key]
    owner: ContractAddress,
    score: u32,
    revenant_count: u32,
    outpost_count: u32,
    reinforcement_count: u32,
    inited: bool,
}
