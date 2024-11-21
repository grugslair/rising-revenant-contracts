use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::{map::Point, fortifications::models::Fortifications};

/// Represents the initial setup configuration for outposts in a game
/// @param game_id - Unique identifier for the game instance
/// @param price - Cost to create an outpost
/// @param hp - Initial health points for new outposts
#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct OutpostSetup {
    #[key]
    game_id: felt252,
    price: u256,
    hp: u64,
}

/// Represents an individual outpost instance in the game
/// @param id - Unique identifier for the outpost
/// @param game_id - Associated game instance
/// @param position - Location coordinates of the outpost
/// @param fortifications - Defensive structures attached to the outpost
/// @param hp - Current health points of the outpost
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

/// Tracks events that affect specific outposts
/// @param outpost_id - ID of the affected outpost
/// @param event_id - Unique identifier for the event
/// @param applied - Whether the event has been processed
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostEvent {
    #[key]
    outpost_id: felt252,
    #[key]
    event_id: felt252,
    applied: bool,
}

/// Tracks the number of active outposts in a game
/// @param game_id - Associated game instance
/// @param active - Count of currently active outposts
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostsActive {
    #[key]
    game_id: felt252,
    active: u32,
}

