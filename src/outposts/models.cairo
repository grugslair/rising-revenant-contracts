use rising_revenant::{map::Point, fortifications::models::Fortifications};

#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct OutpostSetup{
    #[key]
    game_id: felt252,
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

