use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::world_event::{
    WorldEventSetup, CurrentWorldEvent, CurrentWorldEventTrait
};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::position::{PositionGeneratorTrait};


#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    fn new_world_event(self: GameAction) {
        self.assert_playing();
        let event_setup: WorldEventSetup = self.get_game();
        let last_event: CurrentWorldEvent = self.get_game();

        let next_event_id = self.uuid();
        let event = CurrentWorldEvent {
            game_id: self.game_id,
            event_id: next_event_id,
            position: PositionGeneratorTrait::single(self),
            radius: last_event.radius + event_setup.radius_increase,
            number: last_event.number,
            block_number: starknet::get_block_info().unbox().block_number,
            previous_event: last_event.event_id,
        };
        set!(self.world, (event, last_event.to_event(next_event_id)));
    }
    fn get_current_event(self: GameAction) -> CurrentWorldEvent {
        self.get_game()
    }
}
