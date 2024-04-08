use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::world_event::{
    WorldEventSetup, CurrentWorldEvent, CurrentWorldEventTrait, EventType, WorldEventVerifications
};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::position::{PositionGeneratorTrait};


#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    fn new_world_event(self: GameAction, event_type: EventType) -> CurrentWorldEvent {
        self.assert_playing();
        let event_setup: WorldEventSetup = self.get_game();
        let last_event: CurrentWorldEvent = self.get_game();
        let next_event_id = self.uuid();
        let mut radius: u32 = last_event.radius;
        if radius.is_zero() {
            radius = event_setup.radius_start;
        }

        let mut verifications: WorldEventVerifications = self.get_game();
        let n_verifications = verifications.verifications;
        if n_verifications == 0 {
            radius += event_setup.radius_increase;
        } else {
            verifications.verifications = 0;
            self.set(verifications);
        }
        let event = CurrentWorldEvent {
            game_id: self.game_id,
            event_id: next_event_id,
            position: PositionGeneratorTrait::single(self),
            event_type,
            radius,
            number: last_event.number + 1,
            block_number: starknet::get_block_info().unbox().block_number,
            previous_event: last_event.event_id,
        };
        let last_world_event = last_event.to_event(next_event_id, n_verifications);
        self.set(event);
        self.set(last_world_event);

        event
    }
    fn get_current_event(self: GameAction) -> CurrentWorldEvent {
        self.get_game()
    }
}
