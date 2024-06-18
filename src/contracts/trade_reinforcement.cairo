use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
#[dojo::interface]
trait ITradeReinforcementsActions {
    // Create a new trade
    fn create(ref world: IWorldDispatcher, game_id: u128, price: u128, count: u32) -> u128;

    // Revoke an initiated trade
    fn revoke(ref world: IWorldDispatcher, game_id: u128, trade_id: u128);

    // Purchase an existing trade
    fn purchase(ref world: IWorldDispatcher, game_id: u128, trade_id: u128);

    // Modify the price of an existing trade
    fn modify_price(ref world: IWorldDispatcher, game_id: u128, trade_id: u128, new_price: u128);

    fn get_status(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) -> u8;
}

// Trade for outpost
#[dojo::contract]
mod trade_reinforcement_actions {
    use super::ITradeReinforcementsActions;

    use starknet::{ContractAddress, get_caller_address};


    use risingrevenant::components::trade::{ReinforcementTrade, TradeTrait, TradeType};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::trade::{TradeActionImpl};
    use risingrevenant::systems::reinforcement::{ReinforcementActionTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TradeReinforcementsActionsImpl of ITradeReinforcementsActions<ContractState> {
        fn create(ref world: IWorldDispatcher, game_id: u128, price: u128, count: u32,) -> u128 {
            let trade_action = GameAction { world, game_id };
            assert(count > 0, 'count must larger than 0');
            let trade: ReinforcementTrade = trade_action.create_trade(price, count);
            trade_action.update_reinforcements::<i64>(trade.seller, -count.into());
            trade.trade_id
        }

        fn purchase(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };
            let trade: ReinforcementTrade = trade_action.purchase_trade(trade_id);
            trade_action.update_reinforcements(trade.buyer, trade.offer);
        }

        fn modify_price(
            ref world: IWorldDispatcher, game_id: u128, trade_id: u128, new_price: u128
        ) {
            TradeActionImpl::<
                ReinforcementTrade, u32
            >::modify_trade_price(GameAction { world, game_id }, trade_id, new_price);
        }

        fn revoke(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };
            let trade: ReinforcementTrade = trade_action.revoke_trade(trade_id);
            trade_action.update_reinforcements(trade.seller, trade.offer);
        }

        fn get_status(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) -> u8 {
            let trade: ReinforcementTrade = GameAction { world, game_id }.get(trade_id);
            trade.status
        }
    }
}

