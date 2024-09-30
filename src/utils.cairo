use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState}
};
use rising_revenant::core::BoundedT;
fn felt252_to_u128(value: felt252) -> u128 {
    Into::<felt252, u256>::into(value).low
}

impl Felt252IntoU128 of Into<felt252, u128> {
    #[inline(always)]
    fn into(self: felt252) -> u128 {
        felt252_to_u128(self)
    }
}

fn clipped_felt252<T, +Bounded<T>, +Into<T, u128>, +TryInto<u128, T>>(value: felt252) -> T {
    (BoundedT::<T, u128>::max() & felt252_to_u128(value)).try_into().unwrap()
}

fn hash_value<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> felt252 {
    PoseidonTrait::new().update_with(value).finalize()
}

fn get_hash_state<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> HashState {
    PoseidonTrait::new().update_with(value)
}

trait ToHash<T> {
    fn to_hash(self: @HashState, value: T) -> felt252;
}


impl TToHashImpl<T, +Hash<T, HashState>, +Drop<T>> of ToHash<T> {
    fn to_hash(self: @HashState, value: T) -> felt252 {
        (*self).update_with(value).finalize()
    }
}


impl Felt252ToHashImpl<T, +Into<T, felt252>> of ToHash<T> {
    fn to_hash(self: @HashState, value: T) -> felt252 {
        (*self).update(value.into()).finalize()
    }
}
