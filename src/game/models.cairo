use dojo::world::IWorldDispatcher;
use starknet::get_block_timestamp;


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

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct Winner {
    #[key]
    game_id: felt252,
    outpost_id: felt252,
}

#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct GamePhases {
    #[key]
    game_id: felt252,
    prep_start: u64,
    prep_stop: u64,
    events_start: u64,
    claim_period: u64,
    ended: u64,
}

#[generate_trait]
impl WinnerImpl of WinnerTrait {
    fn set_winning_outpost(self: IWorldDispatcher, game_id: felt252, outpost_id: felt252) {
        Winner { game_id, outpost_id }.set(self)
    }
    fn get_winning_outpost(self: @IWorldDispatcher, game_id: felt252) -> felt252 {
        WinnerStore::get_outpost_id(*self, game_id)
    }
}

#[generate_trait]
impl GamePhasesImpl of GamePhasesTrait {
    fn get_game_phases(self: @IWorldDispatcher, game_id: felt252) -> GamePhases {
        GamePhasesStore::get(*self, game_id)
    }
    fn get_prep_start(self: @IWorldDispatcher, game_id: felt252) -> u64{
        GamePhasesStore::get_prep_start(*self, game_id)
    }
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
    fn get_claim_end(self: @GamePhases) -> u64 {
        *self.ended + *self.claim_period
    }
    fn is_phase(self: @GamePhases, phase: GamePhase) -> bool {
        self.get_phase() == phase
    }
    fn assert_preparing(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Preparing), 'Not in preparing phase');
    }
    fn assert_playing(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Playing), 'Not in play phase');
    }
    fn assert_claiming(self: @GamePhases) {
        assert(self.is_phase(GamePhase::Claim), 'Not in claim phase');
    }
    fn assert_prep_ended(self: @GamePhases) {
        assert(
            (*self.prep_start).is_non_zero() && *self.prep_stop >= get_block_timestamp(),
            'Preparation not started'
        );
    }
    fn assert_ended(self: @GamePhases) {
        assert(*self.ended > 0 && get_block_timestamp() > self.get_claim_end(), 'Game not ended');
    }
}

