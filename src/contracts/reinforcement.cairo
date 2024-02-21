#[starknet::interface]
trait IReinforcementActions<TContractState> {
    fn get_price(self: @TContractState, game_id: u128, count: u32) -> u128;
    fn purchase(self: @TContractState, game_id: u128, count: u32);
}

#[dojo::contract]
mod outpost_actions {
    use super::IReinforcementActions;
    use starknet::{get_caller_address};

    use risingrevenant::components::outpost::{OutpostTrait, Position};
    use risingrevenant::components::player::{PlayerInfo};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::player::{PlayerActionsTrait};
    use risingrevenant::systems::payment::{PaymentSystemTrait};
    use risingrevenant::systems::reinforcement::{ReinforcementActionTrait};


    #[external(v0)]
    impl OutpostActionsImpl of IReinforcementActions<ContractState> {
        fn get_price(self: @ContractState, game_id: u128, count: u32) -> u128 {
            let game_action = GameAction { world: self.world_dispatcher.read(), game_id };
            game_action.get_reinforcement_price(count)
        }

        fn purchase(self: @ContractState, game_id: u128, count: u32) {
            let game_action = GameAction { world: self.world_dispatcher.read(), game_id };
            game_action.purchase_reinforcement(get_caller_address(), count);
        }
    }
}
