use dojo::world::{IWorldDispatcher};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotTotal {
    #[key]
    game_id: felt252,
    total: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotClaimed {
    #[key]
    game_id: felt252,
    total: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Claimed {
    #[key]
    game_id: felt252,
    dev: bool,
    winner: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotSplit {
    #[key]
    game_id: felt252,
    dev_permille: u16,
    contribution_permille: u16,
}

