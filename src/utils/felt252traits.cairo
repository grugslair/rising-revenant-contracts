use core::{integer::BoundedInt, traits::{BitAnd, Rem}};

impl BitAndFelt252Impl of BitAnd<felt252> {
    fn bitand(lhs: felt252, rhs: felt252) -> felt252 {
        let lhs_u256: u256 = lhs.into();
        let rhs_u256: u256 = rhs.into();
        (lhs_u256 & rhs_u256).try_into().unwrap()
    }
}

impl RemFelt252Impl of Rem<felt252> {
    fn rem(lhs: felt252, rhs: felt252) -> felt252 {
        let lhs_u256: u256 = lhs.into();
        let rhs_u256: u256 = rhs.into();
        (lhs_u256 % rhs_u256).try_into().unwrap()
    }
}


trait TruncateTrait<S, T> {
    fn truncate(self: S) -> T;
}

impl TruncateFelt252Impl<
    T, +BoundedInt<T>, +Into<T, felt252>, +TryInto<felt252, T>
> of TruncateTrait<felt252, T> {
    fn truncate(self: felt252) -> T {
        (BoundedInt::<T>::max().into() & self).try_into().unwrap()
    }
}


impl TruncateFelt252ToU8 = TruncateFelt252Impl<u8>;
impl TruncateFelt252ToU16 = TruncateFelt252Impl<u16>;
impl TruncateFelt252ToU32 = TruncateFelt252Impl<u32>;
impl TruncateFelt252ToU64 = TruncateFelt252Impl<u64>;
impl TruncateFelt252ToU128 = TruncateFelt252Impl<u128>;
