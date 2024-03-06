use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use cubit::f128::types::fixed::{FixedTrait};

use risingrevenant::components::game::{GameState};
use risingrevenant::components::reinforcement::{ReinforcementMarket, ReinforcementMarketTrait};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::player::{PlayerActionsTrait};
use risingrevenant::systems::payment::{PaymentSystemTrait};

use risingrevenant::utils::get_block_number;

#[generate_trait]
impl ReinforcementActionImpl of ReinforcementActionTrait {
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
    fn purchase_reinforcements(self: GameAction, player_id: ContractAddress, count: u32) {
        self.assert_preparing();
        let mut market: ReinforcementMarket = self.get_game();
        let cost: u128 = market.get_price(count);
        market.sold += count;

        let payment_system = PaymentSystemTrait::new(self);
        payment_system.pay_into_pot(player_id, cost);

        self.update_reinforcements(player_id, count);

        let mut outposts_tracker: GameState = self.get_game();
        outposts_tracker.reinforcement_count += count;

        self.set(outposts_tracker);
        self.set(market);
    }
    fn get_reinforcements_price(self: GameAction, count: u32) -> u128 {
        self.assert_preparing();
        let market: ReinforcementMarket = self.get_game();
        market.get_price(count)
    }
}

