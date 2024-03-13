use risingrevenant::components::world_event::{EventType};


#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn random(self: @TContractState, game_id: u128) -> u128;
}

#[dojo::contract]
mod world_event_actions {
    use core::option::OptionTrait;
    use risingrevenant::components::world_event::{WorldEvent, EventType};

    use risingrevenant::systems::game::{GameAction};
    use risingrevenant::systems::world_event::{WorldEventTrait};

    use risingrevenant::utils::random::{Random, RandomTrait};

    use super::IWorldEventActions;

    #[external(v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn random(self: @ContractState, game_id: u128) -> u128 {
            let game_action = GameAction { game_id, world: self.world_dispatcher.read() };
            let mut random = RandomTrait::new();
            let event_type = (random.next_capped(3) + 1_u8).try_into().unwrap();
            game_action.new_world_event(event_type).event_id
        }
    }
}
