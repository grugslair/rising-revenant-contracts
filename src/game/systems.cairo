use starknet::{ContractAddress, get_block_timestamp};
use dojo::{world::WorldStorage, model::ModelStorage};
use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
use rising_revenant::{
    game::{GamePhasesTrait, GamePhase, GameStorage}, outposts::OutpostStorage,
    tokens::erc721_owner_of,
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
    fn assert_game_claiming(self: @WorldStorage, game_id: felt252) {
        let ended = self.get_game_ended(game_id);
        assert(ended.is_non_zero(), 'Game has not ended');
        assert(
            get_block_timestamp() <= ended + self.get_game_claim_period(game_id),
            'Claim period has ended',
        );
    }

    fn assert_game_claim_ended(self: @WorldStorage, game_id: felt252) {
        let ended = self.get_game_ended(game_id);
        assert(ended.is_non_zero(), 'Game has not ended');
        assert(
            get_block_timestamp() > ended + self.get_game_claim_period(game_id),
            'Claim period has ended',
        );
    }

    /// Asserts that the game is in the playing phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_game_playing(self: @WorldStorage, game_id: felt252) {
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

    fn assert_game_not_ended(self: @WorldStorage, game_id: felt252) {
        assert(self.get_game_ended(game_id).is_zero(), 'Game has ended');
    }

    /// Returns the contract address of the winning player
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// The contract address of the player who owns the winning outpost
    fn get_owner_of_winning_outpost(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        erc721_owner_of(
            self.get_outpost_token_address(game_id), self.get_winning_outpost(game_id).into(),
        )
    }
}
