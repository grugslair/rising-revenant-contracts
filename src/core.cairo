use core::{
    num::traits::{Bounded, Zero, OverflowingSub, OverflowingAdd, OverflowingMul}, cmp::{min, max}
};

trait BoundedT<T, S> {
    fn min() -> S;
    fn max() -> S;
}

impl BoundedTImpl<T, S, +Bounded<T>, +Into<T, S>> of BoundedT<T, S> {
    fn min() -> S {
        Bounded::<T>::MIN.into()
    }

    fn max() -> S {
        Bounded::<T>::MAX.into()
    }
}

pub trait SaturatingInto<T, S> {
    fn saturating_into(self: T) -> S;
}

pub trait SaturatingAdd<T> {
    /// Saturating addition. Computes `self + other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_add(self: T, other: T) -> T;
}

/// Performs subtraction that saturates at the numeric bounds instead of overflowing.
pub trait SaturatingSub<T> {
    /// Saturating subtraction. Computes `self - other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_sub(self: T, other: T) -> T;
}

/// Performs multiplication that saturates at the numeric bounds instead of overflowing.
pub trait SaturatingMul<T> {
    /// Saturating multiplication. Computes `self * other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_mul(self: T, other: T) -> T;
}

pub impl TSaturatingAdd<
    T, +Drop<T>, +Copy<T>, +OverflowingAdd<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingAdd<T> {
    fn saturating_add(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_add(other);
        match overflow {
            true => { if other < Zero::zero() {
                Bounded::MIN
            } else {
                Bounded::MAX
            } },
            false => result,
        }
    }
}

pub impl TSaturatingSub<
    T, +Drop<T>, +Copy<T>, +OverflowingSub<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingSub<T> {
    fn saturating_sub(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_sub(other);
        match overflow {
            true => { if other < Zero::zero() {
                Bounded::MAX
            } else {
                Bounded::MIN
            } },
            false => result,
        }
    }
}


pub impl TSaturatingMul<
    T, +Drop<T>, +Copy<T>, +OverflowingMul<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingMul<T> {
    fn saturating_mul(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_mul(other);
        match overflow {
            true => {
                if (self < Zero::zero()) == (other < Zero::zero()) {
                    Bounded::MAX
                } else {
                    Bounded::MIN
                }
            },
            false => result,
        }
    }
}

pub impl TSaturatingIntoS<
    T, S, +Drop<T>, +Copy<T>, +TryInto<T, S>, +Bounded<S>, +BoundedT<S, T>, +PartialOrd<T>, +Zero<T>
> of SaturatingInto<T, S> {
    fn saturating_into(self: T) -> S {
        match self.try_into() {
            Option::Some(value) => value,
            Option::None => { if self > Zero::zero() {
                Bounded::MAX
            } else {
                Bounded::MIN
            } }
        }
    }
}


trait ToNonZero<T, S> {
    fn non_zero(self: T) -> NonZero<S>;
}

impl ToNonZeroImpl<T, S, +Into<T, S>, +TryInto<S, NonZero<S>>> of ToNonZero<T, S> {
    fn non_zero(self: T) -> NonZero<S> {
        Into::<T, S>::into(self).try_into().unwrap()
    }
}

impl BoolIntoFelt252Impl of Into<bool, felt252> {
    fn into(self: bool) -> felt252 {
        if self {
            1
        } else {
            0
        }
    }
}

impl Felt252IntoBoolImpl of Into<felt252, bool> {
    fn into(self: felt252) -> bool {
        self != 0
    }
}

impl Felt252TryIntoBoolImpl of TryInto<felt252, bool> {
    fn try_into(self: felt252) -> Option<bool> {
        match self {
            0 => Option::Some(false),
            1 => Option::Some(true),
            _ => Option::None,
        }
    }
}
