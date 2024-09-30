use rising_revenant::{models::Point};
use starknet::get_block_number;

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct Map {
    #[key]
    game_id: felt252,
    #[key]
    position: Point,
    outpost: felt252,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum GamePhase {
    NotCreated,
    Created,
    Preparing,
    Playing,
    Ended,
}


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct GameSetup {
    #[key]
    game_id: felt252,
    map_size: Point,
    prep_start: u64,
    events_start: u64,
    ended: bool,
}

#[generate_trait]
impl GameSetupImpl of GameSetupTrait {
    fn get_phase(self: @GameSetup) -> GamePhase {
        let block_number = get_block_number();
        if (*self.prep_start).is_non_zero() {
            if block_number < *self.prep_start {
                return GamePhase::Created;
            }
            if block_number < *self.events_start {
                return GamePhase::Preparing;
            }
            return GamePhase::Playing;
        };
        if *self.ended {
            return GamePhase::Ended;
        }
        return GamePhase::NotCreated;
    }
    fn is_phase(self: @GameSetup, phase: GamePhase) -> bool {
        self.get_phase() == phase
    }
    fn assert_preparing(self: @GameSetup) {
        assert(self.is_phase(GamePhase::Preparing), 'Not in preparing phase');
    }
    fn assert_playing(self: @GameSetup) {
        assert(self.is_phase(GamePhase::Playing), 'Not in play phase');
    }
}
