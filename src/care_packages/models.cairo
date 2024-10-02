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

const N_RARITIES: u128 = 5;

#[derive(Serde, Copy, Drop, PartialEq)]
enum Rarity {
    None,
    Common,
    Rare,
    Epic,
    Legendary,
}

impl UTIntoRarity<T, +TryInto<T, u8>,> of Into<T, Rarity> {
    fn into(self: T) -> Rarity {
        match self.try_into().unwrap() {
            0_u8 => Rarity::None,
            1_u8 => Rarity::Common,
            2_u8 => Rarity::Rare,
            3_u8 => Rarity::Epic,
            4_u8 => Rarity::Legendary,
            _ => panic!("Invalid rarity"),
        }
    }
}
