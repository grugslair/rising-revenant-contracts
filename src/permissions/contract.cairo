use starknet::ContractAddress;

/// Interface for managing permissions in the system
/// Provides functionality to get and set permissions for resources and requesters
#[starknet::interface]
trait IPemissions<TContractState> {
    /// Returns the permission level for a given resource and requester
    /// # Arguments
    /// * `resource` - The resource identifier
    /// * `requester` - The address of the entity requesting permissions
    /// # Returns
    /// * `felt252` - The permission level
    fn get_permissions(
        self: @TContractState, resource: felt252, requester: ContractAddress
    ) -> felt252;

    /// Sets the permission level for a given resource and requester
    /// # Arguments
    /// * `resource` - The resource identifier
    /// * `requester` - The address of the entity to set permissions for
    /// * `permissions` - The permission level to set
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

    /// Implementation of the IPemissions interface
    #[abi(embed_v0)]
    impl IPemissionsCoreImpl of IPemissions<ContractState> {
        /// Gets the current permissions for a resource and requester
        /// # Arguments
        /// * `resource` - The resource identifier
        /// * `requester` - The address of the entity requesting permissions
        /// # Returns
        /// * `felt252` - The current permission level
        fn get_permissions(
            self: @ContractState, resource: felt252, requester: ContractAddress
        ) -> felt252 {
            let world = self.world(default_namespace());
            world.get_permissions(resource, requester)
        }

        /// Sets new permissions for a resource and requester
        /// Only callable by admin
        /// # Arguments
        /// * `resource` - The resource identifier
        /// * `requester` - The address of the entity to set permissions for
        /// * `permissions` - The new permission level to set
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
