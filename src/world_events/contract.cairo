use dojo::{world::WorldStorage, model::ModelStorage};

#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn new_event(ref self: TContractState, game_id: felt252);
}


#[dojo::contract]
mod world_event_actions {
    use starknet::get_block_timestamp;
    use dojo::model::ModelStorage;
    use rising_revenant::{
        game::GameTrait, map::MapTrait,
        world_events::{
            models::{CurrentEvent, WorldEventType, CurrentEventTrait, WorldEventSetupTrait},
            systems::WorldEventTrait
        },
        contribution::{ContributionTrait, ContributionEvent}, vrf::{VRF, Source},
        world::default_namespace,
    };
    use super::{IWorldEventActions};

    #[abi(embed_v0)]
    impl WorldEventActionsImpl of IWorldEventActions<ContractState> {
        fn new_event(ref self: ContractState, game_id: felt252) {
            let mut world = self.world(default_namespace());
            world.assert_playing(game_id);

            let current_event = world.get_current_event(game_id);
            let randomness = world.randomness(Source::Salt(current_event.event_id));
            let event_setup = world.get_world_event_setup(game_id);
            let time_stamp = get_block_timestamp();
            assert(
                current_event.time_stamp + event_setup.min_interval >= time_stamp, 'Event too soon'
            );

            world.increase_caller_contribution(game_id, ContributionEvent::EventCreated);
            world
                .write_model(
                    @event_setup
                        .generate_event(
                            current_event, world.get_map_size(game_id), randomness, time_stamp
                        )
                );
        }
    }
}
