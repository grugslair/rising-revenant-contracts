use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo::database::introspect::Introspect;
use dojo::model::Model;
use token::presets::erc20::tests_bridgeable::{IERC20BridgeablePresetDispatcherTrait, BRIDGE};

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
    use token::presets::erc20::bridgeable::IERC20BridgeablePresetDispatcherTrait;
    use core::option::OptionTrait;

    use debug::PrintTrait;
    use starknet::{ContractAddress, testing::{set_caller_address, set_block_number}};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use origami::defi::auction::vrgda::{LogisticVRGDA, VRGDATrait};
    use cubit::f128::types::fixed::{Fixed, FixedTrait, ONE_u128};

    use risingrevenant::utils::get_block_number;

    use risingrevenant::tests::test_contracts::{make_test_world, TestContracts};
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

    use risingrevenant::systems::{
        game::{GameAction, GameActionTrait}, reinforcement::{ReinforcementActionTrait}
    };
    use risingrevenant::{
        tests::utils::{impersonate, ADMIN, PLAYER_1, PLAYER_2, OTHER}, constants::DECIMAL_MULTIPLIER
    };

    #[test]
    #[available_gas(3000000000)]
    fn test_purchase() {
        println!("Test Purchase Reinforcements");
        let TestContracts { world,
        game_actions,
        outpost_actions,
        payment_actions,
        reinforcement_actions,
        trade_outpost_actions,
        trade_reinforcement_actions,
        world_event_actions,
        erc20_actions } =
            make_test_world();

        let game_id = game_actions.create(1, 10);
        set_block_number(3);
        let game_action = GameAction { world, game_id };
        let mut n: u32 = 1;
        let pot: GamePot = game_action.get_game();
        let balance = erc20_actions.balance_of(PLAYER_1());
        println!(
            "total {} winners {} confirmation {} ltr {} dev {}\t player: {}",
            pot.total_pot,
            pot.winners_pot,
            pot.confirmation_pot,
            pot.ltr_pot,
            pot.dev_pot,
            balance / DECIMAL_MULTIPLIER,
        );
        impersonate(PLAYER_1());
        loop {
            let price = reinforcement_actions.get_price(game_id, n);
            reinforcement_actions.purchase(game_id, n);
            println!("Ammount 10 price {}", price);
            let pot: GamePot = game_action.get_game();
            println!(
                "total {} winners {} confirmation {} ltr {} dev {}\t player: {}",
                pot.total_pot / DECIMAL_MULTIPLIER,
                pot.winners_pot / DECIMAL_MULTIPLIER,
                pot.confirmation_pot / DECIMAL_MULTIPLIER,
                pot.ltr_pot / DECIMAL_MULTIPLIER,
                pot.dev_pot / DECIMAL_MULTIPLIER,
                balance / DECIMAL_MULTIPLIER,
            );
            erc20_actions.balance_of(PLAYER_1());
            n += 1;
            if n >= 10 {
                break;
            }
        };
    }
}
