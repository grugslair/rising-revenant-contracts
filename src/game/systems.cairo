use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{
    addresses::GetDispatcher, game::{GamePhasesTrait, GamePhase, models::{WinnerTrait}},
    outposts::token::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait}
};

#[generate_trait]
impl GameImpl of GameTrait {
    fn get_game_phase(self: @WorldStorage, game_id: felt252) -> GamePhase {
        self.get_game_phases(game_id).get_phase()
    }
    fn assert_preparing(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_preparing()
    }
    fn assert_claiming(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_claiming()
    }
    fn assert_playing(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_playing()
    }
    fn assert_prep_ended(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_prep_ended()
    }
    fn assert_ended(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_ended()
    }
    fn get_winner(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        let dispatcher: IOutpostTokenDispatcher = self.get_dispatcher();
        dispatcher.owner_of(self.get_winning_outpost(game_id).into())
    }
}
