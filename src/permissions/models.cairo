use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::core::{Felt252TryIntoBoolImpl};

mod models {
    use starknet::ContractAddress;
    /// Represents permission settings for a resource and requester
    ///
    /// # Arguments
    /// * `resource` - The identifier of the resource being accessed
    /// * `requester` - The address of the entity requesting access
    /// * `permissions` - The permission flags stored as a felt252
    #[dojo::model]
    #[derive(Drop, Serde)]
    struct Permission {
        #[key]
        resource: felt252,
        #[key]
        requester: ContractAddress,
        permission: felt252,
    }
}

#[derive(Drop)]
struct Permission<P> {
    resource: felt252,
    requester: ContractAddress,
    permission: P,
}

impl PermissionIntoModel<P, +Into<P, felt252>> of Into<Permission<P>, PermissionModel> {
    fn into(self: Permission<P>) -> PermissionModel {
        PermissionModel {
            resource: self.resource,
            requester: self.requester,
            permission: self.permission.into(),
        }
    }
}

use models::Permission as PermissionModel;

/// Trait for reading permissions from storage
///
/// Generic parameter P represents the permission type that will be returned
trait PermissionStorage<P> {
    /// Retrieves permissions for a given resource and requester
    ///
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The address requesting access
    ///
    /// # Returns
    /// * The permissions of type P for the given resource and requester
    fn get_permission(self: @WorldStorage, resource: felt252, requester: ContractAddress) -> P;
    /// Sets permissions for a given resource and requester
    ///
    /// # Arguments
    /// * `resource` - The identifier of the resource
    /// * `requester` - The address requesting access
    /// * `permissions` - The permissions to set
    fn set_permission(
        ref self: WorldStorage, resource: felt252, requester: ContractAddress, permission: P
    );

    fn set_permissions(
        ref self: WorldStorage, permissions: Array<Permission<P>>);
}

/// Implementation of the Permissions trait
///
/// Requires that P can be converted from felt252
impl PermissionImpl<P, +Into<P, felt252>, +TryInto<felt252, P>, +Drop<P>> of PermissionStorage<P> {
    fn get_permission(self: @WorldStorage, resource: felt252, requester: ContractAddress) -> P {
        self
            .read_member::<
                felt252
            >(
                Model::<PermissionModel>::ptr_from_keys((resource, requester)),
                selector!("permission")
            )
            .try_into()
            .unwrap()
    }

    fn set_permission(
        ref self: WorldStorage, resource: felt252, requester: ContractAddress, permission: P
    ) {
        self
            .write_model(
                @PermissionModel { resource: resource, requester, permission: permission.into() }
            )
    }

    fn set_permissions(
        ref self: WorldStorage, permissions: Array<Permission<P>>){
            let mut array = ArrayTrait::<@PermissionModel>::new();
            for permission in permissions {
                array.append(@permission.into());
            };
            self.write_models(array.span());
        }
}
