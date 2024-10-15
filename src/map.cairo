use dojo::world::IWorldDispatcher;
use rising_revenant::{utils::felt252_to_u128, core::{ToNonZero, BoundedT}};
use core::{
    num::traits::Bounded, integer::{u128_safe_divmod, u32_safe_divmod}, zeroable::NonZero,
    hash::HashStateTrait, poseidon::{HashState}
};


#[derive(Drop, Serde, Copy, Introspect, Default,)]
struct Point {
    x: u16,
    y: u16,
}


impl PointIntoFelt252 of Into<Point, felt252> {
    #[inline(always)]
    fn into(self: Point) -> felt252 {
        (self.x.into() * 0x10000_u32 + self.y.into()).into()
    }
}

impl Felt252TryIntoPoint of TryInto<felt252, Point> {
    #[inline(always)]
    fn try_into(self: felt252) -> Option<Point> {
        match self.try_into() {
            Option::Some(value) => {
                let (x, y) = u32_safe_divmod(value, 0x10000_u32.non_zero());
                Option::Some(Point { x: x.try_into().unwrap(), y: y.try_into().unwrap() })
            },
            Option::None => Option::None,
        }
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

impl U128PointImpl of GeneratePointTrait<u128> {
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

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct MapSize {
    #[key]
    game_id: felt252,
    size: Point,
}


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct Map {
    #[key]
    game_id: felt252,
    #[key]
    position: Point,
    outpost: felt252,
}


#[generate_trait]
impl MapImpl of MapTrait {
    fn is_position_empty(self: @IWorldDispatcher, game_id: felt252, position: Point) -> bool {
        MapStore::get_outpost(*self, game_id, position).is_zero()
    }
    fn get_empty_point(self: @IWorldDispatcher, game_id: felt252, mut hash: HashState) -> Point {
        let map_size: Point = MapSizeStore::get_size(*self, game_id);

        loop {
            let point = map_size.generate_point(hash.finalize());
            if self.is_position_empty(game_id, point) {
                break point;
            }
            hash = hash.update('butter');
        }
    }
}
