use rising_revenant::{
    utils::felt252_to_u128,
    world_events::models::{CurrentEvent, WorldEventType, NUM_WORLD_EVENTS, WorldEventSetup},
    map::{Point, GeneratePointTrait, PointTrait}, core::ToNonZero
};
use core::{integer::u128_safe_divmod, zeroable::NonZero};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{get_block_timestamp};


#[generate_trait]
impl WorldEventImpl of WorldEvenTrait {
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

    fn in_range(self: @CurrentEvent, location: Point) -> bool {
        self.position.in_range(location, *self.radius_sq)
    }
}

