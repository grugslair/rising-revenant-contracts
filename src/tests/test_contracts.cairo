#[cfg(test)]
use dojo::{
    test_utils::{deploy_contract, spawn_test_world,},
    world::{IWorldDispatcher, IWorldDispatcherTrait,},
};
use starknet::{class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,};
use risingrevenant::{
    components::{
        game::{
            CurrentGame, current_game, DevWallet, dev_wallet, GameMap, game_map, GamePhases,
            game_phases, GamePot, game_pot, GamePotConsts, game_pot_consts, GameState, game_state,
            GameTradeTax, game_trade_tax,
        },
        outpost::{Outpost, outpost, OutpostMarket, outpost_market, OutpostSetup, outpost_setup,},
        player::{PlayerContribution, player_contribution, PlayerInfo, player_info,},
        reinforcement::{ReinforcementMarketConsts, reinforcement_market_consts,},
        trade::{OutpostTrade, outpost_trade, ReinforcementTrade, reinforcement_trade,},
        world_event::{
            CurrentWorldEvent, current_world_event, OutpostVerified, outpost_verified, WorldEvent,
            world_event, WorldEventSetup, world_event_setup, WorldEventVerifications,
            world_event_verifications,
        },
    },
    contracts::{
        game::{game_actions, IGameActionsDispatcher,},
        outpost::{outpost_actions, IOutpostActionsDispatcher,},
        payment::{payment_actions, IPaymentActionsDispatcher,},
        reinforcement::{reinforcement_actions, IReinforcementActionsDispatcher,},
        trade_outpost::{trade_outpost_actions, ITradeOutpostActionsDispatcher,},
        trade_reinforcement::{trade_reinforcement_actions, ITradeReinforcementsActionsDispatcher,},
        world_event::{world_event_actions, IWorldEventActionsDispatcher,},
    },
};

#[cfg(test)]
#[derive(Copy, Drop)]
struct TestContracts {
    world: IWorldDispatcher,
    game_actions: IGameActionsDispatcher,
    outpost_actions: IOutpostActionsDispatcher,
    payment_actions: IPaymentActionsDispatcher,
    reinforcement_actions: IReinforcementActionsDispatcher,
    trade_outpost_actions: ITradeOutpostActionsDispatcher,
    trade_reinforcement_actions: ITradeReinforcementsActionsDispatcher,
    world_event_actions: IWorldEventActionsDispatcher,
}

#[cfg(test)]
fn make_test_world() -> TestContracts {
    let mut models = array![
        current_game::TEST_CLASS_HASH,
        dev_wallet::TEST_CLASS_HASH,
        game_map::TEST_CLASS_HASH,
        game_phases::TEST_CLASS_HASH,
        game_pot::TEST_CLASS_HASH,
        game_pot_consts::TEST_CLASS_HASH,
        game_state::TEST_CLASS_HASH,
        game_trade_tax::TEST_CLASS_HASH,
        outpost::TEST_CLASS_HASH,
        outpost_market::TEST_CLASS_HASH,
        outpost_setup::TEST_CLASS_HASH,
        player_contribution::TEST_CLASS_HASH,
        player_info::TEST_CLASS_HASH,
        reinforcement_market_consts::TEST_CLASS_HASH,
        outpost_trade::TEST_CLASS_HASH,
        reinforcement_trade::TEST_CLASS_HASH,
        current_world_event::TEST_CLASS_HASH,
        outpost_verified::TEST_CLASS_HASH,
        world_event::TEST_CLASS_HASH,
        world_event_setup::TEST_CLASS_HASH,
        world_event_verifications::TEST_CLASS_HASH,
    ];

    let world = spawn_test_world(models);
    let game_actions_dispatcher = IGameActionsDispatcher {
        contract_address: world
            .deploy_contract('game_actions', game_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let outpost_actions_dispatcher = IOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'outpost_actions', outpost_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let payment_actions_dispatcher = IPaymentActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'payment_actions', payment_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let reinforcement_actions_dispatcher = IReinforcementActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'reinforcement_actions', reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let trade_outpost_actions_dispatcher = ITradeOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'trade_outpost_actions', trade_outpost_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let trade_reinforcement_actions_dispatcher = ITradeReinforcementsActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'trade_reinforcement_actions',
                trade_reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let world_event_actions_dispatcher = IWorldEventActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'world_event_actions', world_event_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };

    TestContracts {
        world,
        game_actions: game_actions_dispatcher,
        outpost_actions: outpost_actions_dispatcher,
        payment_actions: payment_actions_dispatcher,
        reinforcement_actions: reinforcement_actions_dispatcher,
        trade_outpost_actions: trade_outpost_actions_dispatcher,
        trade_reinforcement_actions: trade_reinforcement_actions_dispatcher,
        world_event_actions: world_event_actions_dispatcher,
    }
}
