use dojo::{world::WorldStorage, model::{ModelStorage, Model, ModelValueStorage}};
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
    Earthquake, /// A natural disaster event
}


#[derive(Drop, Serde)]
struct WorldEventVars {
    efficacy: Fortifications,
    mortalities: Fortifications,
    min_radius_sq: u32,
    max_radius_sq: u32,
    radius_sq_increase: u32,
    power: u64,
    f_value: u64
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
            2_u8 => WorldEventType::Earthquake,
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


#[generate_trait]
impl WorldEventStorageImpl of WorldEventStorage {
    fn get_event_min_interval(self: @WorldStorage, game_id: felt252) -> u64 {
        self
            .read_member(
                Model::<WorldEventMinInterval>::ptr_from_keys(game_id), selector!("min_interval")
            )
    }

    fn set_event_min_interval(ref self: WorldStorage, game_id: felt252, min_interval: u64) {
        self.write_model(@WorldEventMinInterval { game_id, min_interval });
    }

    fn get_last_event_of_type(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> LastEventOfTypeValue {
        self.read_value((game_id, event_type))
    }

    fn get_event_setup(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> WorldEventSetupValue {
        self.read_value((game_id, event_type))
    }

    fn get_event(self: @WorldStorage, game_id: felt252) -> WorldEvent {
        let current_event = self.get_current_event(game_id);
        let current_effect: WorldEventEffectValue = self
            .read_value((game_id, current_event.event_type));

        WorldEvent {
            event_id: current_event.event_id,
            event_type: current_event.event_type,
            efficacy: current_effect.efficacy,
            mortalities: current_effect.mortalities,
            position: current_event.position,
            radius_sq: self.get_last_event_radius_sq(game_id, current_event.event_type),
            power: current_effect.power,
            f_value: current_effect.f_value
        }
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
                Model::<LastEventOfType>::ptr_from_keys((game_id, event_type)),
                selector!("did_hit"),
                true
            );
    }

    fn get_last_event_radius_sq(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> u32 {
        self
            .read_member(
                Model::<LastEventOfType>::ptr_from_keys((game_id, event_type)),
                selector!("radius_sq")
            )
    }
    fn set_last_event_of_type(
        ref self: WorldStorage, game_id: felt252, event_type: WorldEventType, radius_sq: u32
    ) {
        self.write_model(@LastEventOfType { game_id, event_type, radius_sq, did_hit: false });
    }
    fn set_current_event(
        ref self: WorldStorage,
        game_id: felt252,
        event_id: felt252,
        event_type: WorldEventType,
        position: Point,
        timestamp: u64
    ) {
        self.write_model(@CurrentEvent { game_id, event_id, event_type, position, timestamp });
    }

    fn set_event_vars(
        ref self: WorldStorage, game_id: felt252, event_type: WorldEventType, vars: WorldEventVars
    ) {
        self
            .write_model(
                @WorldEventSetup {
                    game_id,
                    event_type,
                    min_radius_sq: vars.min_radius_sq,
                    max_radius_sq: vars.max_radius_sq,
                    radius_sq_increase: vars.radius_sq_increase,
                }
            );
        self
            .write_model(
                @WorldEventEffect {
                    game_id,
                    event_type,
                    efficacy: vars.efficacy,
                    mortalities: vars.mortalities,
                    power: vars.power,
                    f_value: vars.f_value,
                }
            );
    }
}

