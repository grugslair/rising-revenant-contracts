use dojo::{world::WorldStorage, model::{Model, ModelStorage}};
use starknet::get_block_timestamp;

/// Represents the different phases a game can be in.
/// 
/// * `NotCreated` - Game hasn't been created yet
/// * `Created` - Game is created but preparation hasn't started
/// * `Preparing` - Players can prepare their outposts
/// * `Hold` - Preparation is complete, waiting for game to start
/// * `Playing` - Game is actively being played
/// * `Claim` - Winners can claim their rewards
/// * `Ended` - Game is completely finished
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum GamePhase {
    NotCreated,
    Created,
    Preparing,
    Hold,
    Playing,
    Claim,
    Ended,
}

/// Stores the winning outpost information for a completed game
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct Winner {
    #[key]
    game_id: felt252,
    outpost_id: felt252,
}

/// Stores the timing information for different phases of the game
#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct GamePhases {
    /// Unique identifier for the game
    #[key]
    game_id: felt252,
    /// Timestamp when preparation phase starts
    prep_start: u64,
    /// Timestamp when preparation phase ends
    prep_stop: u64,
    /// Timestamp when the game events start
    events_start: u64,
    /// Duration of the claim period after game ends
    claim_period: u64,
    /// Timestamp when the game ended
    ended: u64,
}

/// Implementation of Winner-related functionality
#[generate_trait]
impl WinnerImpl of WinnerTrait {
    /// Sets the winning outpost for a specific game
    /// * `game_id` - The ID of the game
    /// * `outpost_id` - The ID of the winning outpost
    fn set_winning_outpost(ref self: WorldStorage, game_id: felt252, outpost_id: felt252) {
        self.write_model(@Winner { game_id, outpost_id });
    }

    /// Retrieves the winning outpost ID for a specific game
    /// * `game_id` - The ID of the game
    /// * Returns the outpost ID of the winner
    fn get_winning_outpost(self: @WorldStorage, game_id: felt252) -> felt252 {
        self.read_member(Model::<Winner>::ptr_from_keys(game_id), selector!("outpost_id"))
    }
}

/// Implementation of game phase related functionality
#[generate_trait]
impl GamePhasesImpl of GamePhasesTrait {
    /// Retrieves the complete GamePhases struct for a specific game
    /// * `game_id` - The ID of the game
    fn get_game_phases(self: @WorldStorage, game_id: felt252) -> GamePhases {
        self.read_model(game_id)
    }

    /// Gets the preparation start timestamp for a specific game
    /// * `game_id` - The ID of the game
    fn get_prep_start(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<GamePhases>::ptr_from_keys(game_id), selector!("prep_start"))
    }
    
    /// Determines the current phase of the game based on timestamps
    /// Returns the current GamePhase enum value
    fn get_phase(self: @GamePhases) -> GamePhase {
        let timestamp = get_block_timestamp();
        if (*self.prep_start).is_non_zero() {
            if timestamp < *self.prep_start {
                GamePhase::Created
            } else if timestamp < *self.prep_stop {
                GamePhase::Preparing
            } else if timestamp < *self.events_start {
                GamePhase::Hold
            } else {
                GamePhase::Playing
            }
        } else if *self.ended > 0 {
            if self.get_claim_end() >= timestamp {
                GamePhase::Claim
            } else {
                GamePhase::Ended
            }
        } else {
            GamePhase::NotCreated
        }
    }
    // Get when the claim period ends
    fn get_claim_end(self: @GamePhases) -> u64 {
        *self.ended + *self.claim_period
    }
    /// Checks if the current game phase matches the specified phase.
    ///
    /// # Arguments
    ///
    /// * `self` - A reference to the `GamePhases` instance.
    /// * `phase` - The `GamePhase` to compare against the current phase.
    ///
    /// # Returns
    ///
    /// * `bool` - `true` if the current phase matches the specified phase, `false` otherwise.
    fn is_phase(self: @GamePhases, phase: GamePhase) -> bool {
        self.get_phase() == phase
    }
    /// Asserts that the current game phase is 'Preparing'.
    /// If the game is not in the 'Preparing' phase, it will raise an error with the message 'Not in
    /// preparing phase'.
    fn assert_preparing(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Preparing), 'Not in preparing phase');
    }
    /// Asserts that the current game phase is 'Playing'.
    /// If the game is not in the 'Playing' phase, it will raise an error with the message 'Not in
    /// play phase'.
    fn assert_playing(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Playing), 'Not in play phase');
    }
    /// Asserts that the current game phase is 'Claim'.
    /// If the game is not in the 'Claim' phase, it will raise an error with the message 'Not in
    /// claim phase'.
    fn assert_claiming(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Claim), 'Not in claim phase');
    }
    /// Asserts that the preparation phase has started and has not yet ended.
    /// If the preparation phase has not started or has already ended, it will raise an error with
    /// the message 'Preparation not started'.
    fn assert_prep_ended(self: @GamePhases) {
        assert(
            (*self.prep_start).is_non_zero() && *self.prep_stop >= get_block_timestamp(),
            'Preparation not started'
        );
    }
    /// Asserts that the game has ended.
    /// If the game has not ended, it will raise an error with the message 'Game not ended'.
    fn assert_ended(self: @GamePhases) {
        assert(*self.ended > 0 && get_block_timestamp() > self.get_claim_end(), 'Game not ended');
    }
}

