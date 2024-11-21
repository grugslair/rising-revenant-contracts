use dojo::{world::WorldStorage, model::ModelStorage};

/// Interface for World Event actions that can be performed in the game
#[starknet::interface]
trait IWorldEventActions<TContractState> {
    /// Creates a new world event for the specified game
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    fn new_event(ref self: TContractState, game_id: felt252);
}


/// Contract implementation for handling world events in the game
#[dojo::contract]
mod world_event_actions {
    use starknet::get_block_timestamp;
    use dojo::model::ModelStorage;
    use rising_revenant::{
        game::GameTrait, map::MapTrait,
        world_events::{
            models::{CurrentEvent, WorldEventType, WorldEventSetupTrait}, systems::WorldEventTrait
        },
        contribution::{ContributionTrait, ContributionEvent}, vrf::{VRF, Source},
        world::default_namespace, hash::hash_value
    };
    use super::{IWorldEventActions};

    /// Implementation of World Event actions
    /// Handles the creation and management of world events within the game
    #[abi(embed_v0)]
    impl WorldEventActionsImpl of IWorldEventActions<ContractState> {
        /// Creates a new world event for the specified game
        /// # Arguments
        /// * `game_id` - The unique identifier of the game
        /// # Panics
        /// * If the game is not in playing state
        /// * If attempting to create an event too soon after the previous one
        fn new_event(ref self: ContractState, game_id: felt252) {
            let mut world = self.world(default_namespace());
            world.assert_playing(game_id);
            let timestamp = get_block_timestamp();
            let min_interval = world.get_min_interval(game_id);
            let last_event = world.get_current_event(game_id);
            assert(last_event.timestamp + min_interval >= timestamp, 'Event too soon');
            let randomness = world
                .randomness(Source::Salt(hash_value((game_id, last_event.event_id))));
            let map_size = world.get_map_size(game_id);
            let (event, event_of_type) = world
                .generate_event(last_event, map_size, randomness, timestamp);

            world.write_model(@event);
            world.write_model(@event_of_type);
            world.increase_caller_contribution(game_id, ContributionEvent::EventCreated);
        }
    }
}
