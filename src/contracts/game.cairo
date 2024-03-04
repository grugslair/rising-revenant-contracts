#[starknet::interface]
trait IGameActions<TContractState> {
    fn create(self: @TContractState, start_block: u64, preparation_blocks: u64) -> u128;
}

#[dojo::contract]
mod game_actions {
    use debug::PrintTrait;

    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};

    use risingrevenant::components::game::{
        CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
        GamePhases, Dimensions
    };
    use risingrevenant::components::reinforcement::{ReinforcementMarket};
    use risingrevenant::components::outpost::{OutpostMarket, OutpostSetup};
    use risingrevenant::components::world_event::{WorldEventSetup};

    use risingrevenant::systems::game::{uuid, GameAction, GameActionTrait};

    use risingrevenant::defaults::{
        MAP_WIDTH, MAP_HEIGHT, DEV_PERCENT, CONFIRMATION_PERCENT, LTR_PERCENT,
        GAME_TRADE_TAX_PERCENT, EVENT_RADIUS_START, EVENT_RADIUS_INCREASE, OUTPOST_PRICE,
        MAX_OUTPOSTS, OUTPOST_INIT_LIFE, OUTPOST_MAX_REINFORCEMENT, REINFORCEMENT_TARGET_PRICE,
        REINFORCEMENT_MAX_SELLABLE, REINFORCEMENT_DECAY_CONSTANT
    };


    use super::IGameActions;

    #[external(v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn create(self: @ContractState, start_block: u64, preparation_blocks: u64) -> u128 {
            let world = self.world_dispatcher.read();
            let caller_id = get_caller_address();
            let game_id = uuid(world);
            let game_action = GameAction { world, game_id };
            let mut current_game: CurrentGame = game_action.get(caller_id);
            let last_game_id = current_game.game_id;
            current_game.game_id = game_id;

            let game_map = GameMap {
                game_id, dimensions: Dimensions { x: MAP_WIDTH, y: MAP_HEIGHT },
            };
            let game_pot_consts = GamePotConsts {
                game_id,
                pot_address: caller_id,
                dev_percent: DEV_PERCENT,
                confirmation_percent: CONFIRMATION_PERCENT,
                ltr_percent: LTR_PERCENT,
            };

            let game_trade_tax = GameTradeTax {
                game_id, trade_tax_percent: GAME_TRADE_TAX_PERCENT,
            };

            let outpost_market = OutpostMarket {
                game_id, price: OUTPOST_PRICE, available: MAX_OUTPOSTS,
            };

            let world_event_setup = WorldEventSetup {
                game_id, radius_start: EVENT_RADIUS_START, radius_increase: EVENT_RADIUS_INCREASE
            };

            let game_state = GameState {
                game_id,
                outpost_created_count: 0,
                outpost_remaining_count: 0,
                remain_life_count: 0,
                reinforcement_count: 0,
                contribution_score_total: 0,
            };

            let game_phases = GamePhases {
                game_id,
                status: GameStatus::created,
                preparation_block_number: start_block,
                play_block_number: start_block + preparation_blocks,
            };

            //we need this so the outpost dont start with 0 life
            let outpost_setup = OutpostSetup {
                game_id, life: OUTPOST_INIT_LIFE, max_reinforcements: OUTPOST_MAX_REINFORCEMENT,
            };

            let world_event_setup = WorldEventSetup {
                game_id, radius_start: EVENT_RADIUS_START, radius_increase: EVENT_RADIUS_INCREASE,
            };

            let reinforcement_market = ReinforcementMarket {
                game_id,
                target_price: REINFORCEMENT_TARGET_PRICE,
                start_block_number: start_block,
                decay_constant: REINFORCEMENT_DECAY_CONSTANT,
                max_sellable: REINFORCEMENT_MAX_SELLABLE,
                count: 0,
            };

            game_action.set(current_game);
            game_action.set(game_map);
            game_action.set(game_pot_consts);
            game_action.set(world_event_setup);
            game_action.set(outpost_market);
            game_action.set(game_trade_tax);
            game_action.set(game_phases);
            game_action.set(game_state);
            game_action.set(outpost_setup);
            game_action.set(world_event_setup);
            game_action.set(reinforcement_market);

            game_id
        }
    }
}
