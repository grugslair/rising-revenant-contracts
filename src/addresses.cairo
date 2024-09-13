use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Address {
    #[key]
    name: felt252,
    address: ContractAddress
}

#[generate_trait]
impl GetAddressImpl of GetAddressTrait {
    fn get_address_from_selector(self: @IWorldDispatcher, name: felt252) -> ContractAddress {
        AddressStore::get_address(*self, name)
    }

    fn get_address<T, +AddressSelectorTrait<T>, +Drop<T>>(
        self: @IWorldDispatcher, obj: T
    ) -> ContractAddress {
        self.get_address_from_selector(obj.get_address_selector())
    }
}


trait AddressSelectorTrait<T> {
    fn get_address_selector(self: @T) -> felt252;
}
