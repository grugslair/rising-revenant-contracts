use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use super::{Permissions, models::WritePermissions};

/// Permission selector constants for different access levels
const DEV_PERMISSIONS_SELECTOR: felt252 = 'devs';
const ADMIN_PERMISSIONS_SELECTOR: felt252 = 'admins';
const SETUP_PERMISSIONS_SELECTOR: felt252 = 'setup';

/// Trait implementation for checking various permission levels
#[generate_trait]
impl PermissionsImpl of HasPermissions {
    /// Checks if a user has admin permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has admin permissions, false otherwise
    fn has_admin_permissions(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permissions(ADMIN_PERMISSIONS_SELECTOR, user)
    }

    /// Checks if a user has dev permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has dev permissions or admin permissions
    fn has_dev_permissions(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permissions(DEV_PERMISSIONS_SELECTOR, user) || self.has_admin_permissions(user)
    }

    /// Checks if a user has setup permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has setup permissions or admin permissions
    fn has_setup_permissions(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permissions(SETUP_PERMISSIONS_SELECTOR, user) || self.has_admin_permissions(user)
    }
}

/// Trait implementation for asserting various permission levels
#[generate_trait]
impl AssertPermissionsImpl of AssertPermissions {
    /// Asserts that a user has admin permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have admin permissions
    fn assert_admin_permissions(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_admin_permissions(user), 'Not admin');
    }

    /// Asserts that a user has dev permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have dev permissions
    fn assert_dev_permissions(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_dev_permissions(user), 'Not dev');
    }

    /// Asserts that a user has setup permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have setup permissions
    fn assert_setup_permissions(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_setup_permissions(user), 'Not setup');
    }
}
