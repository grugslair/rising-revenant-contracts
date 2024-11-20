/// Module for managing contract addresses in a World
use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};

/// Represents a named address entry in the World
/// 
/// # Arguments
/// * `name` - Unique identifier for the address entry
/// * `address` - The StarkNet contract address
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Address {
    #[key]
    name: felt252,
    address: ContractAddress
}

/// Trait for retrieving addresses from the World storage
trait AddressBook<T> {
    /// Gets a contract address by its name
    /// 
    /// # Arguments
    /// * `name` - Identifier to look up
    /// 
    /// # Returns
    /// * `ContractAddress` - The associated contract address
    fn get_address(self: @WorldStorage, name: T) -> ContractAddress;
}

/// Trait for converting a type to an address selector
trait AddressSelectorTrait<T> {
    /// Converts the type to a felt252 selector
    fn get_address_selector(self: @T) -> felt252;
}

/// Trait for getting a dispatcher instance
trait GetDispatcher<D> {
    /// Returns a dispatcher for the given type
    fn get_dispatcher(self: @WorldStorage) -> D;
}

/// Implementation of AddressBook for felt252 keys
impl AddressBookImpl of AddressBook<felt252> {
    fn get_address(self: @WorldStorage, name: felt252) -> ContractAddress {
        self.read_member(Model::<Address>::ptr_from_keys(name), selector!("address"))
    }
}

/// Generic implementation of AddressBook for types that implement AddressSelectorTrait
impl AddressBookObjImpl<T, +AddressSelectorTrait<T>, +Drop<T>> of AddressBook<T> {
    fn get_address(self: @WorldStorage, name: T) -> ContractAddress {
        self.get_address(name.get_address_selector())
    }
}

