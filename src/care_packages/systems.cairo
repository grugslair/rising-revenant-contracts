use dojo::{world::WorldStorage, model::ModelStorage};

use super::Rarity;
use rising_revenant::{
    fortifications::models::Fortifications, core::ToNonZero, utils::felt252_to_u128,
    care_packages::models::{CarePackageMarket,}, vrgda::{LogisticVRGDA, VRGDATrait},
    fixed::FixedToDecimal
};
use core::integer::u128_safe_divmod;
// use origami_defi::auction::vrgda::{LogisticVRGDA, VRGDATrait};
use cubit::f128::types::fixed::{Fixed, FixedTrait};

/// Calculates the types of fortifications based on total and randomness.
/// 
/// # Arguments
/// 
/// * `total` - The total number of fortifications.
/// * `randomness` - A random value used to determine the distribution of fortification types.
/// 
/// # Returns
/// 
/// A `Fortifications` struct containing the calculated number of palisades, trenches, walls, and basements.
fn get_fortifications_types(total: u128, randomness: u128) -> Fortifications {
    let (randomness, trenches_s) = u128_safe_divmod(randomness, (total + 1).non_zero());
    let (randomness, palisades) = u128_safe_divmod(randomness, (trenches_s + 1).non_zero());
    let (_, walls_s) = u128_safe_divmod(randomness, (total - trenches_s + 1).non_zero());
    let trenches = (trenches_s - palisades).try_into().unwrap();
    let walls = (walls_s - trenches_s).try_into().unwrap();
    let basements = (total - walls_s).try_into().unwrap();
    let palisades = palisades.try_into().unwrap();
    Fortifications { palisades, trenches, walls, basements, }
}

/// Returns the range of fortifications based on the rarity.
/// 
/// # Arguments
/// 
/// * `rarity` - The rarity level of the fortifications.
/// 
/// # Returns
/// 
/// A tuple containing the minimum and maximum extra fortifications plus one.
fn get_range_of_fortifications(rarity: Rarity) -> (u128, u128) {
    match rarity {
        Rarity::None => { panic!("Rarity not set") },
        Rarity::Common => (8, 1),
        Rarity::Rare => (10, 3),
        Rarity::Epic => (12, 4),
        Rarity::Legendary => (15, 6),
    }
}

/// Determines the fortifications based on rarity and randomness.
/// 
/// # Arguments
/// 
/// * `rarity` - The rarity level of the fortifications.
/// * `randomness` - A random value used to determine the fortifications.
/// 
/// # Returns
/// 
/// A `Fortifications` struct with the calculated fortifications.
fn get_fortifications(rarity: Rarity, randomness: felt252) -> Fortifications {
    let randomness = felt252_to_u128(randomness);
    let (base, divmod) = get_range_of_fortifications(rarity);
    let (randomness, value) = u128_safe_divmod(randomness, divmod.non_zero());
    get_fortifications_types(base + value, randomness)
}

/// Determines the rarity based on randomness.
/// 
/// # Arguments
/// 
/// * `randomness` - A random value used to determine the rarity.
/// 
/// # Returns
/// 
/// A `Rarity` enum value representing the determined rarity.
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

/// Implementation of the `CarePackageMarketTrait` for `CarePackageMarketImpl`.
/// Provides methods to interact with the care package market.
#[generate_trait]
impl CarePackageMarketImpl of CarePackageMarketTrait {
    /// Retrieves the care package market for a given game ID.
    /// 
    /// # Arguments
    /// 
    /// * `game_id` - The ID of the game for which to retrieve the market.
    /// 
    /// # Returns
    /// 
    /// A `CarePackageMarket` struct representing the market.
    fn get_care_package_market(self: @WorldStorage, game_id: felt252) -> CarePackageMarket {
        self.read_model(game_id)
    }

    /// Converts the care package market to a `LogisticVRGDA`.
    /// 
    /// # Returns
    /// 
    /// A `LogisticVRGDA` struct representing the VRGDA.
    fn to_logistic_vrgda(self: @CarePackageMarket) -> LogisticVRGDA {
        LogisticVRGDA {
            target_price: (*self.target_price).decimal_to_fixed(18),
            decay_constant: FixedTrait::new(*self.decay_constant_mag, false),
            max_sellable: FixedTrait::new(*self.max_sellable_mag, false),
            time_scale: FixedTrait::new(*self.time_scale_mag, false),
        }
    }

    /// Calculates the price of a care package at a given time.
    /// 
    /// # Arguments
    /// 
    /// * `time` - The time at which to calculate the price.
    /// 
    /// # Returns
    /// 
    /// A `u256` value representing the price.
    fn get_price(self: @CarePackageMarket, time: u64) -> u256 {
        self.to_logistic_vrgda().get_vrgda_price(time.into(), (*self.sold).into()).to_decimal(18)
    }

    /// Calculates the total price for multiple care packages at a given time.
    /// 
    /// # Arguments
    /// 
    /// * `time` - The time at which to calculate the price.
    /// * `count` - The number of care packages to calculate the price for.
    /// 
    /// # Returns
    /// 
    /// A `u256` value representing the total price.
    fn get_multiple_price(self: @CarePackageMarket, time: u128, mut count: u128) -> u256 {
        let vrgda = self.to_logistic_vrgda();
        let mut total = FixedTrait::ZERO();
        let mut sold: Fixed = (*self.sold).into();
        loop {
            if count == 0 {
                break;
            };
            total += vrgda
                .get_vrgda_price(
                    FixedTrait::new_unscaled(time, false), FixedTrait::new_unscaled(count, false)
                );
            sold += FixedTrait::ONE();
            count -= 1;
        };
        total.to_decimal(18)
    }
}
