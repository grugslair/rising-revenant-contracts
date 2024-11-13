use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::core::{BoolIntoFelt252Impl, Felt252TryIntoBoolImpl};

mod models {
    use starknet::ContractAddress;
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


trait Permissions<P> {
    fn get_permissions(self: @WorldStorage, resource: felt252, requester: ContractAddress) -> P;
}

trait WritePermissions<P> {
    fn set_permissions(
        ref self: WorldStorage, resource: felt252, requester: ContractAddress, permissions: P
    );
}

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

