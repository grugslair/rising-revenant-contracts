use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{
    addresses::GetDispatcher, game::{GamePhasesTrait, GamePhase, models::{WinnerTrait}},
    outposts::token::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait}
};

/// Trait implementation for game-related functionality
/// Provides methods to check game phases and determine winners
#[generate_trait]
impl GameImpl of GameTrait {
    /// Returns the current phase of a specific game
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn get_game_phase(self: @WorldStorage, game_id: felt252) -> GamePhase {
        self.get_game_phases(game_id).get_phase()
    }

    /// Asserts that the game is in the preparing phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_preparing(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_preparing()
    }

    /// Asserts that the game is in the claiming phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_claiming(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_claiming()
    }

    /// Asserts that the game is in the playing phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_playing(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_playing()
    }

    /// Asserts that the preparation phase has ended
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_prep_ended(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_prep_ended()
    }

    /// Asserts that the game has ended
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_ended(self: @WorldStorage, game_id: felt252) {
        self.get_game_phases(game_id).assert_ended()
    }

    /// Returns the contract address of the winning player
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// The contract address of the player who owns the winning outpost
    fn get_winner(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        let dispatcher: IOutpostTokenDispatcher = self.get_dispatcher();
        dispatcher.owner_of(self.get_winning_outpost(game_id).into())
    }
}
