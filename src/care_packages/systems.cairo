use super::Rarity;
use rising_revenant::{
    fortifications::models::Fortifications, core::ToNonZero, utils::felt252_to_u128
};
use core::integer::u128_safe_divmod;

fn get_fortifications_types(total: u128, randomness: felt252) -> Fortifications {
    let randomness = felt252_to_u128(randomness);
    let (randomness, trenches_s) = u128_safe_divmod(randomness, (total + 1).non_zero());
    let (randomness, palisades) = u128_safe_divmod(randomness, (trenches_s + 1).non_zero());
    let (_, walls_s) = u128_safe_divmod(randomness, (total - trenches_s + 1).non_zero());
    let trenches = (trenches_s - palisades).try_into().unwrap();
    let walls = (walls_s - trenches_s).try_into().unwrap();
    let basements = (total - walls_s).try_into().unwrap();
    let palisades = palisades.try_into().unwrap();
    Fortifications { palisades, trenches, walls, basements, }
}

fn get_number_of_fortifications(rarity: Rarity, randomness: felt252) -> u128 {
    let randomness = felt252_to_u128(randomness);
    match rarity {
        Rarity::None => { panic!("Rarity not set") },
        Rarity::Common => 8,
        Rarity::Rare => 10 + randomness % 3,
        Rarity::Epic => 12 + randomness % 4,
        Rarity::Legendary => 15 + randomness % 6,
    }
}

fn get_rarity(randomness: felt252) -> Rarity {
    let rarity = felt252_to_u128(randomness) % 100;
    if rarity < 65 {
        Rarity::Common
    } else if rarity < 85 {
        Rarity::Rare
    } else if rarity < 97 {
        Rarity::Epic
    } else {
        Rarity::Legendary
    }
}
