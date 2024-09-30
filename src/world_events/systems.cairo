use rising_revenant::{
    utils::felt252_to_u128, world_events::models::{CurrentEvent, WorldEvent, NUM_WORLD_EVENTS},
    game::models::{}, models::{Point, GeneratePointTrait, PointTrait}, core::ToNonZero
};
use core::{integer::u128_safe_divmod, zeroable::NonZero};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{get_block_number};


#[generate_trait]
impl WorldEventImpl of WorldEvenTrait {
    fn generate_event(
        mut current_event: CurrentEvent, map_size: Point, randomness: felt252
    ) -> CurrentEvent {
        let seed = felt252_to_u128(randomness);
        let (seed, event_type_u128) = u128_safe_divmod(seed, NUM_WORLD_EVENTS.non_zero());
        current_event.event_seed = randomness;
        current_event.position = map_size.generate_point(seed);
        current_event.event_type = event_type_u128.into();
        current_event.block_number = get_block_number();
        current_event
    }

    fn in_range(self: @CurrentEvent, location: Point) -> bool {
        self.position.in_range(location, *self.radius_sq)
    }
}

