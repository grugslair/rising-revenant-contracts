use core::poseidon::poseidon_hash_span;
use rising_revenant::{
    care_packages::{systems::{get_fortifications_types, get_fortifications}, Rarity},
    fortifications::Fortifications, utils::felt252_to_u128,
};

#[test]
fn fortification_split_test() {
    let mut total: Fortifications = 0_u64.into();
    for n in 1..21_u128 {
        let mut round: Fortifications = 0_u64.into();
        for m in 1..1000_u128 {
            let randomness = felt252_to_u128(poseidon_hash_span([m.into(), n.into()].span()));
            let splits = get_fortifications_types(n, randomness);

            round += splits;
        };
        total += round;
        let Fortifications { palisades, trenches, walls, basements } = round;
        println!(
            "total: {n}, palisades: {palisades}, trenches: {trenches}, walls: {walls}, basements: {basements}",
        );
    };
    let Fortifications { palisades, trenches, walls, basements } = total;
    println!(
        "palisades: {palisades}, trenches: {trenches}, walls: {walls}, basements: {basements}",
    );
}

