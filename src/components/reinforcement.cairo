use cubit::f128::types::fixed::{Fixed, FixedTrait};
use cubit::f128::math::ops::{ln, abs, exp};
use starknet::{ContractAddress, get_block_timestamp};
use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};

use risingrevenant::components::currency::{CurrencyTrait};


use risingrevenant::utils::get_block_number;

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementMarket {
    #[key]
    game_id: u128,
    target_price: Fixed,
    start_block_number: u64,
    decay_constant: Fixed,
    units_per_time: Fixed,
}
// #[generate_trait]
// impl ReinforcementMarketImpl of ReinforcementMarketTrait {
//     fn get_reinforcement_price(self: ReinforcementMarket, count: u32) -> u128 {
//         let time_since_start: u128 = (get_block_number() - self.start_block_number).into();

//         let vrgda = LogisticVRGDA {
//             target_price: FixedTrait::new_unscaled(self.target_price, false),
//             decay_constant: FixedTrait::new(self.decay_constant, false),
//             max_sellable: FixedTrait::new_unscaled(self.max_sellable.into(), false),
//             time_scale: FixedTrait::new(self.time_scale, false),
//         };

//         let time = FixedTrait::new_unscaled(time_since_start, false);
//         let mut total_price = 0_u128;
//         let mut p = 0_u32;
//         loop {
//             if p == count {
//                 break;
//             }
//             let price = vrgda
//                 .get_vrgda_price(time, FixedTrait::new_unscaled((self.count + p).into(), false));
//             total_price += price.try_into().unwrap();
//             p += 1;
//         };
//         total_price
//     }
// }

#[generate_trait]
impl ReinforcementMarketImpl of ReinforcementMarketTrait {
    fn get_reinforcement_price(self: ReinforcementMarket, sold: u32, count: u32) -> u128 {
        let blocks_since_start = FixedTrait::new_unscaled(
            (get_block_number() - self.start_block_number).into(), false
        );
        

        let mut total_price = 0_u128;
        let mut p = 0_u32;
        loop {
            if p == count {
                break;
            }
            let price = vrgda
                .get_vrgda_price(time, FixedTrait::new_unscaled((self.count + p).into(), false));
            total_price += price.try_into().unwrap();
            p += 1;
        };
        total_price
    }

    fn _get_price(self: @ReinforcementMarket, time_since_start: Fixed, sold: Fixed) -> Fixed {
        *self.target_price
            * exp(
                *self.decay_constant
                    * (self.get_target_sale_time(sold + FixedTrait::new(1, false))
                        - time_since_start)
            )
    }
    fn get_price(self: @ReinforcementMarket , sold: Fixed) -> Fixed {

    }

    fn get_target_sale_time(self: @ReinforcementMarket, sold: Fixed) -> Fixed {
        sold / *self.units_per_time
    }
}

