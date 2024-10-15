use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;
use rising_revenant::core::{BoolIntoFelt252Impl, Felt252TryIntoBoolImpl};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PermissionsModel {
    #[key]
    resource: felt252,
    #[key]
    requester: ContractAddress,
    permissions: felt252,
}

trait Permissions<R, P> {
    fn get_permissions(self: @IWorldDispatcher, resource: R, requester: ContractAddress) -> P;
}

trait WritePermissions<R, P> {
    fn set_permissions(
        self: IWorldDispatcher, resource: R, requester: ContractAddress, permissions: P
    );
}

impl PermissionsImpl<R, P, +Into<R, felt252>, +TryInto<felt252, P>> of Permissions<R, P> {
    fn get_permissions(self: @IWorldDispatcher, resource: R, requester: ContractAddress) -> P {
        PermissionsModelStore::get_permissions(*self, resource.into(), requester)
            .try_into()
            .unwrap()
    }
}

impl WritePermissionsImpl<
    R, P, +Into<R, felt252>, +Into<P, felt252>, +Drop<P>
> of WritePermissions<R, P> {
    fn set_permissions(
        self: IWorldDispatcher, resource: R, requester: ContractAddress, permissions: P
    ) {
        PermissionsModel { resource: resource.into(), requester, permissions: permissions.into() }
            .set(self)
    }
}

