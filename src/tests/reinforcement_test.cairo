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
    use core::dict::{Felt252Dict, Felt252DictTrait, Felt252DictValue};
    // #[derive(Drop, Serde, Copy)]
    // struct Foo {
    //     id: u128,
    //     a: u8,
    //     b: u8
    // }

    // impl Felt252DictValueImpl of Felt252DictValue<Foo> {
    //     fn zero_default() -> Foo nopanic {
    //         Foo { id: 0, a: 0, b: 0 }
    //     }
    // }
    // impl U8TupleDrop

    #[test]
    #[available_gas(3000000000)]
    fn test_dicts() {
        let mut test: Felt252Dict<Foo> = Default::default();
    // let box = BoxTrait::new(Foo { id: 1, a: 2, b: 3 });
    // let mut foo = box.unbox();
    // foo.a = 4;
    // let foo2 = box.unbox();
    // println!("foo2: {}", foo2.a);
    }

    
}
