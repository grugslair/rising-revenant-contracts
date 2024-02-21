#[starknet::interface]
trait IGameActions<TContractState> {
    fn create(self: @TContractState) -> u128;
    fn get_block_number(self: @TContractState) -> u64;
}

#[dojo::contract]
mod game_actions {
    use starknet::{
        ContractAddress, get_block_info, get_block_number, get_block_timestamp, get_caller_address
    };

    use risingrevenant::components::game::{
        CurrentGame, GameStatus, GameMap, GameTradeTax, GamePotConsts, GameState, GamePot,
        Dimensions
    };
    use risingrevenant::components::reinforcement::{ReinforcementBalance, target_price};
    use risingrevenant::components::outpost::{OutpostMarket, OutpostSetup};
    use risingrevenant::components::world_event::{WorldEventSetup};

    use risingrevenant::systems::game::{uuid, GameAction, GameActionTrait};

    use risingrevenant::defaults::{
        MAP_WIDTH, MAP_HEIGHT, DEV_PERCENT, CONFIRMATION_PERCENT, LTR_PERCENT, GAME_TRADE_TAX_PERCENT, EVENT_RADIUS_START, EVENT_RADIUS_INCREASE
    };

    

    use super::IGameActions;

    #[external(v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn create(self: @ContractState, admin: ContractAddress) -> u128 {
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

            let game_trade_tax = GameTradeTax{
                game_id,
                trade_tax_percent: GAME_TRADE_TAX_PERCENT,
            };

            let outpost_market = OutpostMarket{
                game_id, 
            }

            let world_event_setup = WorldEventSetup{
                game_id,
                radius_start: EVENT_RADIUS_START,
                radius_increase: EVENT_RADIUS_INCREASE
            };

            let game_state = GameState{
                game_id,
                outpost_created_count: 0,
                outpost_remaining_count: 0,
                remain_life_count: 0,
                reinforcement_count: 0,
                contribution_score_total: 0,
            };

            let game_phases = GamePhases {
                game_id,

            }



            game_action.set((current_game, game_map, game_pot_consts, world_event_setup, outpost_market, game_trade_tax));
            game_id
        }

        fn get_block_number(self: @ContractState) -> u64 {
            get_block_number()
        }
    }
}
