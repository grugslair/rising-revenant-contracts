use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::core::{BoolIntoFelt252Impl, Felt252TryIntoBoolImpl};

mod models {
    use starknet::ContractAddress;
    /// Represents permission settings for a resource and requester
    /// 
    /// # Arguments
    /// * `resource` - The identifier of the resource being accessed
    /// * `requester` - The address of the entity requesting access
    /// * `permissions` - The permission flags stored as a felt252
    #[dojo::model]
    #[derive(Copy, Drop, Serde)]
    struct Permissions {
        #[key]
        resource: felt252,
        #[key]
        requester: ContractAddress,
        permissions: felt252,
    }
}
use models::Permissions as PermissionsModel;

/// Trait for reading permissions from storage
/// 
/// Generic parameter P represents the permission type that will be returned
trait Permissions<P> {
    /// Retrieves permissions for a given resource and requester
    /// 
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The address requesting access
    /// 
    /// # Returns
    /// * The permissions of type P for the given resource and requester
    fn get_permissions(self: @WorldStorage, resource: felt252, requester: ContractAddress) -> P;
}

/// Trait for writing permissions to storage
/// 
/// Generic parameter P represents the permission type that will be stored
trait WritePermissions<P> {
    /// Sets permissions for a given resource and requester
    /// 
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The address requesting access
    /// * `permissions` - The permissions to set
    fn set_permissions(
        ref self: WorldStorage, resource: felt252, requester: ContractAddress, permissions: P
    );
}

/// Implementation of the Permissions trait
/// 
/// Requires that P can be converted from felt252
impl PermissionsImpl<P, +TryInto<felt252, P>> of Permissions<P> {
    fn get_permissions(self: @WorldStorage, resource: felt252, requester: ContractAddress) -> P {
        self
            .read_member::<
                felt252
            >(
                Model::<PermissionsModel>::ptr_from_keys((resource, requester)),
                selector!("permissions")
            )
            .try_into()
            .unwrap()
    }
}

/// Implementation of the WritePermissions trait
/// 
/// Requires that P can be converted to felt252 and implements Drop
impl WritePermissionsImpl<P, +Into<P, felt252>, +Drop<P>> of WritePermissions<P> {
    fn set_permissions(
        ref self: WorldStorage, resource: felt252, requester: ContractAddress, permissions: P
    ) {
        self
            .write_model(
                @PermissionsModel { resource: resource, requester, permissions: permissions.into() }
            )
    }
}

