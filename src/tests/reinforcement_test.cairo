use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo::database::introspect::Introspect;
use dojo::model::Model;

// contracts
use risingrevenant::contracts::{
    game::{game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait},
    outpost::{outpost_actions, IOutpostActionsDispatcher, IOutpostActionsDispatcherTrait},
    payment::{payment_actions, IPaymentActionsDispatcher, IPaymentActionsDispatcherTrait},
    reinforcement::{
        reinforcement_actions, IReinforcementActionsDispatcher, IReinforcementActionsDispatcherTrait
    },
    trade_outpost::{
        trade_outpost_actions, ITradeOutpostActionsDispatcher, ITradeOutpostActionsDispatcherTrait
    },
    trade_reinforcement::{
        trade_reinforcement_actions, ITradeReinforcementsActionsDispatcher,
        ITradeReinforcementsActionsDispatcherTrait
    },
    world_event::{
        world_event_actions, IWorldEventActionsDispatcher, IWorldEventActionsDispatcherTrait
    },
};
use risingrevenant::components::{
    game::{
        CurrentGame, GamePhases, GameMap, GameERC20, GameTradeTax, GamePotConsts, GameState,
        GamePot, DevWallet
    },
    outpost::{Outpost, OutpostMarket, OutpostSetup}, player::{PlayerInfo, PlayerContribution},
    reinforcement::{ReinforcementMarket}, trade::{OutpostTrade, ReinforcementTrade},
    world_event::{WorldEventSetup, WorldEvent, CurrentWorldEvent, OutpostVerified}
};

#[cfg(test)]
mod contracts_tests {
    use debug::PrintTrait;
    use dojo::test_utils::{deploy_contract};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use origami::defi::auction::vrgda::{LogisticVRGDA, LogisticVRGDATrait};
    use cubit::f128::types::fixed::{Fixed, FixedTrait, ONE_u128};

    use risingrevenant::utils::get_block_number;

    use risingrevenant::tests::utils::{setup_test_world, DefaultWorld};
    use risingrevenant::components::{
        game::{
            CurrentGame, GamePhases, GameMap, GameERC20, GameTradeTax, GamePotConsts, GameState,
            GamePot, DevWallet
        },
        outpost::{Outpost, OutpostMarket, OutpostSetup}, player::{PlayerInfo, PlayerContribution},
        reinforcement::{ReinforcementMarket}, trade::{OutpostTrade, ReinforcementTrade},
        world_event::{WorldEventSetup, WorldEvent, CurrentWorldEvent, OutpostVerified}
    };
    use risingrevenant::contracts::{
        game::{game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait},
        outpost::{outpost_actions, IOutpostActionsDispatcher, IOutpostActionsDispatcherTrait},
        payment::{payment_actions, IPaymentActionsDispatcher, IPaymentActionsDispatcherTrait},
        reinforcement::{
            reinforcement_actions, IReinforcementActionsDispatcher,
            IReinforcementActionsDispatcherTrait
        },
        trade_outpost::{
            trade_outpost_actions, ITradeOutpostActionsDispatcher,
            ITradeOutpostActionsDispatcherTrait
        },
        trade_reinforcement::{
            trade_reinforcement_actions, ITradeReinforcementsActionsDispatcher,
            ITradeReinforcementsActionsDispatcherTrait
        },
        world_event::{
            world_event_actions, IWorldEventActionsDispatcher, IWorldEventActionsDispatcherTrait
        },
    };

    use risingrevenant::systems::{game::{GameAction, GameActionTrait},};

    use risingrevenant::defaults::{
        REINFORCEMENT_TARGET_PRICE, REINFORCEMENT_MAX_SELLABLE, REINFORCEMENT_DECAY_CONSTANT,
        REINFORCEMENT_TIME_SCALE
    };

    #[test]
    #[available_gas(3000000000)]
    fn test_purchase() {
        println!("Test Purchase Reinforcements");
        let DefaultWorld{world,
        game_actions,
        outpost_actions,
        payment_actions,
        reinforcement_actions,
        trade_outpost_actions,
        trade_reinforcement_actions,
        world_event_actions,
        admin } =
            setup_test_world();
        let game_id = game_actions.create(1, 10);
        starknet::testing::set_block_number(1);
        let game_action = GameAction { world, game_id };
        let mut n: u32 = 1;
        loop {
            let price = reinforcement_actions.get_price(game_id, 10);
            let mut market: ReinforcementMarket = game_action.get_game();
            println!("Market count {} price {}", market.count, price);

            market.count = n * 10;
            game_action.set(market);

            n += 1;
            if n >= 10 {
                break;
            }
        };
    }
    #[test]
    #[available_gas(3000000000)]
    fn test_target_sales_time() {
        let vrgda = LogisticVRGDA {
            target_price: FixedTrait::new_unscaled(REINFORCEMENT_TARGET_PRICE, false),
            decay_constant: FixedTrait::new(REINFORCEMENT_DECAY_CONSTANT, false),
            max_sellable: FixedTrait::new_unscaled(REINFORCEMENT_MAX_SELLABLE.into(), false),
            time_scale: FixedTrait::new(REINFORCEMENT_TIME_SCALE, false),
        };
        let mut n: u128 = 0;
        loop {
            let price = vrgda
                .get_vrgda_price(
                    FixedTrait::new_unscaled(5, false), FixedTrait::new_unscaled(n, false)
                );

            let price_u128: u128 = price.try_into().unwrap();
            println!("count {} price {}", n, price_u128);
            if n >= 40 {
                break;
            }
            n += 2;
        };
        n = 0;
        println!("Target Sales Times");
        loop {
            let time = vrgda.get_target_sale_time(FixedTrait::new_unscaled(n, false));

            let time_1_000_000_000: u128 = time.mag * 1_000_000_000 / ONE_u128;
            let time_1: u128 = time.try_into().unwrap();
            println!("count {} time * 1e9 {} time {}", n, time_1_000_000_000, time_1);
            if n >= 20 {
                break;
            }
            n += 5;
        };
    }
}
