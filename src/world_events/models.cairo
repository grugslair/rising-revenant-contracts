use dojo::{world::WorldStorage, model::ModelStorage};
use starknet::ContractAddress;
use rising_revenant::{map::Point, fortifications::{Fortifications, FortificationsTrait}};

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

struct WorldEventFrequency {
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

/// Represents the currently active world event
#[dojo::model]
#[derive(Copy, Drop, Serde, Default)]
struct CurrentEvent {
    #[key]
    game_id: felt252, /// Unique identifier for the game session
    event_id: felt252, /// Unique identifier for the event
    event_type: WorldEventType, /// Type of the current event
    position: Point, /// Location where the event is centered
    radius_sq: u32, /// Current squared radius of effect
    time_stamp: u64, /// When the event was created
    did_hit: bool, /// Whether the event has impacted any targets
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

/// Trait implementation for accessing current event data
#[generate_trait]
impl CurrentEventImpl of CurrentEventTrait {
    /// Retrieves the current event for a given game
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn get_current_event(self: @WorldStorage, game_id: felt252) -> CurrentEvent {
        self.read_model(game_id)
    }
}

/// Trait implementation for accessing world event setup data
#[generate_trait]
impl WorldEventSetupImpl of WorldEventSetupTrait {
    /// Retrieves the world event setup configuration for a given game
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn get_world_event_setup(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> WorldEventSetup {
        self.read_model((game_id, event_type))
    }
}
