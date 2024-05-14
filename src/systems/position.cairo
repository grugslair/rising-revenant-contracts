use core::traits::Into;
use cubit::f128::types::fixed::{FixedTrait, Fixed};
use risingrevenant::{
    components::game::{Position, Dimensions}, utils::random::{RandomTrait, RandomGenerator}
};


fn calculate_distance(position1: Position, position2: Position) -> Fixed {
    let mut diff_x: Fixed = position1.x.into() - position2.x.into();
    let mut diff_y: Fixed = position1.y.into() - position2.y.into();
    (diff_x.pow(2_u8.into()) + diff_y.pow(2_u8.into())).sqrt()
}

#[derive(Copy, Drop)]
struct PositionGenerator {
    generator: RandomGenerator,
    map_dims: Dimensions
}

#[generate_trait]
impl PositionImpl of PositionGeneratorTrait {
    fn new(ref generator: RandomGenerator, map_dims: Dimensions) -> PositionGenerator {
        PositionGenerator { generator, map_dims }
    }
    fn next(ref self: PositionGenerator) -> Position {
        Position {
            x: self.generator.next_capped(self.map_dims.x),
            y: self.generator.next_capped(self.map_dims.y)
        }
    }
}
