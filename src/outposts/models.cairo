use dojo::world::{IWorldDispatcher};
use rising_revenant::{map::Point, fortifications::models::Fortifications};

#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct OutpostSetup {
    #[key]
    game_id: felt252,
    price: u256,
    hp: u64,
}

#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct Outpost {
    #[key]
    id: felt252,
    game_id: felt252,
    position: Point,
    fortifications: Fortifications,
    hp: u64,
}


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostEvent {
    #[key]
    outpost_id: felt252,
    #[key]
    event_id: felt252,
    applied: bool,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostsActive {
    #[key]
    game_id: felt252,
    active: u32,
}

#[generate_trait]
impl OutpostModelsImpl of OutpostModels {
    #[inline(always)]
    fn get_outpost(self: @IWorldDispatcher, id: felt252) -> Outpost {
        OutpostStore::get(*self, id)
    }
    #[inline(always)]
    fn get_outpost_setup(self: @IWorldDispatcher, game_id: felt252) -> OutpostSetup {
        OutpostSetupStore::get(*self, game_id)
    }
    #[inline(always)]
    fn get_outpost_event(
        self: @IWorldDispatcher, outpost_id: felt252, event_id: felt252
    ) -> OutpostEvent {
        OutpostEventStore::get(*self, outpost_id, event_id)
    }
    #[inline(always)]
    fn get_outposts_active(self: @IWorldDispatcher, game_id: felt252) -> OutpostsActive {
        OutpostsActiveStore::get(*self, game_id)
    }
    #[inline(always)]
    fn get_starting_hp(self: @IWorldDispatcher, game_id: felt252) -> u64 {
        OutpostSetupStore::get_hp(*self, game_id)
    }
    #[inline(always)]
    fn get_active_outposts(self: @IWorldDispatcher, game_id: felt252) -> u32 {
        OutpostsActiveStore::get_active(*self, game_id)
    }
}

