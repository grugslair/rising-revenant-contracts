use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IReinforcementActions<TContractState> {
    fn get_price(self: @TContractState, world: IWorldDispatcher, game_id: u128, count: u32) -> u128;
    fn purchase(self: @TContractState, world: IWorldDispatcher, game_id: u128, count: u32);
}

#[starknet::contract]
mod reinforcement_actions {
    use super::IReinforcementActions;
    use starknet::{get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


    use risingrevenant::components::reinforcement::{ReinforcementMarket, ReinforcementMarketTrait};


    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::reinforcement::{ReinforcementActionTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl ReinforcementActionsImpl of IReinforcementActions<ContractState> {
        fn get_price(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, count: u32
        ) -> u128 {
            let game_action = GameAction { world, game_id };
            game_action.get_reinforcements_price(count)
        }

        fn purchase(self: @ContractState, world: IWorldDispatcher, game_id: u128, count: u32) {
            let game_action = GameAction { world, game_id };
            game_action.purchase_reinforcements(get_caller_address(), count);
        }
    }
}
