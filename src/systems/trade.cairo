use risingrevenant::components::trade::GenTradeTrait;
use starknet::{get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::model::{Model};
use dojo::database::introspect::Introspect;

use risingrevenant::components::game::{GameTradeTax, Position};
use risingrevenant::components::trade::{
    Trade, TradeTrait, TradeStatus, OutpostTrade, ReinforcementTrade, TradeType
};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::payment::{PaymentSystemTrait};

#[generate_trait]
impl TradeActionImpl<
    T,
    O,
    +Introspect<T>,
    +Model<T>,
    +Drop<T>,
    +Copy<T>,
    +Serde<T>,
    +Drop<O>,
    +Serde<O>,
    +Copy<O>,
    +TradeTrait<T, O>,
> of TradeActionTrait<T, O> {
    fn create_trade(self: GameAction, price: u128, offer: O) -> T {
        self.assert_playing();
        let seller = get_caller_address();

        let trade = TradeTrait::<T, O>::new(self.game_id, self.uuid(), seller, price, offer);
        set!(self.world, (trade,));
        trade
    }

    fn purchase_trade(self: GameAction, trade_id: u128) -> T {
        let mut trade = TradeActionTrait::<T, O>::get_active_trade(self, trade_id);

        let buyer = get_caller_address(); //get the address of the person calling the api
        assert(trade.seller != buyer, 'unable purchase your own trade');
        trade.status = TradeStatus::sold;
        trade.buyer = buyer;

        let payment_system = PaymentSystemTrait::new(self);
        let taxes: GameTradeTax = self.get_game();

        let pot_contribution = trade.price * (taxes.trade_tax_percent).into() / 100_u128;
        let seller_payout = trade.price - pot_contribution;

        payment_system.transfer(buyer, trade.seller, seller_payout);
        payment_system.pay_into_pot(buyer, pot_contribution);

        let _trade = TradeTrait::from_generic(trade);
        set!(self.world, (_trade,));
        _trade
    }

    fn modify_trade_price(self: GameAction, trade_id: u128, new_price: u128) {
        let mut _trade = TradeActionTrait::<T, O>::get_players_active_trade(self, trade_id);
        _trade.price = new_price;
        let trade: T = TradeTrait::from_generic(_trade);
        set!(self.world, (trade,));
    }

    fn revoke_trade(self: GameAction, trade_id: u128) -> T {
        let mut _trade = TradeActionTrait::<T, O>::get_players_active_trade(self, trade_id);
        _trade.status = TradeStatus::revoked;
        let trade = TradeTrait::from_generic(_trade);
        set!(self.world, (trade,));
        trade
    }
    fn get_active_trade(self: GameAction, trade_id: u128) -> Trade<O> {
        self.assert_playing();
        let trade = self.get::<(u128, u128), T>((self.game_id, trade_id)).to_generic();
        trade.check_selling();
        trade
    }
    fn get_players_active_trade(self: GameAction, trade_id: u128) -> Trade<O> {
        let trade = TradeActionTrait::<T, O>::get_active_trade(self, trade_id);
        let caller = get_caller_address();
        assert(caller == trade.seller, 'not owner');
        trade
    }
}

