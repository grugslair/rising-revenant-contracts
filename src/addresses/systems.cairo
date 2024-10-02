use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Address {
    #[key]
    name: felt252,
    address: ContractAddress
}

trait AddressBook<T> {
    fn get_address(self: @IWorldDispatcher, name: T) -> ContractAddress;
}

trait AddressSelectorTrait<T> {
    fn get_address_selector(self: @T) -> felt252;
}

trait GetDispatcher<D> {
    fn get_dispatcher(self: @IWorldDispatcher) -> D;
}

impl AddressBookImpl of AddressBook<felt252> {
    fn get_address(self: @IWorldDispatcher, name: felt252) -> ContractAddress {
        AddressStore::get_address(*self, name)
    }
}


impl AddressBookObjImpl<T, +AddressSelectorTrait<T>, +Drop<T>> of AddressBook<T> {
    fn get_address(self: @IWorldDispatcher, name: T) -> ContractAddress {
        self.get_address(name.get_address_selector())
    }
}

