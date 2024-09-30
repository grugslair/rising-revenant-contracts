#[dojo::interface]
trait IWorldEventActions {
    fn new_event(self: IWorldDispatcher, event: felt252);
}


#[dojo::contract]
mod world_events {
    use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
    use risingrevenant::{
        models::{GameSetup, GameSetupStore},
        world_events::{models::{CurrentEvent, WorldEvent}, systems::WorldEvenTrait}
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
            self.generate_event(game_id, game_setup.map_size, randomness).set(self);
        }
    }
}
