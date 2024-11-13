use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};

// use cartridge_vrf::{IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source};
use rising_revenant::{
    addresses::{AddressBook,}, address_selectors::VRF_ADDRESS_SELECTOR, utils::felt252_to_u128
};

#[derive(Drop, Copy, Clone, Serde)]
enum Source {
    Nonce: ContractAddress,
    Salt: felt252,
}

#[derive(Copy, Drop, Serde)]
struct Point {
    x: felt252,
    y: felt252,
}

#[derive(Drop, Copy, Clone, Serde)]
struct PublicKey {
    x: felt252,
    y: felt252,
}

#[derive(Clone, Drop, Serde)]
struct Proof {
    gamma: Point,
    c: felt252,
    s: felt252,
    sqrt_ratio_hint: felt252,
}

#[starknet::interface]
trait IVrfProvider<TContractState> {
    fn request_random(self: @TContractState, caller: ContractAddress, source: Source);
    fn submit_random(ref self: TContractState, seed: felt252, proof: Proof);
    fn consume_random(ref self: TContractState, source: Source) -> felt252;
    fn assert_consumed(ref self: TContractState, seed: felt252);

    fn get_public_key(self: @TContractState) -> PublicKey;
    fn set_public_key(ref self: TContractState, new_pubkey: PublicKey);
}

#[generate_trait]
impl VrfProviderImpl of GetDispatcher {
    fn get_dispatcher(self: @WorldStorage) -> IVrfProviderDispatcher {
        IVrfProviderDispatcher { contract_address: self.get_address(VRF_ADDRESS_SELECTOR) }
    }
}

trait VRF {
    fn randomness(ref self: WorldStorage, key: Source) -> felt252;
    fn random_u128(ref self: WorldStorage, key: Source) -> u128;
    fn random_range<T, +TryInto<u128, T>, +Into<T, u128>, +Drop<T>>(
        ref self: WorldStorage, key: Source, range: T
    ) -> T;
}


impl VrfImpl of VRF {
    fn randomness(ref self: WorldStorage, key: Source) -> felt252 {
        VrfProviderImpl::get_dispatcher(@self).consume_random(key)
    }
    fn random_u128(ref self: WorldStorage, key: Source) -> u128 {
        felt252_to_u128(self.randomness(key))
    }
    fn random_range<T, +TryInto<u128, T>, +Into<T, u128>, +Drop<T>>(
        ref self: WorldStorage, key: Source, range: T
    ) -> T {
        (self.random_u128(key) % range.into()).try_into().unwrap()
    }
}
