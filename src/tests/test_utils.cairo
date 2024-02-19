use dojo::test_utils::spawn_test_world;

use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};

use openzeppelin::token::erc20::interface::{
    IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
};
use risingrevenant::components::game::{game, game_count_tracker};
use risingrevenant::components::outpost::outpost;
use risingrevenant::components::player::player_info;
use risingrevenant::components::revenant::revenant;
use risingrevenant::components::trade_reinforcement::trade_reinforcement;
use risingrevenant::components::trade_revenant::trade_revenant;
use risingrevenant::components::world_event::world_event;

use risingrevenant::constants::{EVENT_INIT_RADIUS, GAME_CONFIG, OUTPOST_INIT_LIFE};

use risingrevenant::systems::game::{
    game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait
};
use risingrevenant::systems::revenant::{
    revenant_actions, IRevenantActionsDispatcher, IRevenantActionsDispatcherTrait
};
use risingrevenant::systems::trade_reinforcement::{
    trade_reinforcement_actions, ITradeActionsDispatcher, ITradeActionsDispatcherTrait
};
use risingrevenant::systems::trade_revenant::{
    trade_revenant_actions, ITradeRevenantActionsDispatcher, ITradeRevenantActionsDispatcherTrait
};
use risingrevenant::systems::world_event::{
    world_event_actions, IWorldEventActionsDispatcher, IWorldEventActionsDispatcherTrait
};
use risingrevenant::tests::foo_erc::FooErc20;
use starknet::{ContractAddress, syscalls::deploy_syscall};

const EVENT_BLOCK_INTERVAL: u64 = 3;
const PREPARE_PHRASE_INTERVAL: u64 = 10;
const REVENENT_INIT_PRICE: u128 = 0;
const TRANSACTION_FEE_PERCENT: u32 = 5;
const CHAMPION_PRIZE_PERCENT: u32 = 85;

#[derive(Copy, Drop)]
struct DefaultWorld {
    world: IWorldDispatcher,
    caller: ContractAddress,
    game_action: IGameActionsDispatcher,
    revenant_action: IRevenantActionsDispatcher,
    trade_action: ITradeActionsDispatcher,
    trade_revenant_action: ITradeRevenantActionsDispatcher,
    world_event_action: IWorldEventActionsDispatcher,
    test_erc: IERC20Dispatcher,
}

// region ---- base method ----

fn _init_world() -> DefaultWorld {
    let caller = starknet::contract_address_const::<0x0>();

    // components
    let mut models = array![
        game::TEST_CLASS_HASH,
        game_count_tracker::TEST_CLASS_HASH,
        player_info::TEST_CLASS_HASH,
        outpost::TEST_CLASS_HASH,
        revenant::TEST_CLASS_HASH,
        trade_reinforcement::TEST_CLASS_HASH,
        trade_revenant::TEST_CLASS_HASH,
        world_event::TEST_CLASS_HASH
    ];

    // deploy executor, world and register components/systems
    let world = spawn_test_world(models);

    let game_action = IGameActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', game_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    let revenant_action = IRevenantActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', revenant_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    let trade_action = ITradeActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', trade_reinforcement_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    let trade_revenant_action = ITradeRevenantActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', trade_revenant_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    let world_event_action = IWorldEventActionsDispatcher {
        contract_address: world
            .deploy_contract('salt', world_event_actions::TEST_CLASS_HASH.try_into().unwrap())
    };

    let (test_erc_addr, _) = deploy_syscall(
        FooErc20::TEST_CLASS_HASH.try_into().unwrap(), 0, array![].span(), false
    )
        .expect('error deploy erc');
    let test_erc = IERC20Dispatcher { contract_address: test_erc_addr };

    // init admin user
    let admin = starknet::contract_address_const::<0xABCD>();
    world.grant_owner(admin, 'Game');
    world.grant_owner(admin, 'GameCountTracker');
    world.grant_owner(admin, 'GameEntityCounter');
    world.grant_owner(admin, 'PlayerInfo');
    world.grant_owner(admin, 'Outpost');
    world.grant_owner(admin, 'OutpostPosition');
    world.grant_owner(admin, 'Reinforcement');
    world.grant_owner(admin, 'Revenant');
    world.grant_owner(admin, 'WorldEvent');
    world.grant_owner(admin, 'WorldEventTracker');
    world.grant_owner(admin, 'ReinforcementBalance');
    world.grant_owner(admin, 'Trade');
    world.grant_owner(admin, 'TradeRevenant');

    test_erc.transfer(admin, 0x100000000000000_u256);

    DefaultWorld {
        world,
        caller,
        game_action,
        revenant_action,
        trade_action,
        trade_revenant_action,
        world_event_action,
        test_erc,
    }
}

fn _init_game() -> (DefaultWorld, u32) {
    let world = _init_world();
    let game_id = world
        .game_action
        .create(
            PREPARE_PHRASE_INTERVAL,
            EVENT_BLOCK_INTERVAL,
            world.test_erc.contract_address,
            world.revenant_action.contract_address,
            REVENENT_INIT_PRICE,
            1000,
            TRANSACTION_FEE_PERCENT,
            CHAMPION_PRIZE_PERCENT,
        );

    (world, game_id)
}

fn _create_revenant(revenant_action: IRevenantActionsDispatcher, game_id: u32) -> (u128, u128) {
    let (revenant_id, outpost_id) = revenant_action.create(game_id, 1);
    // revenant_action.claim_initial_rewards(game_id);
    (revenant_id, outpost_id)
}

fn _add_block_number(number: u64) -> u64 {
    let mut block_number = starknet::get_block_info().unbox().block_number;
    block_number += number;
    starknet::testing::set_block_number(block_number);
    block_number
}