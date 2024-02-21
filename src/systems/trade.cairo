use starknet::{get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::model::{Model};
use dojo::database::introspect::Introspect;

use risingrevenant::components::game::{GameTradeTax};
use risingrevenant::components::trade::{Trade, TradeTrait, TradeStatus, GenTradeTrait};

use risingrevenant::systems::game::{GameAction, GameActionTrait};
use risingrevenant::systems::payment::{PaymentSystemTrait};

#[generate_trait]
impl TradeActionImpl<
    O,
    T,
    +Introspect<T>,
    +Serde<T>,
    +Model<T>,
    +Drop<T>,
    +Copy<T>,
    +Drop<O>,
    +Copy<O>,
    +TradeTrait<O, T>,
> of TradeActionTrait<O, T> {
    fn create_trade(self: GameAction, trade_type: u8, price: u128, offer: O) -> T {
        self.assert_playing();
        let seller = get_caller_address();

        let trade = TradeTrait::<O, T>::new(self.game_id, self.uuid(), seller, price, offer);
        set!(self.world, (trade,));
        trade
    }

    fn purchase_trade(self: GameAction, trade_type: u8, trade_id: u32) -> T {
        let mut trade = TradeActionTrait::<O, T>::get_active_trade(self, trade_type, trade_id);

        let buyer = get_caller_address(); //get the address of the person calling the api
        assert(trade.seller != buyer, 'unable purchase your own trade');

        let payment_system = PaymentSystemTrait::new(self);
        let taxes: GameTradeTax = self.get_game();

        let pot_contribution = trade.price * (taxes.trade_tax_percent).into() / 100_u128;
        let seller_payout = trade.price - pot_contribution;

        payment_system.transfer(buyer, trade.seller, seller_payout);
        payment_system.pay_into_pot(buyer, pot_contribution);

        trade.status = TradeStatus::sold;
        trade.buyer = buyer;
        set!(self.world, (trade,));

        trade
    }

    fn modify_trade_price(self: GameAction, trade_type: u8, trade_id: u32, new_price: u128) {
        let mut trade = TradeActionTrait::<
            O, T
        >::get_players_active_trade(self, trade_type, trade_id);
        trade.price = new_price;
        set!(self.world, (trade,));
    }

    fn revoke_trade(self: GameAction, trade_type: u8, trade_id: u32) -> T {
        let mut trade = TradeActionTrait::<
            O, T
        >::get_players_active_trade(self, trade_type, trade_id);
        trade.status = TradeStatus::revoked;
        set!(self.world, (trade,));
        trade
    }

    fn get_active_trade(self: GameAction, trade_type: u8, trade_id: u32) -> T {
        self.assert_playing();
        let trade = self.get((self.game_id, trade_type, trade_id));
        trade.check_selling();
        trade
    }
    fn get_players_active_trade(self: GameAction, trade_type: u8, trade_id: u32) -> T {
        let trade = TradeActionTrait::<O, T>::get_active_trade(self, trade_type, trade_id);
        let caller = get_caller_address();
        // assert(trade.seller == caller, 'not owner');
        trade
    }
}

