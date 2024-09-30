use dojo::world::{IWorldDispatcher};
use rising_revenant::{models::Point, fortifications::models::{Fortifications}, utils::hash_value};

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
struct OutpostLastEvent {
    #[key]
    outpost_id: felt252,
    event_id: felt252,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostsActive {
    #[key]
    game_id: felt252,
    active: u32,
}

#[generate_trait]
impl OutpostImpl of OutpostTrait {
    fn get_outpost(self: @IWorldDispatcher, id: felt252) -> Outpost {
        OutpostStore::get(*self, id)
    }
}

#[generate_trait]
impl OutpostsActiveImpl of OutpostsActiveTrait {
    fn reduce_active_outposts(self: IWorldDispatcher, game_id: felt252) -> u32 {
        let mut model = OutpostsActiveStore::get(self, game_id);
        assert(model.active > 1, 'No active outposts');
        model.active -= 1;
        model.set(self);
        model.active
    }
}

