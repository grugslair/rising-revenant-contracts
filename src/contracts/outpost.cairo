use risingrevenant::components::game::{Position};
use risingrevenant::components::reinforcement::{ReinforcementType};
use risingrevenant::components::outpost::{OutpostEventStatus};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[starknet::interface]
trait IOutpostActions<TContractState> {
    fn purchase(self: @TContractState, world: IWorldDispatcher, game_id: u128) -> Position;
    fn get_price(self: @TContractState, world: IWorldDispatcher, game_id: u128) -> u256;
    fn reinforce(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u128,
        outpost_id: Position,
        count: u32
    );
    fn verify(self: @TContractState, world: IWorldDispatcher, game_id: u128, outpost_id: Position);
    fn set_reinforcement_type(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u128,
        outpost_id: Position,
        reinforcement_type: ReinforcementType
    );
    fn get_event_status(
        self: @TContractState, world: IWorldDispatcher, game_id: u128, outpost_id: Position
    ) -> OutpostEventStatus;
}


#[starknet::contract]
mod outpost_actions {
    use super::IOutpostActions;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use risingrevenant::components::outpost::{OutpostTrait, OutpostEventStatus};
    use risingrevenant::components::game::{Position};
    use risingrevenant::components::player::{PlayerInfo};
    use risingrevenant::components::reinforcement::{ReinforcementType};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::player::{PlayerActionsTrait};
    use risingrevenant::systems::payment::{PaymentSystemTrait};
    use risingrevenant::systems::outpost::{OutpostActionsTrait};

    #[storage]
    struct Storage {}
    #[abi(embed_v0)]
    impl OutpostActionsImpl of IOutpostActions<ContractState> {
        fn purchase(self: @ContractState, world: IWorldDispatcher, game_id: u128) -> Position {
            let outpost_action = GameAction { world, game_id };
            outpost_action.purchase_outpost().position
        }

        fn get_price(self: @ContractState, world: IWorldDispatcher, game_id: u128) -> u256 {
            GameAction { world, game_id }.get_outpost_price()
        }

        fn reinforce(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            outpost_id: Position,
            count: u32
        ) {
            let outpost_action = GameAction { world, game_id };
            outpost_action.reinforce_outpost(outpost_id, count);
        }

        fn verify(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, outpost_id: Position
        ) {
            let outpost_action = GameAction { world, game_id };
            outpost_action.verify_outpost(outpost_id);
        }
        fn set_reinforcement_type(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            outpost_id: Position,
            reinforcement_type: ReinforcementType
        ) {
            let outpost_action = GameAction { world, game_id };
            outpost_action.set_outpost_reinforcement_type(outpost_id, reinforcement_type);
        }
        fn get_event_status(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, outpost_id: Position
        ) -> OutpostEventStatus {
            let outpost_action = GameAction { world, game_id };
            outpost_action.get_outpost_event_status(outpost_id)
        }
    }
}
