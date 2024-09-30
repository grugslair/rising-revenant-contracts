const N_RARITIES: u128 = 5;

#[derive(Serde, Copy, Drop, PartialEq, starknet::Store)]
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
