use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::game::{Position};

#[starknet::interface]
trait ITradeOutpostActions<TContractState> {
    // Create a new trade
    fn create(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u128,
        price: u128,
        outpost_id: Position
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
mod trade_outpost_actions {
    use super::ITradeOutpostActions;

    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


    use risingrevenant::{
        components::{trade::{OutpostTrade}, game::{Position}},
        systems::{
            game::{GameAction, GameActionTrait}, trade::{TradeActionImpl},
            outpost::{OutpostActionsTrait},
        }
    };

    impl OutpostTradeActionImpl = TradeActionImpl<OutpostTrade, Position>;


    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TradeOutpostActionImpl of ITradeOutpostActions<ContractState> {
        fn create(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            price: u128,
            outpost_id: Position
        ) -> u128 {
            let trade_action = GameAction { world, game_id };

            let trade: OutpostTrade = trade_action.create_trade(price, outpost_id);
            trade.trade_id
        }


        fn purchase(self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let trade_action = GameAction { world, game_id };

            let trade: OutpostTrade = trade_action.purchase_trade(trade_id);

            trade_action.change_outpost_owner(trade.offer, trade.buyer);
        }

        fn modify_price(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            trade_id: u128,
            new_price: u128
        ) {
            OutpostTradeActionImpl::modify_trade_price(
                GameAction { world, game_id }, trade_id, new_price
            );
        }

        fn revoke(self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128) {
            let _: OutpostTrade = GameAction { world, game_id }.revoke_trade(trade_id);
        }
        fn get_status(
            self: @ContractState, world: IWorldDispatcher, game_id: u128, trade_id: u128
        ) -> u8 {
            let trade: OutpostTrade = GameAction { world, game_id }.get(trade_id);
            trade.status
        }
    }
}
