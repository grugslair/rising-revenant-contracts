use starknet::{
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    testing::set_account_contract_address, get_contract_address, get_caller_address,
};
use dojo::{
    test_utils::{deploy_contract, spawn_test_world,},
    world::{IWorldDispatcher, IWorldDispatcherTrait,},
};


use token::presets::erc20::tests_bridgeable::{
    setup as erc20_setup, IERC20BridgeablePresetDispatcher, IERC20BridgeablePresetDispatcherTrait,
    BRIDGE, DECIMALS
};
use risingrevenant::{
    components::{
        game::{
            CurrentGame, current_game, GameMap, game_map, GamePhases, game_phases, GamePot,
            game_pot, GamePotConsts, game_pot_consts, GameState, game_state, GameTradeTax,
            game_trade_tax, GameERC20, game_erc_20,
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
        game::{game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait},
        outpost::{outpost_actions, IOutpostActionsDispatcher,},
        payment::{payment_actions, IPaymentActionsDispatcher,},
        reinforcement::{reinforcement_actions, IReinforcementActionsDispatcher,},
        trade_outpost::{trade_outpost_actions, ITradeOutpostActionsDispatcher,},
        trade_reinforcement::{trade_reinforcement_actions, ITradeReinforcementsActionsDispatcher,},
        world_event::{world_event_actions, IWorldEventActionsDispatcher,},
    },
    tests::{utils::{impersonate, ADMIN, PLAYER_1, PLAYER_2, OTHER}, // erc20::{
    //     setup as erc20_setup, IERC20BridgeablePresetDispatcher,
    //     IERC20BridgeablePresetDispatcherTrait, BRIDGE, DECIMALS
    // }
    },
    constants::DECIMAL_MULTIPLIER,
};

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
    erc20_actions: IERC20BridgeablePresetDispatcher,
}

fn get_test_world() -> IWorldDispatcher {
    let mut models = array![
        current_game::TEST_CLASS_HASH,
        game_map::TEST_CLASS_HASH,
        game_phases::TEST_CLASS_HASH,
        game_pot::TEST_CLASS_HASH,
        game_pot_consts::TEST_CLASS_HASH,
        game_erc_20::TEST_CLASS_HASH,
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

    spawn_test_world(models)
}

#[cfg(test)]
fn make_test_world() -> TestContracts {
    println!("Start deploy erc20");
    let (erc20_world, erc20_dispatcher) = erc20_setup();
    println!("Deployed erc20");
    impersonate(BRIDGE());
    erc20_dispatcher.mint(PLAYER_1(), 1000 * DECIMAL_MULTIPLIER);
    erc20_dispatcher.mint(ADMIN(), 1000 * DECIMAL_MULTIPLIER);

    println!("Minted to player 1");
    impersonate(ADMIN());
    let mut world = get_test_world();
    println!("Made world");
    let empty_felt_span: Span<felt252> = ArrayTrait::new().span();

    let game_actions_dispatcher = IGameActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'game_actions', game_actions::TEST_CLASS_HASH.try_into().unwrap(), empty_felt_span
            )
    };

    let outpost_actions_dispatcher = IOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'outpost_actions',
                outpost_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };
    let payment_actions_dispatcher = IPaymentActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'payment_actions',
                payment_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };
    let reinforcement_actions_dispatcher = IReinforcementActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'reinforcement_actions',
                reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };
    let trade_outpost_actions_dispatcher = ITradeOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'trade_outpost_actions',
                trade_outpost_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };
    let trade_reinforcement_actions_dispatcher = ITradeReinforcementsActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'trade_reinforcement_actions',
                trade_reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };
    let world_event_actions_dispatcher = IWorldEventActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'world_event_actions',
                world_event_actions::TEST_CLASS_HASH.try_into().unwrap(),
                empty_felt_span
            )
    };

    game_actions_dispatcher.set_defaults();
    let mut game_pot_consts: GamePotConsts = get!(world, 0, GamePotConsts);
    let mut game_erc20: GameERC20 = get!(world, 0, GameERC20);
    game_pot_consts.pot_address = payment_actions_dispatcher.contract_address;
    game_erc20.address = erc20_dispatcher.contract_address;

    set!(world, (game_pot_consts, game_erc20));
    TestContracts {
        world,
        game_actions: game_actions_dispatcher,
        outpost_actions: outpost_actions_dispatcher,
        payment_actions: payment_actions_dispatcher,
        reinforcement_actions: reinforcement_actions_dispatcher,
        trade_outpost_actions: trade_outpost_actions_dispatcher,
        trade_reinforcement_actions: trade_reinforcement_actions_dispatcher,
        world_event_actions: world_event_actions_dispatcher,
        erc20_actions: erc20_dispatcher,
    }
}
