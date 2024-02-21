#[starknet::interface]
trait ITradeReinforcmentsActions<TContractState> {
    // Create a new trade
    fn create(self: @TContractState, game_id: u128, count: u32, price: u128) -> u128;

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
    use super::ITradeReinforcmentsActions;

    use starknet::{ContractAddress, get_caller_address};

    use risingrevenant::components::trade::{ReinforcementTrade, TradeTrait, TradeType};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::trade::{TradeActionImpl};
    use risingrevenant::systems::reinforcement::{ReinforcementActionTrait};

    #[external(v0)]
    impl TradeReinforcmentsActionImpl of ITradeReinforcmentsActions<ContractState> {
        fn create(self: @ContractState, game_id: u128, count: u32, price: u128) -> u128 {
            let trade_action = GameAction { world: self.world_dispatcher.read(), game_id };
            assert(count > 0, 'count must larger than 0');
            let trade = trade_action.create_trade(TradeType::reinforcements, price, count);
            trade_action.update_reinforcements::<i64>(trade.seller, -count.into());
            trade.trade_id
        }

        fn purchase(self: @ContractState, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world: self.world_dispatcher.read(), game_id };
            let trade: ReinforcementTrade = trade_action
                .purchase_trade(TradeType::reinforcements, trade_id);
            trade_action.update_reinforcements(trade.buyer, trade.offer);
        }

        fn modify_price(self: @ContractState, game_id: u128, trade_id: u128, new_price: u128) {
            TradeActionImpl::<
                u128
            >::modify_trade_price(
                GameAction { world: self.world_dispatcher.read(), game_id },
                TradeType::reinforcements,
                trade_id,
                new_price
            );
        }

        fn revoke(self: @ContractState, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world: self.world_dispatcher.read(), game_id };
            let trade: ReinforcementTrade = trade_action
                .revoke_trade(TradeType::reinforcements, trade_id);
            trade_action.update_reinforcements(trade.seller, trade.offer);
        }
    }
}

