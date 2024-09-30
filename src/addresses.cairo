use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};

const GAME_TOKEN_SELECTOR: felt252 = 'game-token';

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


mod selectors{
    const GAME_TOKEN: felt252 = 'game-currency';
    const GAME_WALLET: felt252 = 'game-wallet';
}