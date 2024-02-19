use cubit::f128::types::fixed::{FixedTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};
use starknet::{ContractAddress, get_block_timestamp};

use risingrevenant::components::game::{GameSetup, GameOutpostsTracker};
use risingrevenant::components::reinforcement::ReinforcementBalance;

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::player::{PlayerActionsTrait};

const target_price: u128 = 10;
const decay_constant: u128 = 571849066284996100; // 0.031
const max_sellable: u128 = 1000000000;

#[generate_trait]
impl ReinforcementActionImpl of ReinforcementActionTrait {
    fn get_reinforcement_price(self: @GameAction, count: u32) -> u128 {
        let balance_info: ReinforcementBalance = self.get(self.game_id);

        let time_since_start: u128 = get_block_timestamp().into()
            - balance_info.start_timestamp.into();

        let vrgda = LogisticVRGDA {
            target_price: FixedTrait::new_unscaled(balance_info.target_price, false),
            decay_constant: FixedTrait::new(decay_constant, false),
            max_sellable: FixedTrait::new_unscaled(max_sellable, false),
            time_scale: FixedTrait::new(decay_constant, false),
        };

        let time = FixedTrait::new_unscaled(time_since_start / 60, false);
        let mut total_price = 0_u128;
        let mut p = 0_u32;
        loop {
            if p == count {
                break;
            }
            let price = vrgda
                .get_vrgda_price(
                    time, FixedTrait::new_unscaled((balance_info.count + p).into(), false)
                );
            total_price += price.try_into().unwrap();
            p += 1;
        };

        total_price
    }
    fn update_renforcements<T, +Into<T, i64>, +Copy<T>, +Drop<T>>(
        self: @GameAction, player_id: ContractAddress, count: T
    ) {
        let mut player_info = self.get_player(player_id);
        let new_reinforcements_count: i64 = player_info.reinforcements_available_count.into()
            + count.into();
        assert(0 <= new_reinforcements_count, 'Not enough renformecments');
        player_info.reinforcements_available_count = new_reinforcements_count.try_into().unwrap();
        self.set(player_info);
    }
    fn purchase_reinforcement(self: @GameAction, player_id: ContractAddress, count: u32) {
        let cost = self.get_reinforcement_price(count);
        let game_setup: GameSetup = self.get(self.game_id);

        self.transfer(player_id, game_setup.pot_pool_addr, cost);
        self.update_renforcements(player_id, count);

        let mut outposts_tracker: GameOutpostsTracker = self.get(self.game_id);
        outposts_tracker.reinforcement_count += count;
        self.increase_pot(cost);
        self.set(outposts_tracker);
    }
}
