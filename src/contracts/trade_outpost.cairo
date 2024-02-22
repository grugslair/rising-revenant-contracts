use risingrevenant::components::game::{Position};

#[starknet::interface]
trait ITradeOutpostActions<TContractState> {
    // Create a new trade
    fn create(self: @TContractState, game_id: u128, outpost_postion: Position, price: u128) -> u128;

    // Revoke an initiated trade
    fn revoke(self: @TContractState, game_id: u128, trade_id: u128);

    // Purchase an existing trade
    fn purchase(self: @TContractState, game_id: u128, trade_id: u128);

    // Modify the price of an existing trade
    fn modify_price(self: @TContractState, game_id: u128, trade_id: u128, new_price: u128);
}

// Trade for outpost
#[dojo::contract]
mod trade_outpost_actions {
    use super::ITradeOutpostActions;

    use starknet::{ContractAddress, get_caller_address};

    use risingrevenant::components::trade::{Trade, OutpostTrade, TradeTrait, TradeType};
    use risingrevenant::components::game::{Position};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::trade::{TradeActionImpl, TradeActionTrait};
    use risingrevenant::systems::outpost::{OutpostActionsTrait};

    #[external(v0)]
    impl TradeOutpostActionImpl of ITradeOutpostActions<ContractState> {
        fn create(
            self: @ContractState, game_id: u128, outpost_postion: Position, price: u128
        ) -> u128 {
            let trade_action = GameAction { world: self.world_dispatcher.read(), game_id };

            let caller = get_caller_address();
            let outpost = trade_action.get_active_outpost(outpost_postion);
            assert(outpost.owner == caller, 'not owner');

            let trade: OutpostTrade = TradeActionTrait::create_trade(
                trade_action, price, outpost_postion
            );
            trade.trade_id
        }


        fn purchase(self: @ContractState, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world: self.world_dispatcher.read(), game_id };
            let trade: OutpostTrade = trade_action.purchase_trade(TradeType::outpost, trade_id);

            trade_action.change_outpost_owner(trade.offer, trade.buyer);
        }

        fn modify_price(self: @ContractState, game_id: u128, trade_id: u128, new_price: u128) {
            TradeActionImpl::<
                Position
            >::modify_trade_price(
                GameAction { world: self.world_dispatcher.read(), game_id },
                TradeType::outpost,
                trade_id,
                new_price
            );
        }

        fn revoke(self: @ContractState, game_id: u128, trade_id: u128) {
            let _: OutpostTrade = GameAction { world: self.world_dispatcher.read(), game_id }
                .revoke_trade(TradeType::outpost, trade_id);
        }
    }
}
