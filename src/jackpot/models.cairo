use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotTotal {
    #[key]
    game_id: felt252,
    total: u256,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotClaimed {
    #[key]
    game_id: felt252,
    amount: u256,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Claimant {
    Dev,
    Winner,
    Contributor: ContractAddress,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Claimed {
    #[key]
    game_id: felt252,
    #[key]
    claimant: Claimant,
    claimed: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotSplit {
    #[key]
    game_id: felt252,
    dev_permille: u16,
    contribution_permille: u16,
}

