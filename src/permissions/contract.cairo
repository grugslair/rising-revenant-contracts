use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};

#[dojo::interface]
trait IPemissions<TContractState> {
    fn get_permissions(
        self: @ContractState, resource: felt252, requester: ContractAddress
    ) -> felt252;
    fn set_permissions(
        ref self: ContractState, resource: felt252, requester: ContractAddress, permissions: felt252
    );
}


#[dojo::contract]
mod permissions_core {
    use starknet::{ContractAddress, get_caller_address};
    use rising_revenant::{Permissions, permissions::{AssertPermissions, models::WritePermissions}};
    use super::{IPemissions};

    #[abi(embed_v0)]
    impl IPemissionsCoreImpl of IPemissions<ContractState> {
        fn get_permissions(
            self: @ContractState, resource: felt252, requester: ContractAddress
        ) -> felt252 {
            world.get_permissions(resource, requester)
        }
        fn set_permissions(
            ref self: ContractState,
            resource: felt252,
            requester: ContractAddress,
            permissions: felt252
        ) {
            world.assert_admin_permissions(get_caller_address());
            world.set_permissions(resource, requester, permissions);
        }
    }
}
