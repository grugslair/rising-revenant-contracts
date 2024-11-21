use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState, poseidon_hash_span},
    fmt::{Display, Formatter, Error, Debug}, integer::u128_safe_divmod
};
use starknet::{
    ContractAddress, get_contract_address, get_caller_address, get_tx_info, get_block_timestamp,
    StorageAddress, StorageBaseAddress, syscalls::{storage_read_syscall, storage_write_syscall},
    storage_address_from_base
};
use rising_revenant::{core::{Felt252BitAnd, BoundedT}};

fn storage_read(address: StorageAddress) -> felt252 {
    storage_read_syscall(0, address).unwrap()
}

fn storage_write(address: StorageAddress, value: felt252) {
    storage_write_syscall(0, address, value).unwrap()
}

fn felt252_to_u128(value: felt252) -> u128 {
    Into::<felt252, u256>::into(value).low
}

impl TDebugImpl<T, +Display<T>> of Debug<T> {
    fn fmt(self: @T, ref f: Formatter) -> Result<(), Error> {
        Display::fmt(self, ref f)
    }
}

fn clipped_felt252<T, +Bounded<T>, +Into<T, u128>, +TryInto<u128, T>>(value: felt252) -> T {
    (BoundedT::<T, u128>::max() & felt252_to_u128(value)).try_into().unwrap()
}

trait SeedProbability {
    fn get_outcome<T, +Into<T, u128>>(ref self: u128, scale: NonZero<u128>, probability: T) -> bool;
    fn get_value(ref self: u128, scale: NonZero<u128>) -> u128;
}

impl SeedProbabilityImpl of SeedProbability {
    fn get_outcome<T, +Into<T, u128>>(
        ref self: u128, scale: NonZero<u128>, probability: T
    ) -> bool {
        let (seed, value) = u128_safe_divmod(self, scale);
        self = seed;
        value < probability.into()
    }

    fn get_value(ref self: u128, scale: NonZero<u128>) -> u128 {
        let (seed, value) = u128_safe_divmod(self, scale);
        self = seed;
        value
    }
}

