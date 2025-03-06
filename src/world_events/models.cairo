use dojo::{
    world::WorldStorage, model::{ModelStorage, Model, ModelValueStorage}, event::EventStorage,
};
use starknet::ContractAddress;
use rising_revenant::{
    map::{Point, PointTrait}, fortifications::{Fortifications, FortificationsTrait}, core::in_range,
};

// use rising_revenant::world::ModelSchema;

/// Number of different world event types available in the game
const NUM_WORLD_EVENTS: u8 = 3;


/// Represents the minimum interval between world events for a specific game
///
/// Setup Model
///
/// # Fields
/// * `game_id` - The unique identifier of the game instance
/// * `min_interval` - The minimum time (in seconds) that must elapse between world events
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct WorldEventMinInterval {
    #[key]
    game_id: felt252,
    min_interval: u64,
}


/// Represents different types of world events that can occur in the game

#[derive(Copy, Drop, Serde, PartialEq, Introspect, Default)]
enum WorldEventType {
    #[default]
    Dragon, /// A dragon attack event
    Goblins, /// A goblin raid event
    Earthquake /// A natural disaster event
}
#[derive(Drop, Serde, Introspect)]
struct WorldEventEffect {
    efficacy: Fortifications,
    mortalities: Fortifications,
    power: u64,
    f_value: u64,
}

/// Represents the current active world event in the game
///
/// Game Model
///
/// # Fields
/// * `game_id` - Unique identifier for the game instance (key field)
/// * `event_id` - Unique identifier for the specific event
/// * `event_type` - Type of the world event (enum WorldEventType)
/// * `position` - Coordinates of the event in the game world (Point struct)
/// * `timestamp` - Unix timestamp when the event was created
#[dojo::model]
#[derive(Copy, Drop, Serde, Default)]
struct CurrentEvent {
    #[key]
    game_id: felt252,
    event_id: felt252,
    event_type: WorldEventType,
    position: Point,
    timestamp: u64,
}


mod models {
    use super::{WorldEventType, Fortifications};
    /// Represents the most recent event of a specific type in the game.
    ///
    /// GameModel
    ///
    /// # Fields
    /// * `game_id` - Unique identifier for the game instance this event belongs to
    /// * `event_type` - The type of world event
    /// * `radius_sq` - The squared radius of the event's area of effect
    /// * `did_hit` - Boolean indicating whether the event successfully affected any outposts
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


    /// Represents the configuration parameters for a world event in the game
    ///
    /// Setup Model
    ///
    /// # Members
    /// * `game_id` - Unique identifier for the game instance
    /// * `event_type` - The type of world event (enum WorldEventType)
    /// * `min_radius_sq` - Minimum squared radius of the event's area of effect
    /// * `max_radius_sq` - Maximum squared radius of the event's area of effect
    /// * `radius_sq_increase` - Rate at which the radius squared increases
    /// * `efficacy` - Impact on fortification effectiveness (enum Fortifications)
    /// * `mortalities` - Mortality rates affected by the event (enum Fortifications)
    /// * `power` - Power level of the event
    /// * `f_value` - Financial/economic value associated with the event
    #[dojo::model]
    #[derive(Drop, Serde, Copy)]
    struct WorldEventSetup {
        #[key]
        game_id: felt252,
        #[key]
        event_type: WorldEventType,
        min_radius_sq: u32,
        max_radius_sq: u32,
        radius_sq_increase: u32,
        efficacy: Fortifications,
        mortalities: Fortifications,
        power: u64,
        f_value: u64,
    }
}

use models::{LastEventOfType as LastEventOfTypeModel, WorldEventSetup as WorldEventSetupModel};

#[derive(Drop, Serde, Introspect)]
struct LastEventOfType {
    radius_sq: u32,
    did_hit: bool,
}

/// Represents the setup configuration for a world event in the game.
///
/// # Fields
/// - `efficacy`: The weighted efficacy of the fortifications.
/// - `mortalities`: The fortifications related to the mortalities caused by the event.
/// - `min_radius_sq`: The minimum radius squared within which the event can occur.
/// - `max_radius_sq`: The maximum radius squared within which the event can occur.
/// - `radius_sq_increase`: The increase in radius squared for the event if no outposts are
/// effected.
/// - `power`: The damage caused by an event with no fortifications.
/// - `f_value`: The relative amount of fortifications that half the damage dealt by an event.
#[derive(Drop, Serde, Introspect)]
struct WorldEventSetup {
    efficacy: Fortifications,
    mortalities: Fortifications,
    min_radius_sq: u32,
    max_radius_sq: u32,
    radius_sq_increase: u32,
    power: u64,
    f_value: u64,
}


/// Event emitted when a world event occurs in the game
///
/// Game Event
///
/// # Fields
/// * `event_id` - Unique identifier for the world event
/// * `game_id` - Identifier of the game instance this event belongs to
/// * `event_type` - Type of world event (enum WorldEventType)
/// * `position` - Coordinates where the event occurs (Point struct)
/// * `radius_sq` - Square of the radius defining event's area of effect
/// * `time_stamp` - Unix timestamp when the event was created
#[dojo::event]
#[derive(Copy, Drop, Serde, Default)]
struct WorldEventEvent {
    #[key]
    event_id: felt252,
    game_id: felt252,
    event_type: WorldEventType,
    position: Point,
    radius_sq: u32,
    time_stamp: u64,
}

/// Complete information about a world event
///
/// event_id: felt252, /// Unique identifier for the event
/// event_type: WorldEventType, /// Type of event
/// efficacy: Fortifications, efficacy
/// mortalities: Fortifications, chance in % of a single fortification being destroyed
/// position: Point, /// Location where the event is centered
/// radius_sq: u32, /// Squared radius of effect
/// power: u64, /// Current power/impact of the event
/// f_value: u64 /// Rate at which the event's effect diminishes

#[derive(Copy, Drop, Serde, Default)]
struct WorldEvent {
    event_id: felt252,
    event_type: WorldEventType,
    efficacy: Fortifications,
    mortalities: Fortifications,
    position: Point,
    radius_sq: u32,
    power: u64,
    f_value: u64,
}

/// Calculates protection provided by fortifications
/// # Arguments
/// * `fortifications` - Current fortification levels
/// * `efficacy` - Effectiveness of each fortification type
/// * `f_value` - Decay factor
/// # Returns
/// * Protection value as a u64
fn get_damage(
    fortifications: Fortifications, efficacy: Fortifications, f_value: u64, power: u64,
) -> u64 {
    let total = (fortifications * efficacy).sum();
    power - (total * power) / (total + f_value)
}

#[generate_trait]
impl WorldEventEffectImpl of WorldEventEffectTrait {
    fn get_damage(self: @WorldEvent, fortifications: Fortifications) -> u64 {
        get_damage(fortifications, *self.efficacy, *self.f_value, *self.power)
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
            2_u8 => WorldEventType::Earthquake,
            _ => panic!("Index out of bounds"),
        }
    }
}

#[generate_trait]
impl WorldEventSetupImpl of WorldEventSetupTrait {
    fn get_radius_sq(self: @WorldEventSetup, last_event: LastEventOfType) -> u32 {
        in_range(
            *self.min_radius_sq,
            *self.max_radius_sq,
            if last_event.did_hit {
                last_event.radius_sq + *self.radius_sq_increase
            } else {
                last_event.radius_sq
            },
        )
    }
}

#[generate_trait]
impl WorldEventStorageImpl of WorldEventStorage {
    fn get_event_min_interval(self: @WorldStorage, game_id: felt252) -> u64 {
        self
            .read_member(
                Model::<WorldEventMinInterval>::ptr_from_keys(game_id), selector!("min_interval"),
            )
    }

    fn set_event_min_interval(ref self: WorldStorage, game_id: felt252, min_interval: u64) {
        self.write_model(@WorldEventMinInterval { game_id, min_interval });
    }

    fn get_last_event_of_type(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType,
    ) -> LastEventOfType {
        self.read_schema(Model::<LastEventOfTypeModel>::ptr_from_keys((game_id, event_type)))
    }

    fn get_event_setup(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType,
    ) -> WorldEventSetup {
        self.read_schema(Model::<WorldEventSetupModel>::ptr_from_keys((game_id, event_type)))
    }

    fn get_event(self: @WorldStorage, game_id: felt252) -> WorldEvent {
        let current_event = self.get_current_event(game_id);
        let current_effect: WorldEventEffect = self
            .read_schema(
                Model::<WorldEventSetupModel>::ptr_from_keys((game_id, current_event.event_type)),
            );

        WorldEvent {
            event_id: current_event.event_id,
            event_type: current_event.event_type,
            efficacy: current_effect.efficacy,
            mortalities: current_effect.mortalities,
            position: current_event.position,
            radius_sq: self.get_last_event_radius_sq(game_id, current_event.event_type),
            power: current_effect.power,
            f_value: current_effect.f_value,
        }
    }

    fn emit_world_event_event(
        ref self: WorldStorage,
        event_id: felt252,
        game_id: felt252,
        event_type: WorldEventType,
        position: Point,
        radius_sq: u32,
        time_stamp: u64,
    ) {
        self
            .emit_event(
                @WorldEventEvent { event_id, game_id, event_type, position, radius_sq, time_stamp },
            );
    }

    fn get_current_event(self: @WorldStorage, game_id: felt252) -> CurrentEvent {
        self.read_model(game_id)
    }

    fn get_current_event_type(self: @WorldStorage, game_id: felt252) -> WorldEventType {
        self.read_member(Model::<CurrentEvent>::ptr_from_keys(game_id), selector!("event_type"))
    }

    fn get_current_event_position(self: @WorldStorage, game_id: felt252) -> Point {
        self.read_member(Model::<CurrentEvent>::ptr_from_keys(game_id), selector!("position"))
    }

    fn set_event_did_hit(ref self: WorldStorage, game_id: felt252, event_type: WorldEventType) {
        self
            .write_member(
                Model::<LastEventOfTypeModel>::ptr_from_keys((game_id, event_type)),
                selector!("did_hit"),
                true,
            );
    }

    fn get_last_event_radius_sq(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType,
    ) -> u32 {
        self
            .read_member(
                Model::<LastEventOfTypeModel>::ptr_from_keys((game_id, event_type)),
                selector!("radius_sq"),
            )
    }
    fn set_last_event_of_type(
        ref self: WorldStorage, game_id: felt252, event_type: WorldEventType, radius_sq: u32,
    ) {
        self.write_model(@LastEventOfTypeModel { game_id, event_type, radius_sq, did_hit: false });
    }
    fn set_current_event(
        ref self: WorldStorage,
        game_id: felt252,
        event_id: felt252,
        event_type: WorldEventType,
        position: Point,
        timestamp: u64,
    ) {
        self.write_model(@CurrentEvent { game_id, event_id, event_type, position, timestamp });
    }

    fn set_event_vars(
        ref self: WorldStorage, game_id: felt252, event_type: WorldEventType, vars: WorldEventSetup,
    ) {
        self
            .write_model(
                @WorldEventSetupModel {
                    game_id,
                    event_type,
                    min_radius_sq: vars.min_radius_sq,
                    max_radius_sq: vars.max_radius_sq,
                    radius_sq_increase: vars.radius_sq_increase,
                    efficacy: vars.efficacy,
                    mortalities: vars.mortalities,
                    power: vars.power,
                    f_value: vars.f_value,
                },
            );
    }
}

