use starknet::ContractAddress;

use risingrevenant::components::game::Position;
use risingrevenant::components::reinforcement::{ReinforcementType};

use risingrevenant::utils::{calculate_distance};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct WorldEventSetup {
    #[key]
    game_id: u128,
    radius_start: u32,
    radius_increase: u32,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct WorldEvent {
    #[key]
    game_id: u128,
    #[key]
    event_id: u128,
    position: Position,
    event_type: EventType,
    radius: u32,
    verifications: u32,
    number: u32,
    block_number: u64,
    previous_event: u128,
    next_event: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct CurrentWorldEvent {
    #[key]
    game_id: u128,
    event_id: u128,
    position: Position,
    event_type: EventType,
    radius: u32,
    number: u32,
    block_number: u64,
    previous_event: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct OutpostVerified {
    #[key]
    game_id: u128,
    #[key]
    event_id: u128,
    #[key]
    outpost_id: Position,
    verified: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct WorldEventVerifications {
    #[key]
    game_id: u128,
    verifications: u32,
}


#[generate_trait]
impl CurrentWorldEventImpl of CurrentWorldEventTrait {
    fn to_event(self: @CurrentWorldEvent, next_event: u128, verifications: u32) -> WorldEvent {
        WorldEvent {
            game_id: *self.game_id,
            event_id: *self.event_id,
            position: *self.position,
            event_type: *self.event_type,
            radius: *self.radius,
            verifications,
            number: *self.number,
            block_number: *self.block_number,
            previous_event: *self.previous_event,
            next_event,
        }
    }
    fn is_impacted(self: @CurrentWorldEvent, outpost_position: Position) -> bool {
        let distance = calculate_distance(*self.position, outpost_position);
        distance <= *self.radius
    }
}
// This enum simply defines the states of a game.
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum EventType {
    None,
    Dragon,
    Goblin,
    Earthquake,
}

// We define an into trait
impl EventTypeFelt252 of Into<EventType, felt252> {
    fn into(self: EventType) -> felt252 {
        match self {
            EventType::None => 0,
            EventType::Dragon => 1,
            EventType::Goblin => 2,
            EventType::Earthquake => 3,
        }
    }
}

impl u8IntoEventType of TryInto<u8, EventType> {
    fn try_into(self: u8) -> Option<EventType> {
        if self == 0 {
            return Option::Some(EventType::None);
        } else if self == 1 {
            return Option::Some(EventType::Dragon);
        } else if self == 2 {
            return Option::Some(EventType::Goblin);
        } else if self == 3 {
            return Option::Some(EventType::Earthquake);
        } else {
            return Option::None;
        }
    }
}


#[generate_trait]
impl EventDefenseImpl of EventDefenseTrait {
    fn get_defense_probability(
        self: EventType, reinforcement_type: ReinforcementType
    ) -> (u8, u32) {
        return if reinforcement_type == ReinforcementType::None {
            (51, 1)
        } else {
            match self {
                EventType::None => (255, 0),
                EventType::Dragon => if reinforcement_type == ReinforcementType::Wall {
                    (179, 1)
                } else {
                    (0, 1)
                },
                EventType::Goblin => if reinforcement_type == ReinforcementType::Trench {
                    (179, 1)
                } else {
                    (0, 1)
                },
                EventType::Earthquake => if reinforcement_type == ReinforcementType::Bunker {
                    (179, 1)
                } else {
                    (0, 1)
                },
            }
        };
    }
}

