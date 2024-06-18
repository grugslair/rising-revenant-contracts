use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::game::{Position};

#[dojo::interface]
trait ITradeOutpostActions {
    // Create a new trade
    fn create(
        ref world: IWorldDispatcher, game_id: u128, price: u128, outpost_id: Position
    ) -> u128;

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
mod trade_outpost_actions {
    use super::ITradeOutpostActions;

    use starknet::{ContractAddress, get_caller_address};


    use risingrevenant::components::trade::{Trade, OutpostTrade, TradeTrait, TradeType};
    use risingrevenant::components::game::{Position};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::trade::{TradeActionTrait};
    use risingrevenant::systems::outpost::{OutpostActionsTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TradeOutpostActionImpl of ITradeOutpostActions<ContractState> {
        fn create(
            ref world: IWorldDispatcher, game_id: u128, price: u128, outpost_id: Position
        ) -> u128 {
            let trade_action = GameAction { world, game_id };

            let trade: OutpostTrade = trade_action.create_trade(price, outpost_id);
            trade.trade_id
        }


        fn purchase(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };

            let trade: OutpostTrade = trade_action.purchase_trade(trade_id);

            trade_action.change_outpost_owner(trade.offer, trade.buyer);
        }

        fn modify_price(
            ref world: IWorldDispatcher, game_id: u128, trade_id: u128, new_price: u128
        ) {
            TradeActionTrait::<
                OutpostTrade, Position
            >::modify_trade_price(GameAction { world, game_id }, trade_id, new_price);
        }

        fn revoke(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let _: OutpostTrade = GameAction { world, game_id }.revoke_trade(trade_id);
        }
        fn get_status(ref world: IWorldDispatcher, game_id: u128, trade_id: u128) -> u8 {
            let trade: OutpostTrade = GameAction { world, game_id }.get(trade_id);
            trade.status
        }
    }
}
