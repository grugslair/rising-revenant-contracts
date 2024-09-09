use super::models::{Rarity};
use rising_revenant::fortifications::models::Fortifications;


fn get_fortifications(rarity: Rarity, randomness: felt252) -> Fortifications {
    Fortifications { palisade: 0, obsidian: 0, stone: 0, trench: 0, }
}
