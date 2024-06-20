use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::world_event::{EventType};


#[dojo::interface]
trait IWorldEventActions {
    fn random(ref world: IWorldDispatcher, game_id: u128) -> u128;
}

#[dojo::contract]
mod world_event_actions {
    use risingrevenant::systems::game::GameActionTrait;
    use starknet::{get_caller_address};

    use risingrevenant::components::world_event::{WorldEvent, EventType};

    use risingrevenant::systems::game::{GameAction};
    use risingrevenant::systems::world_event::{WorldEventTrait};

    use risingrevenant::utils::random::{Random, RandomTrait};

    use super::IWorldEventActions;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn random(ref world: IWorldDispatcher, game_id: u128) -> u128 {
            let game_action = GameAction { game_id, world };
            let caller = get_caller_address();
            world.assert_is_admin(caller);
            let mut random = RandomTrait::new();
            let event_type = (random.next_capped(3) + 1_u8).try_into().unwrap();
            game_action.new_world_event(event_type).event_id
        }
    }
}
