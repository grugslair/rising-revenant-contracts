use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;
use rising_revenant::{map::Point, fortifications::{Fortifications, FortificationsTrait}};

const NUM_WORLD_EVENTS: u8 = 3;


#[derive(Copy, Drop, Serde, PartialEq, Introspect, Default)]
enum WorldEventType {
    #[default]
    Dragon,
    Goblins,
    EarthQuake,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct WorldEventSetup {
    #[key]
    game_id: felt252,
    min_radius_sq: u32,
    max_radius_sq: u32,
    radius_sq_increase: u32,
    min_interval: u64,
    power: u64,
    decay: u64,
}

#[dojo::model]
#[derive(Copy, Drop, Serde, Default)]
struct CurrentEvent {
    #[key]
    game_id: felt252,
    event_id: felt252,
    event_type: WorldEventType,
    position: Point,
    radius_sq: u32,
    time_stamp: u64,
    did_hit: bool,
}


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
impl CurrentEventImpl of CurrentEventTrait {
    fn get_current_event(self: @IWorldDispatcher, game_id: felt252) -> CurrentEvent {
        CurrentEventStore::get(*self, game_id)
    }
}

#[generate_trait]
impl WorldEventSetupImpl of WorldEventSetupTrait {
    fn get_world_event_setup(self: @IWorldDispatcher, game_id: felt252) -> WorldEventSetup {
        WorldEventSetupStore::get(*self, game_id)
    }
}
