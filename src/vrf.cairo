use dojo::world::IWorldDispatcher;
use cartridge_vrf::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};
use rising_revenant::{addresses::{AddressBook,}, address_selectors::VRF_ADDRESS_SELECTOR, utils::felt252_to_u128};


#[generate_trait]
impl VrfProviderImpl of GetDispatcher {
    fn get_dispatcher(self: @IWorldDispatcher) -> IVrfProviderDispatcher {
        IVrfProviderDispatcher {
            contract_address: self.get_address(VRF_ADDRESS_SELECTOR)
        }
    }
}

trait VRF {
    fn randomness(self: IWorldDispatcher, key: Source) -> felt252;
    fn random_u128(self: IWorldDispatcher, key: Source) -> u128;
    fn random_range<T, +TryInto<u128, T>, +Into<T, u128>, +Drop<T>>(self: IWorldDispatcher, key: Source, range: T) -> T;
}


impl VrfImpl of VRF {
    fn randomness(self: IWorldDispatcher, key: Source) -> felt252 {
        VrfProviderImpl::get_dispatcher(@self).consume_random(key)
    }
    fn random_u128(self: IWorldDispatcher, key: Source) -> u128 {
        felt252_to_u128(self.randomness(key))
    }
    fn random_range<T, +TryInto<u128, T>, +Into<T, u128>, +Drop<T>>(self: IWorldDispatcher, key: Source, range: T) -> T {
        (self.random_u128(key) % range.into()).try_into().unwrap()
    }
}