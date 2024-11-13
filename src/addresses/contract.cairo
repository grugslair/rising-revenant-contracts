use starknet::ContractAddress;

#[dojo::interface]
trait IAddress<TContractState> {
    fn get_address(self: @ContractState, name: felt252) -> ContractAddress;
    fn set_address(ref self: ContractState, name: felt252, address: ContractAddress);
}

mod address_actions {
    use super::{IAddress, AddressTrait};
    use starknet::ContractAddress;
    use dojo::model::Model;

    #[abi(embed_v0)]
    impl AddressImpl of IAddress<ContractState> {
        fn get_address(self: @ContractState, name: felt252) -> ContractAddress {
            world.get_address(name)
        }

        fn set_address(ref self: ContractState, name: felt252, address: ContractAddress) {
            // TODO: permissions
            Address { name, address }.set(self)
        }
    }
}
