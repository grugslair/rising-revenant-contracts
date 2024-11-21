use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::{
    utils::{felt252_to_u128, SeedProbability}, core::{ToNonZero, BoundedT}, hash::UpdateHashToU128
};
use core::{
    num::traits::Bounded, integer::{u128_safe_divmod, u32_safe_divmod}, zeroable::NonZero,
    hash::HashStateTrait, poseidon::{HashState}
};


#[derive(Drop, Serde, Copy, IntrospectPacked, Default,)]
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

#[generate_trait]
impl U128PointImpl of GeneratePointTrait {
    #[inline(always)]
    fn generate_point(ref self: u128, map_size: Point) -> Point {
        Point {
            x: self.get_value(map_size.x.non_zero()).try_into().unwrap(),
            y: self.get_value(map_size.y.non_zero()).try_into().unwrap()
        }
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
    fn get_map_size(self: @WorldStorage, game_id: felt252) -> Point {
        self.read_member(Model::<MapSize>::ptr_from_keys(game_id), selector!("size"))
    }

    fn is_position_empty(self: @WorldStorage, game_id: felt252, position: Point) -> bool {
        self
            .read_member::<
                felt252
            >(Model::<Map>::ptr_from_keys((game_id, position)), selector!("outpost"))
            .is_zero()
    }
    fn get_empty_point(self: @WorldStorage, game_id: felt252, mut hash: HashState) -> Point {
        let map_size = self.get_map_size(game_id);
        let mut seed = hash.to_u128();
        let min_seed: u128 = (map_size.x * map_size.y).into();
        loop {
            if seed < min_seed {
                hash = hash.update('butter');
                seed = hash.to_u128();
            };

            let point = seed.generate_point(map_size);
            if self.is_position_empty(game_id, point) {
                break point;
            }
        }
    }
}
