use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
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
    fn get_outpost(self: @WorldStorage, id: felt252) -> Outpost {
        self.read_model(id)
    }
    fn get_outpost_setup(self: @WorldStorage, game_id: felt252) -> OutpostSetup {
        self.read_model(game_id)
    }
    fn get_outpost_event(
        self: @WorldStorage, outpost_id: felt252, event_id: felt252
    ) -> OutpostEvent {
        self.read_model((outpost_id, event_id))
    }
    fn get_outposts_active(self: @WorldStorage, game_id: felt252) -> OutpostsActive {
        self.read_model(game_id)
    }
    fn get_starting_hp(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<OutpostSetup>::ptr_from_keys(game_id), selector!("hp"))
    }
    fn get_active_outposts(self: @WorldStorage, game_id: felt252) -> u32 {
        self.read_member(Model::<OutpostsActive>::ptr_from_keys(game_id), selector!("active"))
    }
}

