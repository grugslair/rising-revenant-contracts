use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[starknet::interface]
trait ITradeReinforcementsActions<TContractState> {
    // Create a new trade
    fn create(
        self: @TContractState, world: IWorldDispatcher, game_id: u128, price: u128, count: u32
    ) -> u128;

    // Revoke an initiated trade
    fn revoke(self: @TContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128);

    // Purchase an existing trade
    fn purchase(self: @TContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128);

    // Modify the price of an existing trade
    fn modify_price(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u128,
        trade_id: u128,
        new_price: u128
    );

    fn get_status(
        self: @TContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128
    ) -> u8;
}

// Trade for outpost
#[starknet::contract]
mod trade_reinforcement_actions {
    use super::ITradeReinforcementsActions;

    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use risingrevenant::{
        components::trade::{ReinforcementTrade},
        systems::{
            game::{GameAction, GameActionTrait}, trade::{TradeActionImpl},
            reinforcement::{ReinforcementActionTrait},
        }
    };


    impl ReinforcementsTradeActionImpl = TradeActionImpl<ReinforcementTrade, u32>;


    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl TradeReinforcementsActionsImpl of ITradeReinforcementsActions<ContractState> {
        fn create(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, price: u128, count: u32,
        ) -> u128 {
            let trade_action = GameAction { world, game_id };
            assert(count > 0, 'count must larger than 0');
            let trade: ReinforcementTrade = trade_action.create_trade(price, count);
            trade_action.update_reinforcements::<i64>(trade.seller, -count.into());
            trade.trade_id
        }

        fn purchase(self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };
            let trade: ReinforcementTrade = trade_action.purchase_trade(trade_id);
            trade_action.update_reinforcements(trade.buyer, trade.offer);
        }

        fn modify_price(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            trade_id: u128,
            new_price: u128
        ) {
            ReinforcementsTradeActionImpl::modify_trade_price(
                GameAction { world, game_id }, trade_id, new_price
            );
        }

        fn revoke(self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };
            let trade: ReinforcementTrade = trade_action.revoke_trade(trade_id);
            trade_action.update_reinforcements(trade.seller, trade.offer);
        }

        fn get_status(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128
        ) -> u8 {
            let trade: ReinforcementTrade = GameAction { world, game_id }.get(trade_id);
            trade.status
        }
    }
}

