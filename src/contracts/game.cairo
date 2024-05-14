use risingrevenant::systems::get_set::SetTrait;
use risingrevenant::{
    components::{
        currency::CurrencyTrait,
        game::{
            CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
            GamePhases, Dimensions
        },
        reinforcement::{ReinforcementMarketConsts}, outpost::{OutpostMarket, OutpostSetup},
        world_event::{WorldEventSetup},
    }
};
#[starknet::interface]
trait IGameActions<TContractState> {
    fn set_defaults(self: @TContractState);
    fn create(self: @TContractState, start_block: u64, preparation_blocks: u64) -> u128;
    fn set_game_map(self: @TContractState, game_map: GameMap);
    fn set_game_pot_consts(self: @TContractState, game_pot_consts: GamePotConsts);
    fn set_game_trade_tax(self: @TContractState, game_trade_tax: GameTradeTax);
    fn set_outpost_market(self: @TContractState, outpost_market: OutpostMarket);
    fn set_game_state(self: @TContractState, game_state: GameState);
    fn set_game_phases(self: @TContractState, game_phases: GamePhases);
    fn set_outpost_setup(self: @TContractState, outpost_setup: OutpostSetup);
    fn set_world_event_setup(self: @TContractState, world_event_setup: WorldEventSetup);
    fn set_reinforcement_market(
        self: @TContractState, reinforcement_market: ReinforcementMarketConsts
    );
}

#[dojo::contract]
mod game_actions {
    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};

    use risingrevenant::{
        components::{
            currency::CurrencyTrait,
            game::{
                GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot, GamePhases,
                Dimensions
            },
            reinforcement::{ReinforcementMarketConsts}, outpost::{OutpostMarket, OutpostSetup},
            world_event::{WorldEventSetup},
        },
        systems::{get_set::SetTrait, game::{GameAction, GameActionTrait}},
    };


    use super::IGameActions;

    #[abi(embed_v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn set_defaults(self: @ContractState) {
            GameActionTrait::set_defaults(self.world_dispatcher.read());
        }
        fn create(self: @ContractState, start_block: u64, preparation_blocks: u64) -> u128 {
            let world = self.world_dispatcher.read();
            world.new_game(start_block, preparation_blocks)
        }

        fn set_game_map(self: @ContractState, game_map: GameMap) {
            self.update_settings(game_map.game_id, game_map);
        }
        fn set_game_pot_consts(self: @ContractState, game_pot_consts: GamePotConsts) {
            self.update_settings(game_pot_consts.game_id, game_pot_consts);
        }
        fn set_game_trade_tax(self: @ContractState, game_trade_tax: GameTradeTax) {
            self.update_settings(game_trade_tax.game_id, game_trade_tax);
        }
        fn set_outpost_market(self: @ContractState, outpost_market: OutpostMarket) {
            self.update_settings(outpost_market.game_id, outpost_market);
        }
        fn set_game_state(self: @ContractState, game_state: GameState) {
            self.update_settings(game_state.game_id, game_state);
        }
        fn set_game_phases(self: @ContractState, game_phases: GamePhases) {
            self.update_settings(game_phases.game_id, game_phases);
        }
        fn set_outpost_setup(self: @ContractState, outpost_setup: OutpostSetup) {
            self.update_settings(outpost_setup.game_id, outpost_setup);
        }
        fn set_world_event_setup(self: @ContractState, world_event_setup: WorldEventSetup) {
            self.update_settings(world_event_setup.game_id, world_event_setup);
        }
        fn set_reinforcement_market(
            self: @ContractState, reinforcement_market: ReinforcementMarketConsts
        ) {
            self.update_settings(reinforcement_market.game_id, reinforcement_market);
        }
    }

    #[generate_trait]
    impl SetSettingsImpl of SetSettingsTrait {
        fn update_settings<T, +SetTrait<T>, +Drop<T>>(
            self: @ContractState, game_id: u128, settings: T
        ) {
            let world = self.world_dispatcher.read();
            let caller_id = get_caller_address();
            let game_action = GameAction { world, game_id };
            game_action.assert_not_started();
            game_action.assert_is_admin(caller_id);
            game_action.set(settings);
        }
    }
}
