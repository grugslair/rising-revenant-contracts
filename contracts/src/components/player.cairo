use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct PlayerInfo {
    #[key]
    game_id: u32,
    #[key]
    owner: ContractAddress,
    score: u32,
    score_claim_status: bool,
    earned_prize: u256,
    revenant_count: u32,
    outpost_count: u32,
    reinforcement_count: u32,
    initiated: u8,
    inited: bool,
}

#[generate_trait]
impl PlayerInfoImpl of PlayerInfoTrait {
    fn check_player_exists(ref self: PlayerInfo, world: IWorldDispatcher) {
        assert(self.initiated != 0, 'The user does not exist');
    }
}