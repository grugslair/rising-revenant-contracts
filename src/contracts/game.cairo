use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


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
    fn set_defaults(self: @TContractState, world: IWorldDispatcher,);
    fn create(
        self: @TContractState, world: IWorldDispatcher, start_block: u64, preparation_blocks: u64
    ) -> u128;
    fn set_game_map(self: @TContractState, world: IWorldDispatcher, game_map: GameMap);
    fn set_game_pot_consts(
        self: @TContractState, world: IWorldDispatcher, game_pot_consts: GamePotConsts
    );
    fn set_game_trade_tax(
        self: @TContractState, world: IWorldDispatcher, game_trade_tax: GameTradeTax
    );
    fn set_outpost_market(
        self: @TContractState, world: IWorldDispatcher, outpost_market: OutpostMarket
    );
    fn set_game_state(self: @TContractState, world: IWorldDispatcher, game_state: GameState);
    fn set_game_phases(self: @TContractState, world: IWorldDispatcher, game_phases: GamePhases);
    fn set_outpost_setup(
        self: @TContractState, world: IWorldDispatcher, outpost_setup: OutpostSetup
    );
    fn set_world_event_setup(
        self: @TContractState, world: IWorldDispatcher, world_event_setup: WorldEventSetup
    );
    fn set_reinforcement_market(
        self: @TContractState,
        world: IWorldDispatcher,
        reinforcement_market: ReinforcementMarketConsts
    );
}

#[starknet::contract]
mod game_actions {
    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


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

    #[storage]
    struct Storage {}
    use super::IGameActions;

    #[generate_trait]
    impl SetSettingsImpl of SetSettingsTrait {
        fn update_settings<T, +SetTrait<T>, +Drop<T>>(
            self: IWorldDispatcher, game_id: u128, settings: T
        ) {
            let caller_id = get_caller_address();
            let game_action = GameAction { world: self, game_id };
            game_action.assert_not_started();
            game_action.assert_is_admin(caller_id);
            game_action.set(settings);
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, world: IWorldDispatcher) {
        GameActionTrait::set_defaults(world);
    }

    #[abi(embed_v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn set_defaults(self: @ContractState, world: IWorldDispatcher) {
            GameActionTrait::set_defaults(world);
        }
        fn create(
            self: @ContractState, world: IWorldDispatcher, start_block: u64, preparation_blocks: u64
        ) -> u128 {
            world.new_game(start_block, preparation_blocks)
        }

        fn set_game_map(self: @ContractState, world: IWorldDispatcher, game_map: GameMap) {
            world.update_settings(game_map.game_id, game_map);
        }
        fn set_game_pot_consts(
            self: @ContractState, world: IWorldDispatcher, game_pot_consts: GamePotConsts
        ) {
            world.update_settings(game_pot_consts.game_id, game_pot_consts);
        }
        fn set_game_trade_tax(
            self: @ContractState, world: IWorldDispatcher, game_trade_tax: GameTradeTax
        ) {
            world.update_settings(game_trade_tax.game_id, game_trade_tax);
        }
        fn set_outpost_market(
            self: @ContractState, world: IWorldDispatcher, outpost_market: OutpostMarket
        ) {
            world.update_settings(outpost_market.game_id, outpost_market);
        }
        fn set_game_state(self: @ContractState, world: IWorldDispatcher, game_state: GameState) {
            world.update_settings(game_state.game_id, game_state);
        }
        fn set_game_phases(self: @ContractState, world: IWorldDispatcher, game_phases: GamePhases) {
            world.update_settings(game_phases.game_id, game_phases);
        }
        fn set_outpost_setup(
            self: @ContractState, world: IWorldDispatcher, outpost_setup: OutpostSetup
        ) {
            world.update_settings(outpost_setup.game_id, outpost_setup);
        }
        fn set_world_event_setup(
            self: @ContractState, world: IWorldDispatcher, world_event_setup: WorldEventSetup
        ) {
            world.update_settings(world_event_setup.game_id, world_event_setup);
        }
        fn set_reinforcement_market(
            self: @ContractState,
            world: IWorldDispatcher,
            reinforcement_market: ReinforcementMarketConsts
        ) {
            world.update_settings(reinforcement_market.game_id, reinforcement_market);
        }
    }
}
