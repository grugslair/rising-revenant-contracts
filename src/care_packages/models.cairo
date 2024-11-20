/// Represents a market for care packages within a game.
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CarePackageMarket {
    /// Unique identifier for the game.
    #[key]
    game_id: felt252,
    
    /// The target price for the care package.
    target_price: u256,
    
    /// Magnitude of the decay constant, affecting price changes over time.
    decay_constant_mag: u128,
    
    /// Maximum magnitude of sellable items.
    max_sellable_mag: u128,
    
    /// Magnitude of the time scale, influencing the rate of decay.
    time_scale_mag: u128,
    
    /// The start time of the market in Unix timestamp format.
    start_time: u64,
    
    /// The number of items sold.
    sold: u64,
}
