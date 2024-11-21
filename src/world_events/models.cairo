use dojo::{world::WorldStorage, model::ModelStorage};
use starknet::ContractAddress;
use rising_revenant::{
    map::{Point, Map, PointTrait}, fortifications::{Fortifications, FortificationsTrait},
    core::in_range
};

/// Number of different world event types available in the game
const NUM_WORLD_EVENTS: u8 = 3;

/// Represents different types of world events that can occur in the game
#[derive(Copy, Drop, Serde, PartialEq, Introspect, Default)]
enum WorldEventType {
    #[default]
    Dragon, /// A dragon attack event
    Goblins, /// A goblin raid event
    EarthQuake, /// A natural disaster event
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct WorldEventMinInterval {
    #[key]
    game_id: felt252,
    min_interval: u64, /// Minimum time between events
}

/// Configuration parameters for world events in a game session
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct WorldEventSetup {
    #[key]
    game_id: felt252, /// Unique identifier for the game session
    #[key]
    event_type: WorldEventType, /// Type of the event
    min_radius_sq: u32, /// Minimum squared radius of event effect (starting radius)
    max_radius_sq: u32, /// Maximum squared radius of event effect
    radius_sq_increase: u32, /// Rate at which the radius increases
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct WorldEventEffect {
    #[key]
    game_id: felt252, /// Unique identifier for the game session
    #[key]
    event_type: WorldEventType, /// Type of the event
    efficacy: Fortifications,
    mortalities: Fortifications,
    power: u64, /// Base power/impact of the event
    f_value: u64, /// 
}

#[dojo::event]
#[derive(Copy, Drop, Serde, Default)]
struct WorldEventEvent {
    #[key]
    event_id: felt252, /// Unique identifier for the event
    game_id: felt252, /// Unique identifier for the game session
    event_type: WorldEventType, /// Type of the current event
    position: Point, /// Location where the event is centered
    time_stamp: u64, /// When the event was created
}


/// Represents the currently active world event
#[dojo::model]
#[derive(Copy, Drop, Serde, Default)]
struct CurrentEvent {
    #[key]
    game_id: felt252, /// Unique identifier for the game session
    event_id: felt252, /// Unique identifier for the event
    event_type: WorldEventType, /// Type of the current event
    position: Point, /// Location where the event is centered
    timestamp: u64, /// When the event was created
}

#[dojo::model]
#[derive(Copy, Drop, Serde, Default)]
struct LastEventOfType {
    #[key]
    game_id: felt252,
    #[key]
    event_type: WorldEventType,
    radius_sq: u32,
    did_hit: bool,
}


/// Complete information about a world event
#[derive(Copy, Drop, Serde, Default)]
struct WorldEvent {
    event_id: felt252, /// Unique identifier for the event
    event_type: WorldEventType, /// Type of event
    efficacy: Fortifications,
    mortalities: Fortifications,
    position: Point, /// Location where the event is centered
    radius_sq: u32, /// Squared radius of effect
    power: u64, /// Current power/impact of the event
    f_value: u64, /// Rate at which the event's effect diminishes
}

#[generate_trait]
impl WorldEventEffectImpl of WorldEventEffectTrait {
    fn get_damage(self: @WorldEvent, fortifications: Fortifications) -> u64 {
        let total: u128 = (fortifications * *self.efficacy).sum().into();
        (total * (*self.power).into() / (total + (*self.f_value).into())).try_into().unwrap()
    }

    /// Checks if a given location is within the event's area of effect
    /// # Arguments
    /// * `location` - The point to check
    /// # Returns
    /// * `bool` - True if the location is within the event's radius, false otherwise
    fn in_range(self: @WorldEvent, location: Point) -> bool {
        self.position.in_range(location, *self.radius_sq)
    }
}

/// Implements conversion from u8 to WorldEventType
impl U8IntoWorldEvent<T, +TryInto<T, u8>> of Into<T, WorldEventType> {
    #[inline(always)]
    fn into(self: T) -> WorldEventType {
        match self.try_into().unwrap() {
            0_u8 => WorldEventType::Dragon,
            1_u8 => WorldEventType::Goblins,
            2_u8 => WorldEventType::EarthQuake,
            _ => panic!("Index out of bounds"),
        }
    }
}

#[generate_trait]
impl WorldEventSetupImpl of WorldEventSetupTrait {
    fn get_radius_sq(self: @WorldEventSetupValue, last_event: LastEventOfTypeValue) -> u32 {
        in_range(
            *self.min_radius_sq,
            *self.max_radius_sq,
            if last_event.did_hit {
                last_event.radius_sq + *self.radius_sq_increase
            } else {
                last_event.radius_sq
            }
        )
    }
}

