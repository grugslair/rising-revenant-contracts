use cubit::f128::{Fixed, FixedTrait, ONE_u128};
use rising_revenant::utils::felt252_to_u128;
use core::num::traits::Bounded;

use super::models::{Fortifications};


// Probabalility is a number between 0 and 1 the mag of a fixed number
fn fortifications_destroyed(probability: u128, randomness: felt252) -> u128 {
    if probability == 0 {
        return 0;
    };
    if probability == ONE_u128 {
        return Bounded::MAX;
    };
    let randomness = (felt252_to_u128(randomness) % ONE_u128) + 1;
    let probability = FixedTrait::new(probability, false);
    (random.ln() / probability.ln()).try_into().unwrap()
}


fn damage_done(fortifications: Fortifications, randomness: felt252) -> u128 {}
