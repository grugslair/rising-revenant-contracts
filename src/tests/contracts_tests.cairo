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
    reinforcement::{ReinforcementBalance}, trade::{OutpostTrade, ReinforcementTrade},
    world_event::{WorldEventSetup, WorldEvent, CurrentWorldEvent, OutpostVerified}
};

#[cfg(test)]
mod contracts_tests {
    use debug::PrintTrait;
    use dojo::test_utils::{deploy_contract};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


    use risingrevenant::tests::utils::{setup_test_world, DefaultWorld};
    use risingrevenant::components::{
        game::{
            CurrentGame, GamePhases, GameMap, GameERC20, GameTradeTax, GamePotConsts, GameState,
            GamePot, DevWallet
        },
        outpost::{Outpost, OutpostMarket, OutpostSetup}, player::{PlayerInfo, PlayerContribution},
        reinforcement::{ReinforcementBalance}, trade::{OutpostTrade, ReinforcementTrade},
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

    #[test]
    #[available_gas(3000000000)]
    fn test_create_game() {
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
        let game_action = GameAction { world, game_id };
        // let mut game_phases: GamePhases = game_action.get_game();

        // set!(
        //     world,
        //     (GamePhases {
        //         game_id, status: 1, preparation_block_number: 2, play_block_number: 10,
        //     }),
        // );
        // let game_phases: GamePhases = game_action.get_game();
        let game_phases: GamePhases = game_action.get_game();
        // let game_phases = get!(world, game_id, GamePhases);
        // game_phases = game_action.get_game();
        println!("Game ID {}", game_id);
        game_phases.print();
    }
}
