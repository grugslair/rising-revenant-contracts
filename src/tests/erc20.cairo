use core::array::SpanTrait;
use starknet::ContractAddress;
use starknet::testing;
use zeroable::Zeroable;

use integer::BoundedInt;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::test_utils::spawn_test_world;
use token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, BRIDGE, DECIMALS, SUPPLY, VALUE};

use starknet::storage::{StorageMemberAccessTrait};


fn setup() -> (IWorldDispatcher, IERC20BridgeablePresetDispatcher) {
    let world = spawn_test_world(
        array![
            erc_20_allowance_model::TEST_CLASS_HASH,
            erc_20_balance_model::TEST_CLASS_HASH,
            erc_20_metadata_model::TEST_CLASS_HASH,
            erc_20_bridgeable_model::TEST_CLASS_HASH,
        ]
    );

    // deploy contract
    let mut erc20_bridgeable_dispatcher = IERC20BridgeablePresetDispatcher {
        contract_address: world
            .deploy_contract(
                'salt', ERC20Bridgeable::TEST_CLASS_HASH.try_into().unwrap(), array![].span()
            )
    };

    // setup auth
    world
        .grant_writer(
            selector!("ERC20AllowanceModel"), erc20_bridgeable_dispatcher.contract_address
        );
    world
        .grant_writer(selector!("ERC20BalanceModel"), erc20_bridgeable_dispatcher.contract_address);
    world
        .grant_writer(
            selector!("ERC20MetadataModel"), erc20_bridgeable_dispatcher.contract_address
        );
    world
        .grant_writer(
            selector!("ERC20BridgeableModel"), erc20_bridgeable_dispatcher.contract_address
        );

    // initialize contracts
    erc20_bridgeable_dispatcher.initializer("NAME", "SYMBOL", SUPPLY, OWNER(), BRIDGE());

    // drop all events
    utils::drop_all_events(erc20_bridgeable_dispatcher.contract_address);
    utils::drop_all_events(world.contract_address);

    (world, erc20_bridgeable_dispatcher)
}

