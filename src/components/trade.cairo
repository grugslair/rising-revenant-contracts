use starknet::{ContractAddress};
use risingrevenant::components::game::{Position};


#[derive(Copy, Drop)]
struct Trade<T> {
    game_id: u128,
    trade_id: u128,
    trade_type: u8,
    seller: ContractAddress,
    buyer: ContractAddress,
    price: u128,
    offer: T,
    status: u8,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde, SerdeLen)]
struct OutpostTrade {
    #[key]
    game_id: u128,
    #[key]
    trade_id: u128,
    trade_type: u8,
    seller: ContractAddress,
    buyer: ContractAddress,
    price: u128,
    offer: Position,
    status: u8,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde, SerdeLen)]
struct ReinforcementTrade {
    #[key]
    game_id: u128,
    #[key]
    trade_id: u128,
    trade_type: u8,
    seller: ContractAddress,
    buyer: ContractAddress,
    price: u128,
    offer: u32,
    status: u8,
}

trait TradeTrait<T, O> {
    fn new(game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: O) -> T;
    fn to_generic(self: T) -> Trade<O>;
    fn from_generic(trade: Trade<O>) -> T;
    fn get_type(self: T) -> u8;
}


#[generate_trait]
impl TradeImpl<O> of GenTradeTrait<O> {
    fn check_selling(self: @Trade<O>) {
        assert(*self.status != TradeStatus::not_created, 'trade not exist');
        assert(*self.status != TradeStatus::sold, 'trade had been sold');
        assert(*self.status != TradeStatus::revoked, 'trade had been revoked');
    }
}


impl ReinforcementTradeImpl of TradeTrait<ReinforcementTrade, u32> {
    fn new(
        game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: u32
    ) -> ReinforcementTrade {
        ReinforcementTrade {
            game_id,
            trade_id,
            trade_type: TradeType::reinforcements,
            seller,
            buyer: starknet::contract_address_const::<0x0>(),
            price,
            offer,
            status: TradeStatus::selling,
        }
    }
    fn to_generic(self: ReinforcementTrade) -> Trade<u32> {
        Trade {
            game_id: self.game_id,
            trade_id: self.trade_id,
            trade_type: self.trade_type,
            seller: self.seller,
            buyer: self.buyer,
            price: self.price,
            offer: self.offer,
            status: self.status,
        }
    }
    fn from_generic(trade: Trade<u32>) -> ReinforcementTrade {
        ReinforcementTrade {
            game_id: trade.game_id,
            trade_id: trade.trade_id,
            trade_type: trade.trade_type,
            seller: trade.seller,
            buyer: trade.buyer,
            price: trade.price,
            offer: trade.offer,
            status: trade.status,
        }
    }
    fn get_type(self: ReinforcementTrade) -> u8 {
        TradeType::reinforcements
    }
}

impl OutpostTradeImpl of TradeTrait<OutpostTrade, Position> {
    fn new(
        game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: Position
    ) -> OutpostTrade {
        OutpostTrade {
            game_id,
            trade_id,
            trade_type: TradeType::outpost,
            seller,
            buyer: starknet::contract_address_const::<0x0>(),
            price,
            offer,
            status: TradeStatus::selling,
        }
    }
    fn to_generic(self: OutpostTrade) -> Trade<Position> {
        Trade {
            game_id: self.game_id,
            trade_id: self.trade_id,
            trade_type: self.trade_type,
            seller: self.seller,
            buyer: self.buyer,
            price: self.price,
            offer: self.offer,
            status: self.status,
        }
    }
    fn from_generic(trade: Trade<Position>) -> OutpostTrade {
        OutpostTrade {
            game_id: trade.game_id,
            trade_type: trade.trade_type,
            trade_id: trade.trade_id,
            seller: trade.seller,
            buyer: trade.buyer,
            price: trade.price,
            offer: trade.offer,
            status: trade.status,
        }
    }
    fn get_type(self: OutpostTrade) -> u8 {
        TradeType::outpost
    }
}

mod TradeStatus {
    const not_created: u8 = 0;
    const selling: u8 = 1;
    const sold: u8 = 2;
    const revoked: u8 = 3;
}

mod TradeType {
    const outpost: u8 = 1;
    const reinforcements: u8 = 2;
}
