use starknet::{ContractAddress, get_block_timestamp};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use cubit::f128::types::fixed::{FixedTrait};
use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};

use risingrevenant::components::game::{GameState};
use risingrevenant::components::reinforcement::ReinforcementMarket;

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::player::{PlayerActionsTrait};
use risingrevenant::systems::payment::{PaymentSystemTrait};


#[generate_trait]
impl ReinforcementActionImpl of ReinforcementActionTrait {
    fn get_reinforcement_price(self: GameAction, count: u32) -> u128 {
        let market: ReinforcementMarket = self.get_game();

        let time_since_start: u128 = get_block_timestamp().into() - market.start_timestamp.into();

        let vrgda = LogisticVRGDA {
            target_price: FixedTrait::new_unscaled(market.target_price, false),
            decay_constant: FixedTrait::new(market.decay_constant, false),
            max_sellable: FixedTrait::new_unscaled(market.max_sellable.into(), false),
            time_scale: FixedTrait::new(market.decay_constant, false),
        };

        let time = FixedTrait::new_unscaled(time_since_start / 60, false);
        let mut total_price = 0_u128;
        let mut p = 0_u32;
        loop {
            if p == count {
                break;
            }
            let price = vrgda
                .get_vrgda_price(time, FixedTrait::new_unscaled((market.count + p).into(), false));
            total_price += price.try_into().unwrap();
            p += 1;
        };

        total_price
    }
    fn update_reinforcements<T, +Into<T, i64>, +Copy<T>, +Drop<T>>(
        self: GameAction, player_id: ContractAddress, count: T
    ) {
        let mut player_info = self.get_player(player_id);
        let new_reinforcements_count: i64 = player_info.reinforcements_available_count.into()
            + count.into();
        assert(0 <= new_reinforcements_count, 'Not enough reinforcements');
        player_info.reinforcements_available_count = new_reinforcements_count.try_into().unwrap();
        self.set(player_info);
    }
    fn purchase_reinforcement(self: GameAction, player_id: ContractAddress, count: u32) {
        self.assert_preparing();
        let cost = self.get_reinforcement_price(count);

        let payment_system = PaymentSystemTrait::new(self);
        payment_system.pay_into_pot(player_id, cost);

        self.update_reinforcements(player_id, count);

        let mut outposts_tracker: GameState = self.get_game();
        outposts_tracker.reinforcement_count += count;
        self.set(outposts_tracker);
    }
}

