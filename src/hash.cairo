use core::{
    hash::{Hash, HashStateExTrait, HashStateTrait}, poseidon::HashState, poseidon::PoseidonTrait,
    num::traits::Bounded
};

use rising_revenant::utils::felt252_to_u128;

trait HashUpdate<T> {
    fn update_hash_state(ref self: HashState, value: T);
}

impl HashUpdateImpl<T, +Hash<T, HashState>, +Drop<T>> of HashUpdate<T> {
    fn update_hash_state(ref self: HashState, value: T) {
        self = Hash::update_state(self, value);
    }
}

impl ArrayHash<
    T, S, +hash::HashStateTrait<S>, +hash::Hash<T, S>, +Drop<Array<T>>, +Drop<S>
> of Hash<Array<T>, S> {
    fn update_state(mut state: S, mut value: Array<T>) -> S {
        loop {
            match value.pop_front() {
                Option::Some(v) => { state = Hash::update_state(state, v); },
                Option::None => { break; },
            }
        };
        state
    }
}

impl SpanHash<
    T, S, +hash::HashStateTrait<S>, +hash::Hash<T, S>, +Drop<Array<T>>, +Drop<S>, +Copy<T>,
> of Hash<Span<T>, S> {
    fn update_state(mut state: S, mut value: Span<T>) -> S {
        loop {
            match value.pop_front() {
                Option::Some(v) => { state = Hash::update_state(state, *v); },
                Option::None => { break; },
            }
        };
        state
    }
}
fn get_byte_felts(value: ByteArray) -> Array<felt252> {
    let mut bytes = array![];
    value.serialize(ref bytes);
    let mut array = array![];
    let (mut len, mut n) = (bytes.len() - 1, 1);
    while n < len {
        array.append(*array.at(n));
        n += 1;
    };
    array
}
impl ByteArrayHash<S, +hash::HashStateTrait<S>, +Drop<S>> of Hash<ByteArray, S> {
    fn update_state(mut state: S, value: ByteArray) -> S {
        let mut array = array![];
        value.serialize(ref array);
        let (len, mut n) = (array.len() - 2, 1);
        while n < len {
            state = Hash::update_state(state, *array.at(n));
            n += 1;
        };
        if len > 1 == (*array.at(len + 1)).is_non_zero() {
            state = Hash::update_state(state, *array.at(len));
        }
        state
    }
}


fn hash_value<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> felt252 {
    PoseidonTrait::new().update_with(value).finalize()
}


fn array_to_hash_state<T, +Hash<T, HashState>, +Drop<Array<T>>,>(arr: Array<T>) -> HashState {
    Hash::update_state(PoseidonTrait::new(), arr)
}

fn make_hash_state<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> HashState {
    PoseidonTrait::new().update_with(value)
}

trait ToHash<T> {
    fn update_to(self: @HashState, value: T) -> felt252;
}

impl TToHashImpl<T, +Hash<T, HashState>, +Drop<T>> of ToHash<T> {
    fn update_to(self: @HashState, value: T) -> felt252 {
        (*self).update_with(value).finalize()
    }
}

trait UpdateHashToU128 {
    fn to_u128(self: HashState) -> u128;
    fn update_to_u128<T, +Hash<T, HashState>>(self: HashState, value: T) -> u128;
}

impl HashToU128Impl of UpdateHashToU128 {
    fn to_u128(self: HashState) -> u128 {
        felt252_to_u128(self.finalize())
    }
    fn update_to_u128<T, +Hash<T, HashState>>(self: HashState, value: T) -> u128 {
        Self::to_u128(Hash::update_state(self, value))
    }
}
