use cubit::f128::types::fixed::{Fixed, FixedTrait};
use starknet::{ContractAddress, get_block_timestamp};
use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};

use risingrevenant::utils::get_block_number;

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementMarket {
    #[key]
    game_id: u128,
    target_price: u128,
    start_block_number: u64,
    decay_constant: u128,
    max_sellable: u32,
    count: u32,
}

#[generate_trait]
impl ReinforcementMarketImpl of ReinforcementMarketTrait {
    fn get_reinforcement_price(self: ReinforcementMarket, count: u32) -> u128 {
        let time_since_start: u128 = (get_block_number() - self.start_block_number).into();

        let vrgda = LogisticVRGDA {
            target_price: FixedTrait::new_unscaled(self.target_price, false),
            decay_constant: FixedTrait::new(self.decay_constant, false),
            max_sellable: FixedTrait::new_unscaled(self.max_sellable.into(), false),
            time_scale: FixedTrait::new(self.decay_constant, false),
        };

        let time = FixedTrait::new_unscaled(time_since_start / 60, false);
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
}

