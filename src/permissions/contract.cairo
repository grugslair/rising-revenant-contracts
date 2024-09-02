use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;

#[dojo::interface]
trait IPemissionsCore<TContractState> {
    fn get_permissions(world: @IWorldDispatcher, resource: felt252, requester: felt252) -> felt252;
    fn set_permissions(
        ref world: IWorldDispatcher, resource: felt252, requester: felt252, permissions: felt252
    );
}


#[dojo::contract]
mod permissions_core {
    use starknet::{ContractAddress, get_caller_address};
    use super::super::models::{PermissionsStore};
    use super::{IPemissionsCore};

    #[abi(embed_v0)]
    impl IPemissionsCoreImpl of IPemissionsCore<ContractState> {
        fn get_permissions(
            world: @IWorldDispatcher, resource: felt252, requester: felt252
        ) -> felt252 {
            world.get_permissions(get_caller_address(), resource, requester)
        }
        fn set_permissions(
            ref world: IWorldDispatcher, resource: felt252, requester: felt252, permissions: felt252
        ) {
            
            world.set_permissions(get_caller_address(), resource, requester, permissions);
        }
    }
}
