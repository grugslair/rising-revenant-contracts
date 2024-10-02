use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};

#[dojo::interface]
trait IAddress<TContractState> {
    fn get_address(world: @IWorldDispatcher, name: felt252) -> ContractAddress;
    fn set_address(ref world: IWorldDispatcher, name: felt252, address: ContractAddress);
}

mod address_actions {
    use super::{IAddress, AddressTrait};
    use starknet::ContractAddress;
    use dojo::model::Model;

    #[abi(embed_v0)]
    impl AddressImpl of IAddress<ContractState> {
        fn get_address(world: @IWorldDispatcher, name: felt252) -> ContractAddress {
            world.get_address(name)
        }

        fn set_address(ref world: IWorldDispatcher, name: felt252, address: ContractAddress) {
            Address { name, address }.set(self)
        }
    }
}
