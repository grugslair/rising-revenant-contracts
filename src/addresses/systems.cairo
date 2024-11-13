use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Address {
    #[key]
    name: felt252,
    address: ContractAddress
}

trait AddressBook<T> {
    fn get_address(self: @WorldStorage, name: T) -> ContractAddress;
}

trait AddressSelectorTrait<T> {
    fn get_address_selector(self: @T) -> felt252;
}

trait GetDispatcher<D> {
    fn get_dispatcher(self: @WorldStorage) -> D;
}

impl AddressBookImpl of AddressBook<felt252> {
    fn get_address(self: @WorldStorage, name: felt252) -> ContractAddress {
        self.read_member(Model::<Address>::ptr_from_keys(name), selector!("address"))
    }
}


impl AddressBookObjImpl<T, +AddressSelectorTrait<T>, +Drop<T>> of AddressBook<T> {
    fn get_address(self: @WorldStorage, name: T) -> ContractAddress {
        self.get_address(name.get_address_selector())
    }
}

