use rising_revenant::{
    utils::{felt252_to_u128, SeedProbability},
    world_events::models::{
        CurrentEvent, WorldEventType, NUM_WORLD_EVENTS, WorldEventSetup, WorldEvent,
        WorldEventSetupTrait, LastEventOfType, LastEventOfTypeValue, WorldEventMinInterval,
        WorldEventSetupValue, WorldEventEffectValue
    },
    map::{Point, GeneratePointTrait, PointTrait}, core::ToNonZero
};
use core::{integer::u128_safe_divmod, zeroable::NonZero};
use dojo::{world::WorldStorage, model::{ModelValueStorage, ModelStorage, Model}};
use starknet::{get_block_timestamp};

/// Trait implementation for handling World Events in the game
#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    fn get_min_interval(self: @WorldStorage, game_id: felt252) -> u64 {
        self
            .read_member(
                Model::<WorldEventMinInterval>::ptr_from_keys(game_id), selector!("min_interval")
            )
    }

    fn get_last_event_of_type(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> LastEventOfTypeValue {
        self.read_value((game_id, event_type))
    }

    fn get_world_event_setup(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> WorldEventSetupValue {
        self.read_value((game_id, event_type))
    }

    fn get_world_event(self: @WorldStorage, game_id: felt252) -> WorldEvent {
        let current_event = self.get_current_event(game_id);
        let current_effect: WorldEventEffectValue = self
            .read_value((game_id, current_event.event_type));

        WorldEvent {
            event_id: current_event.event_id,
            event_type: current_event.event_type,
            efficacy: current_effect.efficacy,
            mortalities: current_effect.mortalities,
            position: current_event.position,
            radius_sq: self.get_event_radius_sq(game_id, current_event.event_type),
            power: current_effect.power,
            f_value: current_effect.f_value
        }
    }

    fn get_current_event(self: @WorldStorage, game_id: felt252) -> CurrentEvent {
        self.read_model(game_id)
    }

    fn set_event_did_hit(ref self: WorldStorage, game_id: felt252, event_type: WorldEventType) {
        self
            .write_member(
                Model::<LastEventOfType>::ptr_from_keys((game_id, event_type)),
                selector!("did_hit"),
                true
            );
    }

    fn get_event_radius_sq(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> u32 {
        self
            .read_member(
                Model::<LastEventOfType>::ptr_from_keys((game_id, event_type)),
                selector!("radius_sq")
            )
    }


    /// Generates a new world event based on provided parameters
    /// # Arguments
    /// * `last_event` - The previous event's state
    /// * `map_size` - The dimensions of the game map
    /// * `randomness` - A random seed for event generation
    /// * `time_stamp` - Current timestamp for the event
    /// # Returns
    /// * `CurrentEvent` - The newly generated event with updated properties
    fn generate_event(
        self: @WorldStorage,
        last_event: CurrentEvent,
        map_size: Point,
        randomness: felt252,
        timestamp: u64
    ) -> (CurrentEvent, LastEventOfType) {
        let mut seed = felt252_to_u128(randomness);
        let event_type = seed.get_value(NUM_WORLD_EVENTS.non_zero()).into();
        let last_event_of_type = self.get_last_event_of_type(last_event.game_id, event_type);
        let event_setup = self.get_world_event_setup(last_event.game_id, event_type);

        (
            CurrentEvent {
                game_id: last_event.game_id,
                event_id: randomness,
                event_type,
                position: seed.generate_point(map_size),
                timestamp,
            },
            LastEventOfType {
                game_id: last_event.game_id,
                event_type,
                radius_sq: event_setup.get_radius_sq(last_event_of_type),
                did_hit: false
            }
        )
    }
}

