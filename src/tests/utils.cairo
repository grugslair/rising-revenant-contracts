#[cfg(test)]
use dojo::test_utils::{spawn_test_world, deploy_contract};
use starknet::class_hash::Felt252TryIntoClassHash;
use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};

// use openzeppelin::token::erc20::interface::{
//     IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
// };

// Models
use risingrevenant::components::{
    game::{
        CurrentGame, GamePhases, GameMap, GameERC20, GameTradeTax, GamePotConsts, GameState,
        GamePot, DevWallet
    },
    outpost::{Outpost, OutpostMarket, OutpostSetup}, player::{PlayerInfo, PlayerContribution},
    reinforcement::{ReinforcementMarket}, trade::{OutpostTrade, ReinforcementTrade},
    world_event::{WorldEventSetup, WorldEvent, CurrentWorldEvent, OutpostVerified}
};
use risingrevenant::components::{
    game::{
        current_game, game_phases, game_map, game_trade_tax, game_pot_consts, game_state, game_pot,
        dev_wallet
    },
    outpost::{outpost, outpost_market, outpost_setup}, player::{player_info, player_contribution},
    reinforcement::{reinforcement_market}, trade::{outpost_trade, reinforcement_trade},
    world_event::{world_event_setup, world_event, current_world_event, outpost_verified}
};

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

use starknet::{ContractAddress, syscalls::deploy_syscall};

const EVENT_BLOCK_INTERVAL: u64 = 3;
const PREPARE_PHRASE_INTERVAL: u64 = 10;
const REVENENT_INIT_PRICE: u128 = 0;
const TRANSACTION_FEE_PERCENT: u32 = 5;
const CHAMPION_PRIZE_PERCENT: u32 = 85;

#[cfg(test)]
#[derive(Copy, Drop)]
struct DefaultWorld {
    world: IWorldDispatcher,
    game_actions: IGameActionsDispatcher,
    outpost_actions: IOutpostActionsDispatcher,
    payment_actions: IPaymentActionsDispatcher,
    reinforcement_actions: IReinforcementActionsDispatcher,
    trade_outpost_actions: ITradeOutpostActionsDispatcher,
    trade_reinforcement_actions: ITradeReinforcementsActionsDispatcher,
    world_event_actions: IWorldEventActionsDispatcher,
    admin: ContractAddress,
}


// region ---- base method ----
#[cfg(test)]
fn setup_test_world() -> DefaultWorld {
    let mut models = array![
        current_game::TEST_CLASS_HASH,
        game_phases::TEST_CLASS_HASH,
        game_map::TEST_CLASS_HASH,
        game_trade_tax::TEST_CLASS_HASH,
        game_pot_consts::TEST_CLASS_HASH,
        game_state::TEST_CLASS_HASH,
        game_pot::TEST_CLASS_HASH,
        dev_wallet::TEST_CLASS_HASH,
        outpost::TEST_CLASS_HASH,
        outpost_market::TEST_CLASS_HASH,
        outpost_setup::TEST_CLASS_HASH,
        player_info::TEST_CLASS_HASH,
        player_contribution::TEST_CLASS_HASH,
        reinforcement_market::TEST_CLASS_HASH,
        outpost_trade::TEST_CLASS_HASH,
        reinforcement_trade::TEST_CLASS_HASH,
        world_event_setup::TEST_CLASS_HASH,
        world_event::TEST_CLASS_HASH,
        current_world_event::TEST_CLASS_HASH,
        outpost_verified::TEST_CLASS_HASH,
    ];

    // deploy executor, world and register components/systems
    let world = spawn_test_world(models);

    let game_actions = IGameActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', game_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let outpost_actions = IOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', outpost_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let payment_actions = IPaymentActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', payment_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let reinforcement_actions = IReinforcementActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let trade_outpost_actions = ITradeOutpostActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', trade_outpost_actions::TEST_CLASS_HASH.try_into().unwrap())
    };
    let trade_reinforcement_actions = ITradeReinforcementsActionsDispatcher {
        contract_address: world
            .deploy_contract(
                'salt', trade_reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap()
            )
    };
    let world_event_actions = IWorldEventActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', world_event_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    // init admin user
    let admin = starknet::contract_address_const::<0x1>();
    world.grant_owner(admin, 'CurrentGame');
    world.grant_owner(admin, 'GamePhases');
    world.grant_owner(admin, 'GameMap');
    world.grant_owner(admin, 'GameERC20');
    world.grant_owner(admin, 'GameTradeTax');
    world.grant_owner(admin, 'GamePotConsts');
    world.grant_owner(admin, 'GameState');
    world.grant_owner(admin, 'GamePot');
    world.grant_owner(admin, 'DevWallet');
    world.grant_owner(admin, 'Outpost');
    world.grant_owner(admin, 'OutpostMarket');
    world.grant_owner(admin, 'OutpostSetup');
    world.grant_owner(admin, 'PlayerInfo');
    world.grant_owner(admin, 'PlayerContribution');
    world.grant_owner(admin, 'ReinforcementMarket');
    world.grant_owner(admin, 'OutpostTrade');
    world.grant_owner(admin, 'ReinforcementTrade');
    world.grant_owner(admin, 'WorldEventSetup');
    world.grant_owner(admin, 'WorldEvent');
    world.grant_owner(admin, 'CurrentWorldEvent');
    world.grant_owner(admin, 'OutpostVerified');

    DefaultWorld {
        world: world,
        game_actions,
        outpost_actions,
        payment_actions,
        reinforcement_actions,
        trade_outpost_actions,
        trade_reinforcement_actions,
        world_event_actions,
        admin,
    }
}
// fn _add_block_number(number: u64) -> u64 {
//     let mut block_number = starknet::get_block_info().unbox().block_number;
//     block_number += number;
//     starknet::testing::set_block_number(block_number);
//     block_number
// }


