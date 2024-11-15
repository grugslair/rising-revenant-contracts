use starknet::ContractAddress;

#[starknet::interface]
trait IPemissions<TContractState> {
    fn get_permissions(
        self: @TContractState, resource: felt252, requester: ContractAddress
    ) -> felt252;
    fn set_permissions(
        ref self: TContractState,
        resource: felt252,
        requester: ContractAddress,
        permissions: felt252
    );
}


#[dojo::contract]
mod permissions_core {
    use starknet::{ContractAddress, get_caller_address};
    use rising_revenant::{
        Permissions, permissions::{AssertPermissions, models::WritePermissions},
        world::{WorldTrait, default_namespace}
    };
    use super::{IPemissions};

    #[abi(embed_v0)]
    impl IPemissionsCoreImpl of IPemissions<ContractState> {
        fn get_permissions(
            self: @ContractState, resource: felt252, requester: ContractAddress
        ) -> felt252 {
            let world = self.world(default_namespace());
            world.get_permissions(resource, requester)
        }
        fn set_permissions(
            ref self: ContractState,
            resource: felt252,
            requester: ContractAddress,
            permissions: felt252
        ) {
            let mut world = self.world(default_namespace());
            world.assert_admin_permissions(get_caller_address());
            world.set_permissions(resource, requester, permissions);
        }
    }
}
