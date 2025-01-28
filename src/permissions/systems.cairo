use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use super::{PermissionStorage, Permission};

/// Permission selector constants for different access levels
const DEV_PERMISSION_SELECTOR: felt252 = 'dev';
const ADMIN_PERMISSION_SELECTOR: felt252 = 'admin';
const SETUP_PERMISSION_SELECTOR: felt252 = 'creator';

/// Trait implementation for checking various permission levels
#[generate_trait]
impl GamePermissionsImpl of GamePermissions {
    /// Checks if a user has admin permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has admin permissions, false otherwise
    fn has_admin_permission(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permission(ADMIN_PERMISSION_SELECTOR, user)
    }

    /// Checks if a user has dev permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has dev permissions or admin permissions
    fn has_dev_permission(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permission(DEV_PERMISSION_SELECTOR, user) || self.has_admin_permission(user)
    }

    /// Checks if a user has creator permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Returns
    /// * `bool` - True if user has creator permissions or admin permissions
    fn has_creator_permission(self: @WorldStorage, user: ContractAddress) -> bool {
        self.get_permission(SETUP_PERMISSION_SELECTOR, user) || self.has_admin_permission(user)
    }

    /// Asserts that a user has admin permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have admin permissions
    fn assert_admin_permission(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_admin_permission(user), 'Not admin');
    }

    /// Asserts that a user has dev permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have dev permissions
    fn assert_dev_permission(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_dev_permission(user), 'Not dev');
    }

    /// Asserts that a user has creator permissions
    /// # Arguments
    /// * `self` - The world storage reference
    /// * `user` - The contract address to check permissions for
    /// # Panics
    /// Panics if the user does not have creator permissions
    fn assert_creator_permission(self: @WorldStorage, user: ContractAddress) {
        assert(self.has_creator_permission(user), 'Not creator');
    }

    fn set_admin_permission(ref self: WorldStorage, user: ContractAddress, has: bool) {
        self.set_permission(ADMIN_PERMISSION_SELECTOR, user, has);
    }

    fn set_dev_permission(ref self: WorldStorage, user: ContractAddress, has: bool) {
        self.set_permission(DEV_PERMISSION_SELECTOR, user, has);
    }

    fn set_creator_permission(ref self: WorldStorage, user: ContractAddress, has: bool) {
        self.set_permission(SETUP_PERMISSION_SELECTOR, user, has);
    }

    fn set_admins_permission(ref self: WorldStorage, users: Array<ContractAddress>, has: bool) {
        let mut permissions = ArrayTrait::<Permission<bool>>::new();
        for user in users{
            permissions.append(Permission { resource: SETUP_PERMISSION_SELECTOR, requester: user, permission: has });
        };
        self.set_permissions(permissions);
    }

    fn set_devs_permission(ref self: WorldStorage, users: Array<ContractAddress>, has: bool) {
        let mut permissions = ArrayTrait::<Permission<bool>>::new();
        for user in users{
            permissions.append(Permission { resource: SETUP_PERMISSION_SELECTOR, requester: user, permission: has });
        };
        self.set_permissions(permissions);
    }

    fn set_creators_permission(ref self: WorldStorage, users: Array<ContractAddress>, has: bool) {
        let mut permissions = ArrayTrait::<Permission<bool>>::new();
        for user in users{
            permissions.append(Permission { resource: SETUP_PERMISSION_SELECTOR, requester: user, permission: has });
        };
        self.set_permissions(permissions);
    }
}
