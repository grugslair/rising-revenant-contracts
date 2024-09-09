use core::num::traits::Bounded;

fn felt252_to_u128(value: felt252) -> u128 {
    Into::<felt252, u256>::into(value).low
}

fn clipped_felt252<T, +Bounded<T>, +Into<T, u128>, +TryInto<u128, T>>(value: felt252) -> T {
    (Bounded::<T>::MAX.into() & felt252_to_u128(value)).try_into().unwrap()
}

