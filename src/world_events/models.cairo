use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;
use rising_revenant::{models::Point, fortifications::models::{Fortifications, FortificationsTrait}};

const NUM_WORLD_EVENTS: u8 = 3;


#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum WorldEvent {
    Dragon,
    Goblins,
    EarthQuake,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct CurrentEvent {
    #[key]
    game_id: felt252,
    event_type: WorldEvent,
    position: Point,
    radius_sq: u32,
    power: u64,
    decay: u64,
    block_number: u64,
    event_seed: felt252,
}

impl U8IntoWorldEvent<T, +TryInto<T, u8>> of Into<T, WorldEvent> {
    #[inline(always)]
    fn into(self: T) -> WorldEvent {
        match self.try_into().unwrap() {
            0_u8 => WorldEvent::Dragon,
            1_u8 => WorldEvent::Goblins,
            2_u8 => WorldEvent::EarthQuake,
            _ => panic!("Index out of bounds"),
        }
    }
}

#[generate_trait]
impl CurrentEventImpl of CurrentEventTrait {
    fn get_current_event(self: @IWorldDispatcher, game_id: felt252) -> CurrentEvent {
        CurrentEventStore::get(*self, game_id)
    }
}

