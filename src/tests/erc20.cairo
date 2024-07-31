use core::array::SpanTrait;
use starknet::ContractAddress;
use starknet::testing;
use zeroable::Zeroable;

use integer::BoundedInt;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::test_utils::spawn_test_world;
use origami_token::tests::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, BRIDGE, DECIMALS, SUPPLY, VALUE
};

use origami_token::tests::utils;

use origami_token::components::token::erc20::erc20_metadata::{
    erc_20_metadata_model, ERC20MetadataModel,
};
use origami_token::components::token::erc20::erc20_metadata::erc20_metadata_component::{
    ERC20MetadataImpl, ERC20MetadataTotalSupplyImpl, InternalImpl as ERC20MetadataInternalImpl
};

use origami_token::components::token::erc20::erc20_balance::{
    erc_20_balance_model, ERC20BalanceModel,
};
use origami_token::components::token::erc20::erc20_balance::erc20_balance_component::{
    Transfer, ERC20BalanceImpl, InternalImpl as ERC20BalanceInternalImpl
};

use origami_token::components::token::erc20::erc20_allowance::{
    erc_20_allowance_model, ERC20AllowanceModel,
};
use origami_token::components::token::erc20::erc20_allowance::erc20_allowance_component::{
    Approval, ERC20AllowanceImpl, InternalImpl as ERC20AllownceInternalImpl,
};

use origami_token::components::token::erc20::erc20_bridgeable::{
    erc_20_bridgeable_model, ERC20BridgeableModel
};
use origami_token::components::token::erc20::erc20_bridgeable::erc20_bridgeable_component::{
    ERC20BridgeableImpl
};

use origami_token::components::token::erc20::erc20_mintable::erc20_mintable_component::InternalImpl as ERC20MintableInternalImpl;
use origami_token::components::token::erc20::erc20_burnable::erc20_burnable_component::InternalImpl as ERC20BurnableInternalImpl;

use origami_token::presets::erc20::bridgeable::{
    ERC20Bridgeable, IERC20BridgeablePresetDispatcher, IERC20BridgeablePresetDispatcherTrait
};
use origami_token::presets::erc20::bridgeable::ERC20Bridgeable::{ERC20InitializerImpl};
use starknet::storage::{StorageMemberAccessTrait};

use origami_token::components::tests::token::erc20::test_erc20_allowance::{
    assert_event_approval, assert_only_event_approval
};
use origami_token::components::tests::token::erc20::test_erc20_balance::{
    assert_event_transfer, assert_only_event_transfer
};


//
// Setup
//

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

