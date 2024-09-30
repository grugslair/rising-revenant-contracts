use rising_revenant::{utils::felt252_to_u128, core::{ToNonZero, BoundedT}};
use core::{integer::u128_safe_divmod, zeroable::NonZero};


#[derive(Drop, Serde, Copy, Introspect, Default)]
struct Point {
    x: u16,
    y: u16,
}

impl PointIntoFelt252 of Into<Point, felt252> {
    #[inline(always)]
    fn into(self: Point) -> felt252 {
        (self.x.into() * BoundedT::<u16, u32>::max() + self.y.into()).into()
    }
}


fn abs_sub<T, +PartialOrd<T>, +Sub<T>, +Copy<T>, +Drop<T>>(lhs: T, rhs: T) -> T {
    if lhs < rhs {
        rhs - lhs
    } else {
        lhs - rhs
    }
}
#[generate_trait]
impl PointImpl of PointTrait {
    fn in_range(self: @Point, other: Point, range_sq: u32) -> bool {
        let dx: u64 = abs_sub((*self).x, other.x).into();
        let dy: u64 = abs_sub((*self).y, other.y).into();

        dx * dx + dy * dy <= range_sq.into()
    }
}

trait GeneratePointTrait<T> {
    fn generate_point(self: @Point, seed: T) -> Point;
}

impl U182PointImpl of GeneratePointTrait<u128> {
    #[inline(always)]
    fn generate_point(self: @Point, seed: u128) -> Point {
        let (seed, x) = u128_safe_divmod(seed, (*self.x).non_zero());
        let (_, y) = u128_safe_divmod(seed, (*self.y).non_zero());
        Point { x: x.try_into().unwrap(), y: y.try_into().unwrap() }
    }
}

impl Felt252PointImpl of GeneratePointTrait<felt252> {
    #[inline(always)]
    fn generate_point(self: @Point, seed: felt252) -> Point {
        self.generate_point(felt252_to_u128(seed))
    }
}

