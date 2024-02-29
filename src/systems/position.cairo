use risingrevenant::components::game::{PositionGenerator, Position, GameMap};

use risingrevenant::systems::game::{GameAction, GameActionTrait};

use risingrevenant::utils::random::{Random, RandomTrait};


#[generate_trait]
impl PositionGeneratorImpl of PositionGeneratorTrait {
    fn new(action: GameAction) -> PositionGenerator {
        PositionGenerator {
            random: RandomTrait::new(), map_dims: action.get_game::<GameMap>().dimensions,
        }
    }
    fn single(action: GameAction) -> Position {
        let mut generator = PositionGeneratorImpl::new(action);
        generator.next()
    }
    fn next(ref self: PositionGenerator) -> Position {
        Position {
            x: self.random.next_capped(self.map_dims.x), y: self.random.next_capped(self.map_dims.y)
        }
    }
}
