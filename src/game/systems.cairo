use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use rising_revenant::{
    addresses::GetDispatcher, game::{GamePhasesTrait, GamePhase, models::{WinnerTrait}},
    outposts::token::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait}
};

#[generate_trait]
impl GameImpl of GameTrait {
    fn get_game_phase(self: @IWorldDispatcher, game_id: felt252) -> GamePhase {
        self.get_game_phases(game_id).get_phase()
    }
    fn assert_claiming(self: @IWorldDispatcher, game_id: felt252) {
        self.get_game_phases(game_id).assert_claiming()
    }
    fn assert_prep_ended(self: @IWorldDispatcher, game_id: felt252) {
        self.get_game_phases(game_id).assert_prep_ended()
    }
    fn assert_ended(self: @IWorldDispatcher, game_id: felt252) {
        self.get_game_phases(game_id).assert_ended()
    }
    fn get_winner(self: @IWorldDispatcher, game_id: felt252) -> ContractAddress {
        let dispatcher: IOutpostTokenDispatcher = self.get_dispatcher();
        dispatcher.owner_of(self.get_winning_outpost(game_id).into())
    }
}
