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
    reinforcement_count: u32,
    initiated: u8,
    inited: bool,
}


// this trait checks if the player has ever bought a revenant, if he has then he can interact with the world
// alex
#[generate_trait]
impl PlayerInfoImpl of PlayerInfoTrait {
    fn check_player_exists(ref self: PlayerInfo, world: IWorldDispatcher) {
        assert(self.initiated != 0, 'The user does not exist');
    }
}



// HERE in the playe rinfo we need an impl that check if the user has ever bough anything this should be used with the initial bool should be false
// this is very similar to the creat coords for the outpost systems 