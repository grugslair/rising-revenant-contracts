use core::option::OptionTrait;
use core::traits::Into;

use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::game::{GamePotTrait};
use risingrevenant::components::trade::{Trade, TradeTrait, TradeType, TradeStatus};

use risingrevenant::systems::game::{GameAction, GameActionTrait};


#[generate_trait]
impl TradeActionImpl<T, +Drop<T>, +Copy<T>> of TradeActionTrait<T> {
    fn create_trade(self: @GameAction, trade_type: u8, price: u128, offer: T) -> Trade<T> {
        self.check_game_playing();

        let seller = get_caller_address();

        let trade = TradeTrait::new(
            *self.game_id, trade_type, (*self.world).uuid(), seller, price, offer
        );
        self.set(trade);
        trade
    }

    fn purchase_trade(self: @GameAction, trade_type: u8, trade_id: u32) -> Trade<T> {
        let mut trade: Trade<T> = self.get_active_trade(trade_type, trade_id);

        let buyer = get_caller_address(); //get the address of the person calling the api
        assert(trade.seller != buyer, 'unable purchase your own trade');

        let game_setup = self.get_setup();
        let pot_contribution = trade.price * (game_setup.trade_pot_percent).into() / 100_u128;
        let seller_payout = trade.price - pot_contribution;

        self.transfer(buyer, trade.seller, seller_payout);
        self.transfer(buyer, game_setup.pot_pool_addr, pot_contribution);

        trade.status = TradeStatus::sold;
        trade.buyer = buyer;
        self.set((trade));

        self.increase_pot(pot_contribution);
        trade
    }

    fn modify_trade_price(self: @GameAction, trade_type: u8, trade_id: u32, new_price: u128) {
        let mut trade: Trade<T> = self.get_players_active_trade(trade_type, trade_id);
        trade.price = new_price;
        self.set(trade);
    }

    fn revoke_trade(self: @GameAction, trade_type: u8, trade_id: u32) -> Trade<T> {
        let mut trade: Trade<T> = self.get_players_active_trade(trade_type, trade_id);
        trade.status = TradeStatus::revoked;
        self.set(trade);
        trade
    }

    fn get_active_trade(self: @GameAction, trade_type: u8, trade_id: u32) -> Trade<T> {
        self.check_game_playing();
        let trade: Trade<T> = self.get((*self.game_id, trade_type, trade_id));
        trade.check_selling();
        trade
    }
    fn get_players_active_trade(self: @GameAction, trade_type: u8, trade_id: u32) -> Trade<T> {
        let trade: Trade<T> = self.get_active_trade(trade_type, trade_id);
        let caller = get_caller_address();
        assert(trade.seller == caller, 'not owner');
        trade
    }
}

