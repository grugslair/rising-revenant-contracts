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
    earned_prize: u128,
    revenant_count: u32,
    outpost_count: u32,
    reinforcements_available_count: u32,
    player_wallet_amount: u128
}

#[generate_trait]
impl PlayerInfoImpl of PlayerInfoTrait {
    fn check_player_exists(ref self: PlayerInfo, world: IWorldDispatcher) {
        assert(self.revenant_count != 0, 'The user does not exist');
    }
}