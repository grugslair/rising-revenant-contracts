use starknet::get_block_number;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::{
    components::world_event::{
        WorldEventSetup, CurrentWorldEvent, CurrentWorldEventTrait, EventType,
        WorldEventVerifications
    },
    systems::{game::{GameAction, GameActionTrait}, position::{Position, PositionGeneratorTrait}}
};


#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    fn new_random_event(self: GameAction, seed: felt252) {}
    fn new_world_event(
        self: GameAction, event_type: EventType, position: Position
    ) -> CurrentWorldEvent {
        self.assert_playing();
        let event_setup: WorldEventSetup = self.get_game();
        let last_event: CurrentWorldEvent = self.get_game();
        let next_event_id = self.uuid();
        let mut radius: u32 = last_event.radius;

        if radius.is_zero() {
            radius = event_setup.radius_start;
        } else {
            let mut verifications: WorldEventVerifications = self.get_game();
            let n_verifications = verifications.verifications;
            if n_verifications == 0 {
                radius += event_setup.radius_increase;
            } else {
                verifications.verifications = 0;
                self.set(verifications);
            }
            let last_world_event = last_event.to_event(next_event_id, n_verifications);
            self.set(last_world_event);
        }

        let event = CurrentWorldEvent {
            game_id: self.game_id,
            event_id: next_event_id,
            position: position,
            event_type,
            radius,
            number: last_event.number + 1,
            block_number: get_block_number(),
            previous_event: last_event.event_id,
        };

        self.set(event);

        event
    }
    fn get_current_event(self: GameAction) -> CurrentWorldEvent {
        self.get_game()
    }
}
