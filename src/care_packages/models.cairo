

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CarePackageMarket {
    #[key]
    game_id: felt252,
    target_price: u256,
    decay_constant_mag: u128,
    max_sellable_mag: u128,
    time_scale_mag: u128,
    start_time: u64,
    sold: u64,
}
