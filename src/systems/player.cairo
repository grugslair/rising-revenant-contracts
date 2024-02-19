use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

use risingrevenant::components::player::{PlayerInfo};

use risingrevenant::systems::game::{GameAction, GameActionTrait};


#[generate_trait]
impl PlayerActionsImpl of PlayerActionsTrait {
    fn get_player(self: @GameAction, player_id: ContractAddress) -> PlayerInfo {
        self.get((self.game_id, player_id))
    }
    fn get_caller_info(self: @GameAction) -> PlayerInfo {
        self.get_player(get_caller_address())
    }
}
