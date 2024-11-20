use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};

/// Represents the total amount in a jackpot for a specific game
/// @param game_id - Unique identifier for the game
/// @param total - Total amount in the jackpot in wei
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotTotal {
    #[key]
    game_id: felt252,
    total: u256,
}

/// Tracks the amount that has been claimed from a specific game's jackpot
/// @param game_id - Unique identifier for the game
/// @param amount - Amount that has been claimed in wei
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotClaimed {
    #[key]
    game_id: felt252,
    amount: u256,
}

/// Represents different types of entities that can claim from the jackpot
/// Dev: Game developers
/// Winner: Game winner
/// Contributor: Address of someone who contributed to the jackpot
#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Claimant {
    Dev,
    Winner,
    Contributor: ContractAddress,
}

/// Tracks whether a specific claimant has claimed their share for a game
/// @param game_id - Unique identifier for the game
/// @param claimant - Type of claimant (Dev, Winner, or Contributor)
/// @param claimed - Boolean indicating if the share has been claimed
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Claimed {
    #[key]
    game_id: felt252,
    #[key]
    claimant: Claimant,
    claimed: bool,
}

/// Defines how the jackpot is split between different parties
/// @param game_id - Unique identifier for the game
/// @param dev_permille - Developer's share in permille (parts per thousand)
/// @param contribution_permille - Contributors' share in permille
#[dojo::model]
#[derive(Copy, Drop, Serde, IntrospectPacked)]
struct JackpotSplit {
    #[key]
    game_id: felt252,
    dev_permille: u16,
    contribution_permille: u16,
}

