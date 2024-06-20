use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::{
    components::{
        currency::CurrencyTrait,
        game::{
            CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
            GamePhases, Dimensions, GameERC20
        },
        reinforcement::{ReinforcementMarketConsts}, outpost::{OutpostMarket, OutpostSetup},
        world_event::{WorldEventSetup},
    }
};

#[dojo::interface]
trait IGameActions {
    fn set_defaults(ref world: IWorldDispatcher,);
    fn create(ref world: IWorldDispatcher, start_block: u64, preparation_blocks: u64) -> u128;
    fn set_game_map(ref world: IWorldDispatcher, game_map: GameMap);
    fn set_game_pot_consts(ref world: IWorldDispatcher, game_pot_consts: GamePotConsts);
    fn set_game_erc20(ref world: IWorldDispatcher, game_id: u128, address: ContractAddress);
    fn set_game_trade_tax(ref world: IWorldDispatcher, game_trade_tax: GameTradeTax);
    fn set_outpost_market(ref world: IWorldDispatcher, outpost_market: OutpostMarket);
    fn set_game_state(ref world: IWorldDispatcher, game_state: GameState);
    fn set_game_phases(ref world: IWorldDispatcher, game_phases: GamePhases);
    fn set_outpost_setup(ref world: IWorldDispatcher, outpost_setup: OutpostSetup);
    fn set_world_event_setup(ref world: IWorldDispatcher, world_event_setup: WorldEventSetup);
    fn set_reinforcement_market(
        ref world: IWorldDispatcher, reinforcement_market: ReinforcementMarketConsts
    );
}

#[dojo::contract]
mod game_actions {
    use core::hash::HashStateTrait;
    use cubit::f128::types::fixed::{FixedTrait, ONE_u128};

    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};

    use risingrevenant::{
        components::{
            currency::CurrencyTrait,
            game::{
                CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
                GamePhases, Dimensions, GameERC20
            },
            reinforcement::{ReinforcementMarketConsts}, outpost::{OutpostMarket, OutpostSetup},
            world_event::{WorldEventSetup},
        },
        systems::{get_set::SetTrait, game::{GameAction, GameActionTrait}},
    };
    use super::IGameActions;


    #[abi(embed_v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn set_defaults(ref world: IWorldDispatcher) {
            let caller_id = get_caller_address();
            world.assert_is_admin(caller_id);
            GameActionTrait::set_defaults(world);
        }
        fn create(ref world: IWorldDispatcher, start_block: u64, preparation_blocks: u64) -> u128 {
            let caller_id = get_caller_address();
            let game_id: u128 = world.get_uuid();
            let game_action = GameAction { world, game_id };
            world.assert_is_admin(caller_id);
            let mut current_game: CurrentGame = game_action.get(caller_id);
            let _last_game_id = current_game.game_id;
            current_game.game_id = game_id;

            let current_block = get_block_info().unbox().block_number;
            let mut game_map: GameMap = get!(world, 0, GameMap);
            let mut game_pot_consts: GamePotConsts = get!(world, 0, GamePotConsts);
            let mut game_erc20: GameERC20 = get!(world, 0, GameERC20);
            let mut game_trade_tax: GameTradeTax = get!(world, 0, GameTradeTax);
            let mut outpost_market: OutpostMarket = get!(world, 0, OutpostMarket);
            let mut outpost_setup: OutpostSetup = get!(world, 0, OutpostSetup);
            let mut world_event_setup: WorldEventSetup = get!(world, 0, WorldEventSetup);
            let mut reinforcement_market: ReinforcementMarketConsts = get!(
                world, 0, ReinforcementMarketConsts
            );
            game_map.game_id = game_id;
            game_pot_consts.game_id = game_id;
            game_trade_tax.game_id = game_id;
            outpost_market.game_id = game_id;
            outpost_setup.game_id = game_id;
            world_event_setup.game_id = game_id;
            reinforcement_market.game_id = game_id;

            let game_phases = GamePhases {
                game_id,
                status: GameStatus::created,
                preparation_block_number: current_block,
                play_block_number: current_block + preparation_blocks,
            };

            game_action.set(current_game);
            game_action.set(game_map);
            game_action.set(game_pot_consts);
            game_action.set(game_erc20);
            game_action.set(world_event_setup);
            game_action.set(outpost_market);
            game_action.set(game_trade_tax);
            game_action.set(game_phases);
            game_action.set(outpost_setup);
            game_action.set(reinforcement_market);
            game_id
        }
        fn set_game_erc20(ref world: IWorldDispatcher, game_id: u128, address: ContractAddress) {
            world.update_settings(game_id, GameERC20 { game_id, address });
        }
        fn set_game_map(ref world: IWorldDispatcher, game_map: GameMap) {
            world.update_settings(game_map.game_id, game_map);
        }
        fn set_game_pot_consts(ref world: IWorldDispatcher, game_pot_consts: GamePotConsts) {
            world.update_settings(game_pot_consts.game_id, game_pot_consts);
        }
        fn set_game_trade_tax(ref world: IWorldDispatcher, game_trade_tax: GameTradeTax) {
            world.update_settings(game_trade_tax.game_id, game_trade_tax);
        }
        fn set_outpost_market(ref world: IWorldDispatcher, outpost_market: OutpostMarket) {
            world.update_settings(outpost_market.game_id, outpost_market);
        }
        fn set_game_state(ref world: IWorldDispatcher, game_state: GameState) {
            world.update_settings(game_state.game_id, game_state);
        }
        fn set_game_phases(ref world: IWorldDispatcher, game_phases: GamePhases) {
            world.update_settings(game_phases.game_id, game_phases);
        }
        fn set_outpost_setup(ref world: IWorldDispatcher, outpost_setup: OutpostSetup) {
            world.update_settings(outpost_setup.game_id, outpost_setup);
        }
        fn set_world_event_setup(ref world: IWorldDispatcher, world_event_setup: WorldEventSetup) {
            world.update_settings(world_event_setup.game_id, world_event_setup);
        }
        fn set_reinforcement_market(
            ref world: IWorldDispatcher, reinforcement_market: ReinforcementMarketConsts
        ) {
            world.update_settings(reinforcement_market.game_id, reinforcement_market);
        }
    }

    #[generate_trait]
    impl SetSettingsImpl of SetSettingsTrait {
        fn update_settings<T, +SetTrait<T>, +Drop<T>>(
            self: IWorldDispatcher, game_id: u128, settings: T
        ) {
            let caller_id = get_caller_address();
            let game_action = GameAction { world: self, game_id };
            if game_id.is_non_zero() {
                game_action.assert_not_started();
            }
            self.assert_is_admin(caller_id);
            game_action.set(settings);
        }
    }
}
