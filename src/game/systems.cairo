use super::models::GamePhasePreppingTrait;
use starknet::{ContractAddress, get_block_timestamp};
use dojo::{world::WorldStorage, model::ModelStorage};
use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
use rising_revenant::{
    game::{GamePhase, GameStorage}, outposts::OutpostStorage, tokens::erc721_owner_of,
};

/// Trait implementation for game-related functionality
/// Provides methods to check game phases and determine winners
#[generate_trait]
impl GameImpl of GameTrait {
    /// Asserts that the game is in the preparing phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_preparing(self: @WorldStorage, game_id: felt252) {
        self.get_game_phase_prepping(game_id).assert_preparing(get_block_timestamp());
    }

    fn assert_game_playing(self: @WorldStorage, game_id: felt252) {
        let schema = self.get_game_phase_playing(game_id);
        assert(schema.events_start > get_block_timestamp(), 'Game play phase not started');
        assert(schema.ended.is_zero(), 'Game has ended');
    }

    /// Asserts that the game is in the claiming phase
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn assert_game_claiming(self: @WorldStorage, game_id: felt252) {
        let schema = self.get_game_phase_claiming(game_id);
        assert(schema.ended.is_non_zero(), 'Game has not ended');
        assert(
            get_block_timestamp() <= schema.ended + schema.claim_period, 'Claim period has ended',
        );
    }

    fn assert_game_claim_ended(self: @WorldStorage, game_id: felt252) {
        let schema = self.get_game_phase_claiming(game_id);
        assert(schema.ended.is_non_zero(), 'Game has not ended');
        assert(
            get_block_timestamp() > schema.ended + schema.claim_period,
            'Claim period has not ended',
        );
    }

    fn assert_prep_ended(self: @WorldStorage, game_id: felt252) {
        assert(
            self.get_game_phase_prep_ended(game_id) > get_block_timestamp(),
            'Preparation not ended',
        );
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
