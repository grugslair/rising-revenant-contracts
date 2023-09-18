mod revenant;

#[derive(Component, Copy, Drop, Serde)]
struct Position {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    x: u32,
    y: u32
}

#[derive(Component, Copy, Drop, Serde)]
struct Lifes {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    count: u32
}

#[derive(Component, Copy, Drop, Serde)]
struct Defence {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    plague: u32
}

#[derive(Component, Copy, Drop, Serde)]
struct Name {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    value: felt252
}

#[derive(Component, Copy, Drop, Serde)]
struct Prosperity {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    value: felt252
}

#[derive(Component, Copy, Drop, Serde)]
struct Balance {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    value: felt252
}

// TODO: Could be ENUM
#[derive(Component, Copy, Drop, Serde)]
struct WorldEvent {
    #[key]
    entity_id: u128,
    #[key]
    game_id: u32,
    radius: u32,
    event_type: u32,
    block_number: u64
}
// TODO: Impl World
// is x,y within radius?

#[derive(Component, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32, // increment
    start_time: u64,
    prize: u32,
    status: bool
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct OutpostCount {
    #[key]
    game_id: u32,
    #[key]
    address: felt252,
    count: u32,
    name: felt252
}

// Config Components ---------------------------------------------------------------------

// This will track the number of games played
#[derive(Component, Copy, Drop, Serde)]
struct GameTracker {
    #[key]
    entity_id: u128, // FIXED
    count: u32
}

#[derive(Component, Copy, Drop, Serde)]
struct Ownership {
    #[key]
    entity_id: u128, // FIXED
    #[key]
    game_id: u32, // increment
    address: felt252
}

// Components to check ---------------------------------------------------------------------

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct GameEntityCounter
{
    #[key]
    game_id: u32,

    outpost_count: u128,
    event_count: u128
}