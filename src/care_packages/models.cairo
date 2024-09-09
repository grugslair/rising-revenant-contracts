#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum Rarity {
    Origin,
    Midnight,
    Eclipse,
    Eternal,
}

impl UTIntoRarity<T, +TryInto<T, u8>,> of Into<T, Rarity> {
    fn into(self: T) -> Rarity {
        match self.try_into().unwrap() {
            0_u8 => Rarity::Origin,
            1_u8 => Rarity::Midnight,
            2_u8 => Rarity::Eclipse,
            3_u8 => Rarity::Eternal,
            _ => panic!("Invalid rarity"),
        }
    }
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct CarePackage {
    #[key]
    token_id: u128,
    rarity: Rarity,
}
