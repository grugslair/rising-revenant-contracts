use cubit::f128::types::fixed::{Fixed, FixedTrait, HALF_u128};
use cubit::f128::math::ops::{ln, abs, exp};
use starknet::{ContractAddress, get_block_timestamp};

// use risingrevenant::utils::vrgda::{LogisticVRGDA, VRGDATrait};
use origami::defi::auction::vrgda::{LogisticVRGDA, VRGDATrait}; // use when VRGDA fix is merged

use risingrevenant::components::currency::{CurrencyTrait};


use risingrevenant::utils::get_block_number;


#[dojo::model]
#[derive(Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementMarketConsts {
    #[key]
    game_id: u128,
    target_price: u128,
    decay_constant_mag: u128,
    max_sellable_percentage: u32,
    time_scale_mag_factor: u128,
}
#[derive(Copy, Drop, Print)]
struct ReinforcementMarket {
    game_id: u128,
    target_price: u128,
    decay_constant_mag: u128,
    max_sellable: u32,
    time_scale_mag: u128,
    blocks: u64,
    sold: u32,
}

#[generate_trait]
impl ReinforcementMarketImpl of ReinforcementMarketTrait {
    fn get_price<T, +CurrencyTrait<Fixed, T>>(self: ReinforcementMarket, count: u32) -> T {
        let blocks_since_start = FixedTrait::new_unscaled(self.blocks.into(), false)
            + Fixed { mag: HALF_u128, sign: false };
        let auction = LogisticVRGDA {
            target_price: self.target_price.convert(),
            decay_constant: FixedTrait::new(self.decay_constant_mag, false),
            max_sellable: FixedTrait::new_unscaled(self.max_sellable.into(), false),
            time_scale: FixedTrait::new(self.time_scale_mag, false),
        };

        let mut total_price = FixedTrait::ZERO();
        let mut p = 0_u32;
        loop {
            if p >= count {
                break;
            }
            total_price += auction
                .get_vrgda_price(
                    blocks_since_start, FixedTrait::new_unscaled((self.sold + p).into(), false)
                );
            p += 1;
        };
        total_price.convert()
    }
}


// This enum simply defines the states of a game.
#[derive(Serde, Copy, Drop, Introspect, PartialEq, Print)]
enum ReinforcementType {
    None,
    Wall,
    Trench,
    Bunker,
}

// We define an into trait
impl ReinforcementTypeFelt252 of Into<ReinforcementType, felt252> {
    fn into(self: ReinforcementType) -> felt252 {
        match self {
            ReinforcementType::None => 0,
            ReinforcementType::Wall => 1,
            ReinforcementType::Trench => 2,
            ReinforcementType::Bunker => 3,
        }
    }
}

