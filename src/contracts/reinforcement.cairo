use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::interface]
trait IReinforcementActions {
    fn get_price(ref world: IWorldDispatcher, game_id: u128, count: u32) -> u256;
    fn purchase(ref world: IWorldDispatcher, game_id: u128, count: u32);
}

#[dojo::contract]
mod reinforcement_actions {
    use super::IReinforcementActions;
    use starknet::{get_caller_address};


    use risingrevenant::components::reinforcement::{ReinforcementMarket, ReinforcementMarketTrait};


    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::reinforcement::{ReinforcementActionTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl ReinforcementActionsImpl of IReinforcementActions<ContractState> {
        fn get_price(ref world: IWorldDispatcher, game_id: u128, count: u32) -> u256 {
            let game_action = GameAction { world, game_id };
            game_action.get_reinforcements_price(count)
        }

        fn purchase(ref world: IWorldDispatcher, game_id: u128, count: u32) {
            let game_action = GameAction { world, game_id };
            game_action.purchase_reinforcements(get_caller_address(), count);
        }
    }
}
