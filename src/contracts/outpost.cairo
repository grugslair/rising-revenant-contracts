use risingrevenant::components::game::{Position};
use risingrevenant::components::reinforcement::{ReinforcementType};
use risingrevenant::components::outpost::{OutpostEventStatus};


#[starknet::interface]
trait IOutpostActions<TContractState> {
    fn purchase(self: @TContractState, game_id: u128) -> Position;
    fn get_price(self: @TContractState, game_id: u128) -> u256;
    fn reinforce(self: @TContractState, game_id: u128, outpost_id: Position, count: u32);
    fn verify(self: @TContractState, game_id: u128, outpost_id: Position);
    fn set_reinforcement_type(
        self: @TContractState,
        game_id: u128,
        outpost_id: Position,
        reinforcement_type: ReinforcementType
    );
    fn get_event_status(
        self: @TContractState, game_id: u128, outpost_id: Position
    ) -> OutpostEventStatus;
}


#[dojo::contract]
mod outpost_actions {
    use super::IOutpostActions;

    use risingrevenant::components::outpost::{OutpostTrait, OutpostEventStatus};
    use risingrevenant::components::game::{Position};
    use risingrevenant::components::player::{PlayerInfo};
    use risingrevenant::components::reinforcement::{ReinforcementType};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::player::{PlayerActionsTrait};
    use risingrevenant::systems::payment::{PaymentSystemTrait};
    use risingrevenant::systems::outpost::{OutpostActionsTrait};


    #[abi(embed_v0)]
    impl OutpostActionsImpl of IOutpostActions<ContractState> {
        fn purchase(self: @ContractState, game_id: u128) -> Position {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.purchase_outpost().position
        }

        fn get_price(self: @ContractState, game_id: u128) -> u256 {
            GameAction { world: self.world_dispatcher.read(), game_id }.get_outpost_price()
        }

        fn reinforce(self: @ContractState, game_id: u128, outpost_id: Position, count: u32) {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.reinforce_outpost(outpost_id, count);
        }

        fn verify(self: @ContractState, game_id: u128, outpost_id: Position) {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.verify_outpost(outpost_id);
        }
        fn set_reinforcement_type(
            self: @ContractState,
            game_id: u128,
            outpost_id: Position,
            reinforcement_type: ReinforcementType
        ) {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.set_outpost_reinforcement_type(outpost_id, reinforcement_type);
        }
        fn get_event_status(
            self: @ContractState, game_id: u128, outpost_id: Position
        ) -> OutpostEventStatus {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.get_outpost_event_status(outpost_id)
        }
    }
}
