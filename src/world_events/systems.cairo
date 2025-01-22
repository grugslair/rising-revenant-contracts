use dojo::world::WorldStorage;
use rising_revenant::{
    utils::{felt252_to_u128, SeedProbability},
    world_events::{
        CurrentEvent, WorldEventType, NUM_WORLD_EVENTS, WorldEventSetupTrait, LastEventOfType,
        WorldEventStorage
    },
    map::{Point, GeneratePointTrait, PointTrait}, core::ToNonZero
};


/// Trait implementation for handling World Events in the game
#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    /// Generates a new world event based on provided parameters
    /// # Arguments
    /// * `last_event` - The previous event's state
    /// * `map_size` - The dimensions of the game map
    /// * `randomness` - A random seed for event generation
    /// * `time_stamp` - Current timestamp for the event
    /// # Returns
    /// * `CurrentEvent` - The newly generated event with updated properties
    fn generate_event(
        ref self: WorldStorage,
        last_event: CurrentEvent,
        map_size: Point,
        randomness: felt252,
        timestamp: u64
    ) {
        let mut seed = felt252_to_u128(randomness);
        let event_type = seed.get_value(NUM_WORLD_EVENTS.non_zero()).into();
        let last_event_of_type = self.get_last_event_of_type(last_event.game_id, event_type);
        let event_setup = self.get_event_setup(last_event.game_id, event_type);

        self
            .set_last_event_of_type(
                last_event.game_id, event_type, event_setup.get_radius_sq(last_event_of_type)
            );
        self
            .set_current_event(
                last_event.game_id,
                randomness,
                event_type,
                seed.generate_point(map_size),
                timestamp,
            );
    }
}

