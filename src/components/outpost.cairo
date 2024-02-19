use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::revenant::{Revenant,};
use risingrevenant::components::player::{PlayerInfo,};
use risingrevenant::constants::{
    MAP_HEIGHT, MAP_WIDTH, OUTPOST_INIT_LIFE, REINFORCEMENT_INIT_COUNT, SPAWN_RANGE_X_MAX,
    SPAWN_RANGE_Y_MAX, SPAWN_RANGE_X_MIN, SPAWN_RANGE_Y_MIN, PLAYER_STARTING_AMOUNT,
    OUTPOST_MAX_REINFORCEMENT
};
use risingrevenant::utils::random::{Random, RandomImpl};


#[derive(Copy, Drop, Serde, SerdeLen)]
struct Position {
    x: u32,
    y: u32,
}

#[generate_trait]
impl PositionImpl of PositionTrait {
    fn new_random(ref random: Random) -> Position {
        Position {
            x: random.next_u32(SPAWN_RANGE_X_MIN, SPAWN_RANGE_X_MAX),
            y: random.next_u32(SPAWN_RANGE_Y_MIN, SPAWN_RANGE_Y_MAX),
        }
    }
}

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Outpost {
    #[key]
    game_id: u32,
    #[key]
    position: Position,
    owner: ContractAddress,
    name: felt252,
    lifes: u32,
    shield: u8,
    reinforcements: u32,
    status: u32,
    last_affect_event_id: u128
}


mod OutpostStatus {
    const not_created: u32 = 0;
    const created: u32 = 1;
}


#[generate_trait]
impl OutpostImpl of OutpostTrait {
    fn new_random(game_id: u32, owner: ContractAddress, ref random: Random) -> Outpost {
        Outpost {
            game_id,
            position: PositionTrait::new_random(ref random),
            owner,
            name: 'Outpost',
            lifes: OUTPOST_INIT_LIFE,
            shield: 0,
            reinforcements: 0,
            status: OutpostStatus::created,
            last_affect_event_id: 0,
        }
    }
    fn assert_existed(self: Outpost) {
        assert(self.status != OutpostStatus::not_created, 'Outpost not exist');
        assert(self.lifes > 0, 'Outpost has been destroyed');
    }

    fn get_max_reinforcement(self: @Outpost) -> u32 {
        assert(*self.reinforcements < OUTPOST_MAX_REINFORCEMENT, 'Max reinforcements reached');
        OUTPOST_MAX_REINFORCEMENT - *self.reinforcements
    }


    fn get_shields_amount(self: Outpost) -> u8 {
        let reinforcements = self.lifes;

        if (reinforcements < 3) {
            return 0;
        } else if (reinforcements < 6) {
            return 1;
        } else if (reinforcements < 10) {
            return 2;
        } else if (reinforcements < 14) {
            return 3;
        } else if (reinforcements < 20) {
            return 4;
        } else if (reinforcements == 20) {
            return 5;
        } else {
            return 7;
        }
    }
}
