use dojo::world::{IWorldDispatcher};

use super::Rarity;
use rising_revenant::{
    fortifications::models::Fortifications, core::ToNonZero, utils::felt252_to_u128,
    care_packages::models::{CarePackageMarket, CarePackageMarketStore}, vrgda::{LogisticVRGDA, VRGDATrait},
    fixed::FixedToDecimal
};
use core::integer::u128_safe_divmod;
// use origami_defi::auction::vrgda::{LogisticVRGDA, VRGDATrait};
use cubit::f128::types::fixed::{Fixed, FixedTrait};

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

fn get_range_of_fortifications(rarity: Rarity) -> (u128, u128) {
    match rarity {
        Rarity::None => { panic!("Rarity not set") },
        Rarity::Common => (8, 1),
        Rarity::Rare => (10, 3),
        Rarity::Epic => (12, 4),
        Rarity::Legendary => (15, 6),
    }
}

fn get_fortifications(rarity: Rarity, randomness: felt252) -> Fortifications {
    let randomness = felt252_to_u128(randomness);
    let (base, divmod) = get_range_of_fortifications(rarity);
    let (randomness, value) = u128_safe_divmod(randomness, divmod.non_zero());
    get_fortifications_types(base + value, randomness)

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

#[generate_trait]
impl CarePackageMarketImpl of CarePackageMarketTrait {
    fn get_care_package_market(self: @IWorldDispatcher, game_id: felt252) -> CarePackageMarket {
        CarePackageMarketStore::get(*self, game_id)
    }
    fn to_logistic_vrgda(self: @CarePackageMarket) -> LogisticVRGDA {
        LogisticVRGDA {
            target_price: (*self.target_price).decimal_to_fixed(18),
            decay_constant: FixedTrait::new(*self.decay_constant_mag, false),
            max_sellable: FixedTrait::new(*self.max_sellable_mag, false),
            time_scale: FixedTrait::new(*self.time_scale_mag, false),
        }
    }
    fn get_price(self: @CarePackageMarket, time: u64) -> u256 {
        self.to_logistic_vrgda().get_vrgda_price(time.into(), (*self.sold).into()).to_decimal(18)
    }
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
