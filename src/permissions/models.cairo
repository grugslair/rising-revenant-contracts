use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ContractPermissionsModel {
    #[key]
    owner: ContractAddress,
    #[key]
    resource: felt252,
    #[key]
    requester: felt252,
    permissions: felt252,
}

#[generate_trait]
impl PermissionsStoreImpl of PermissionsStore {
    fn get_permissions(
        self: @IWorldDispatcher, owner: ContractAddress, resource: felt252, requester: felt252
    ) -> felt252 {
        ContractPermissionsModelStore::get_permissions(*self, owner, resource, requester)
    }
    fn set_permissions(
        self: IWorldDispatcher,
        owner: ContractAddress,
        resource: felt252,
        requester: felt252,
        permissions: felt252
    ) {
        ContractPermissionsModel { owner, resource, requester, permissions }.set(self);
    }
}
