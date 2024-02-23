use starknet::{ContractAddress, get_caller_address};

use risingrevenant::components::player::{PlayerInfo, PlayerContribution};

use risingrevenant::systems::game::{GameAction, GameActionTrait};


#[generate_trait]
impl PlayerActionsImpl of PlayerActionsTrait {
    fn get_player(self: GameAction, player_id: ContractAddress) -> PlayerInfo {
        self.get(player_id)
    }
    fn get_caller_info(self: GameAction) -> PlayerInfo {
        self.get_player(get_caller_address())
    }
    fn get_caller_contribution(self: GameAction) -> PlayerContribution {
        self.get(get_caller_address())
    }
}
