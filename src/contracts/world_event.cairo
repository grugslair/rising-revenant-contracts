use risingrevenant::components::world_event::{EventType};


#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn create(self: @TContractState, game_id: u128, event_type: EventType) -> u128;
}

#[dojo::contract]
mod world_event_actions {
    use risingrevenant::components::world_event::{WorldEvent, EventType};

    use risingrevenant::systems::game::{GameAction};
    use risingrevenant::systems::world_event::{WorldEventTrait};
    use super::IWorldEventActions;

    #[abi(embed_v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn create(self: @ContractState, game_id: u128, event_type: EventType) -> u128 {
            let game_action = GameAction { game_id, world: self.world_dispatcher.read() };
            game_action.new_world_event(event_type).event_id
        }
    }
}
