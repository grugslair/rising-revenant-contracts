use risingrevenant::components::game::GamePhasesTrait;
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use cubit::f128::types::fixed::{FixedTrait};

use risingrevenant::components::game::{GameState, GamePhases};
use risingrevenant::components::outpost::{OutpostMarket, OutpostSetup};
use risingrevenant::components::reinforcement::{
    ReinforcementMarket, ReinforcementMarketConsts, ReinforcementMarketTrait
};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::player::{PlayerActionsTrait};
use risingrevenant::systems::payment::{PaymentSystemTrait};

use risingrevenant::utils::get_block_number;

#[generate_trait]
impl ReinforcementActionImpl of ReinforcementActionTrait {
    fn get_reinforcement_market(self: GameAction) -> ReinforcementMarket {
        let consts: ReinforcementMarketConsts = self.get_game();
        let state: GameState = self.get_game();
        let phases: GamePhases = self.get_game();
        let outpost_market: OutpostMarket = self.get_game();
        let outpost_setup: OutpostSetup = self.get_game();
        ReinforcementMarket {
            game_id: self.game_id,
            target_price: consts.target_price,
            decay_constant_mag: consts.decay_constant_mag,
            blocks: phases.preparation_block_number - get_block_number(),
            max_sellable: consts.max_sellable_percentage
                * outpost_market.max_sellable
                * outpost_setup.max_reinforcements
                / 100,
            time_scale_mag: consts.time_scale_mag_factor * phases.get_preparation_blocks(),
            sold: state.reinforcement_count,
        }
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
    fn purchase_reinforcements(self: GameAction, player_id: ContractAddress, count: u32) {
        self.assert_preparing();

        let cost = self.get_reinforcements_price(count);

        let payment_system = PaymentSystemTrait::new(self);
        payment_system.pay_into_pot(player_id, cost);

        self.update_reinforcements(player_id, count);

        let mut outposts_tracker: GameState = self.get_game();
        outposts_tracker.reinforcement_count += count;

        self.set(outposts_tracker);
    }
    fn get_reinforcements_price(self: GameAction, count: u32) -> u128 {
        assert(count > 0, 'Count must be more than 0');
        self.assert_preparing();
        let market = self.get_reinforcement_market();
        market.get_price(count)
    }
}

