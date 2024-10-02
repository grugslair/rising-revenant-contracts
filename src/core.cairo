use core::num::traits::Bounded;

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

trait SubBounded<T, S> {
    fn sub_bounded(self: T, rhs: S) -> S;
    fn subeq_bounded(ref self: T, rhs: S);
}

impl TSubBoundedImpl<
    T, +Bounded<T>, +Sub<T>, +PartialOrd<T>, +Copy<T>, +Drop<T>, +Add<T>
> of SubBounded<T, T> {
    fn sub_bounded(self: T, rhs: T) -> T {
        if rhs < self + Bounded::MIN {
            self - rhs
        } else {
            Bounded::MIN
        }
    }

    fn subeq_bounded(ref self: T, rhs: T) {
        self = self.sub_bounded(rhs)
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
