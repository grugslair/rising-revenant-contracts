use super::{GamePhasesTrait, GamePhase};

#[generate_trait]
impl GameImpl of GameTrait {
    fn get_game_phase(self: @IWorldDispatcher, game_id: felt252) -> GamePhase {
        self.get_game_phases(game_id).get_phase()
    }
    fn assert_claiming(self: @IWorldDispatcher, game_id: felt252) {
        self.get_game_phases(game_id).assert_claiming()
    }
}
