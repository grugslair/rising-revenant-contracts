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
    use cubit::f128::types::fixed::{FixedTrait, ONE_u128};

    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};
    use risingrevenant::{
        components::{
            currency::CurrencyTrait,
            game::{
                CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
                GamePhases, Dimensions
            },
            reinforcement::{ReinforcementMarketConsts}, outpost::{OutpostMarket, OutpostSetup},
            world_event::{WorldEventSetup},
        },
        systems::{get_set::SetTrait, game::{uuid, GameAction, GameActionTrait}},
        defaults::{
            MAP_WIDTH, MAP_HEIGHT, DEV_PERCENT, CONFIRMATION_PERCENT, LTR_PERCENT,
            GAME_TRADE_TAX_PERCENT, EVENT_RADIUS_START, EVENT_RADIUS_INCREASE, OUTPOST_PRICE,
            MAX_OUTPOSTS, OUTPOST_INIT_LIFE, OUTPOST_MAX_REINFORCEMENT, REINFORCEMENT_TARGET_PRICE,
            REINFORCEMENT_MAX_SELLABLE_PERCENTAGE, REINFORCEMENT_DECAY_CONSTANT_MAG,
            REINFORCEMENT_TIME_SCALE_FACTOR_MAG, MAX_OUTPOSTS_PER_PLAYER
        }
    };


    use super::IGameActions;
    #[constructor]
    fn constructor(ref self: ContractState) {
        let game_id: u128 = 0;
        let game_map = GameMap { game_id, dimensions: Dimensions { x: MAP_WIDTH, y: MAP_HEIGHT }, };
        let game_pot_consts = GamePotConsts {
            game_id,
            pot_address: get_caller_address(),
            dev_percent: DEV_PERCENT,
            confirmation_percent: CONFIRMATION_PERCENT,
            ltr_percent: LTR_PERCENT,
        };

        let game_trade_tax = GameTradeTax { game_id, trade_tax_percent: GAME_TRADE_TAX_PERCENT, };

        let outpost_market = OutpostMarket {
            game_id,
            price: OUTPOST_PRICE,
            max_sellable: MAX_OUTPOSTS,
            max_per_player: MAX_OUTPOSTS_PER_PLAYER
        };
        let outpost_setup = OutpostSetup {
            game_id, life: OUTPOST_INIT_LIFE, max_reinforcements: OUTPOST_MAX_REINFORCEMENT,
        };

        let world_event_setup = WorldEventSetup {
            game_id, radius_start: EVENT_RADIUS_START, radius_increase: EVENT_RADIUS_INCREASE,
        };

        let reinforcement_market = ReinforcementMarketConsts {
            game_id,
            target_price: REINFORCEMENT_TARGET_PRICE.convert(),
            decay_constant_mag: REINFORCEMENT_DECAY_CONSTANT_MAG,
            max_sellable_percentage: REINFORCEMENT_MAX_SELLABLE_PERCENTAGE,
            time_scale_mag_factor: REINFORCEMENT_TIME_SCALE_FACTOR_MAG,
        };
        let world = self.world_dispatcher.read();
        set!(
            world,
            (
                game_map,
                game_pot_consts,
                world_event_setup,
                outpost_market,
                game_trade_tax,
                outpost_setup,
                reinforcement_market
            )
        );
    }

    #[abi(embed_v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn create(self: @ContractState, start_block: u64, preparation_blocks: u64) -> u128 {
            let world = self.world_dispatcher.read();
            let caller_id = get_caller_address();
            let game_id: u128 = uuid(world);
            let game_action = GameAction { world, game_id };
            game_action.assert_is_admin(caller_id);
            let mut current_game: CurrentGame = game_action.get(caller_id);
            let _last_game_id = current_game.game_id;
            current_game.game_id = game_id;

            let current_block = get_block_info().unbox().block_number;

            let mut game_map: GameMap = get!(world, 0, GameMap);
            let mut game_pot_consts: GamePotConsts = get!(world, 0, GamePotConsts);
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

            game_pot_consts.pot_address = caller_id;

            let game_phases = GamePhases {
                game_id,
                status: GameStatus::created,
                preparation_block_number: current_block,
                play_block_number: current_block + preparation_blocks,
            };

            game_action.set(current_game);
            game_action.set(game_map);
            game_action.set(game_pot_consts);
            game_action.set(world_event_setup);
            game_action.set(outpost_market);
            game_action.set(game_trade_tax);
            game_action.set(game_phases);
            game_action.set(outpost_setup);
            game_action.set(reinforcement_market);

            game_id
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
