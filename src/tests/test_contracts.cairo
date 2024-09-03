use starknet::{
    class_hash::Felt252TryIntoClassHash, syscalls::deploy_syscall, ContractAddress,
    testing::set_account_contract_address
};
use dojo::{
    test_utils::{deploy_contract, spawn_test_world,},
    world::{IWorldDispatcher, IWorldDispatcherTrait,},
};


use risingrevenant::{
    components::{
        game::{
            CurrentGame, current_game, DevWallet, dev_wallet, GameMap, game_map, GamePhases,
            game_phases, GamePot, game_pot, GamePotConsts, game_pot_consts, GameState, game_state,
            GameTradeTax, game_trade_tax, GameERC20, game_erc_20,
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

