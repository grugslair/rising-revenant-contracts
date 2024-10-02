#[dojo::interface]
trait IWorldEventActions {
    fn new_event(self: IWorldDispatcher, event: felt252);
}


#[dojo::contract]
mod world_event_actions {
    use starknet::get_block_timestamp;
    use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
    use risingrevenant::{
        models::{GameSetup, GameSetupStore},
        world_events::{
            models::{CurrentEvent, WorldEventType, CurrentEventTrait, WorldEventSetupTrait},
            systems::WorldEvenTrait
        },
        contribution::{ContributionTrait, ContributionEvent},
    };
    use super::{IWorldEventActions};

    #[abi(embed_v0)]
    impl WorldEventActionsImpl of IWorldEventActions {
        fn new_event(self: IWorldDispatcher, event: felt252) {}
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn new_event(self: IWorldDispatcher, game_id: felt252, randomness: felt252) {
            let game_setup = GameSetupStore::get(self, game_id);
            game_setup.assert_playing();

            let current_event = self.get_current_event(game_id);
            let event_setup = self.get_world_event_setup(game_id);
            assert(
                current_event.time_stamp + event_setup.max_frequency > get_block_timestamp(),
                'Event too soon'
            );

            self.increase_caller_contribution(ContributionEvent::EventCreated);
            self.generate_event(game_id, randomness).set(self);
        }
    }
}
