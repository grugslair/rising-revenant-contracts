use rising_revenant::{
    utils::felt252_to_u128,
    world_events::models::{
        CurrentEvent, WorldEventType, NUM_WORLD_EVENTS, WorldEventSetup, WorldEvent,
        WorldEventSetupTrait, CurrentEventTrait
    },
    map::{Point, GeneratePointTrait, PointTrait}, core::ToNonZero
};
use core::{integer::u128_safe_divmod, zeroable::NonZero};
use dojo::world::{WorldStorage, IWorldDispatcherTrait};
use starknet::{get_block_timestamp};

/// Trait implementation for handling World Events in the game
#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    /// Retrieves the current world event for a given game
    /// # Arguments
    /// * `game_id` - The unique identifier for the game
    /// # Returns
    /// * `WorldEvent` - A struct containing the current event's details including position, radius,
    /// power and decay
    fn get_world_event(self: @WorldStorage, game_id: felt252) -> WorldEvent {
        let current = self.get_current_event(game_id);
        let setup = self.get_world_event_setup(game_id);
        WorldEvent {
            event_id: current.event_id,
            event_type: current.event_type,
            position: current.position,
            radius_sq: current.radius_sq,
            power: setup.power,
            decay: setup.decay,
        }
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
        self: @WorldEventSetup,
        mut last_event: CurrentEvent,
        map_size: Point,
        randomness: felt252,
        time_stamp: u64
    ) -> CurrentEvent {
        let seed = felt252_to_u128(randomness);
        let (seed, event_type_u128) = u128_safe_divmod(seed, NUM_WORLD_EVENTS.non_zero());
        last_event.event_id = randomness;
        last_event.event_type = event_type_u128.into();
        last_event.position = map_size.generate_point(seed);
        last_event.time_stamp = time_stamp;
        if last_event.did_hit {
            last_event.did_hit = false;
            if last_event.radius_sq + *self.radius_sq_increase > *self.max_radius_sq {
                last_event.radius_sq = *self.max_radius_sq;
            } else {
                last_event.radius_sq += *self.radius_sq_increase;
            };
        } else if last_event.radius_sq < *self.min_radius_sq {
            last_event.radius_sq = *self.min_radius_sq;
        };
        last_event
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

