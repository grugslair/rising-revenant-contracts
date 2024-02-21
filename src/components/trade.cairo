use starknet::{ContractAddress};
use risingrevenant::components::game::{Position};


#[derive(Copy, Drop, Print, Introspect)]
struct Trade<T> {
    #[key]
    game_id: u128,
    #[key]
    trade_type: u8,
    #[key]
    trade_id: u128,
    seller: ContractAddress,
    buyer: ContractAddress,
    price: u128,
    offer: T,
    status: u8,
}

#[derive(Model, Copy, Drop, Print, Introspect)]
type OutpostTrade = Trade<Position>;

#[derive(Model, Copy, Drop, Print)]
type ReinforcementTrade = Trade<u32>;

trait TradeTrait<O, T> {
    fn new(game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: O) -> T;
    fn check_selling(self: T);
    fn is_owner(self: T, caller: ContractAddress) -> bool;
    fn set_status(ref self: T, status: u8);
    fn set_price(ref self: T, price: u128);
    fn set_sold(ref self: T, buyer: ContractAddress) -> (ContractAddress, u128);
}


#[generate_trait]
impl TradeImpl<O, T> of GenTradeTrait<O, T> {
    fn check_selling(self: @Trade<O>) {
        assert(*self.status != TradeStatus::not_created, 'trade not exist');
        assert(*self.status != TradeStatus::sold, 'trade had been sold');
        assert(*self.status != TradeStatus::revoked, 'trade had been revoked');
    }
}

impl ReinforcementTradeImpl of TradeTrait<u32, ReinforcementTrade> {
    fn new(
        game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: u32
    ) -> ReinforcementTrade {
        ReinforcementTrade {
            game_id,
            trade_type: TradeType::reinforcements,
            trade_id,
            seller,
            buyer: starknet::contract_address_const::<0x0>(),
            price,
            offer,
            status: TradeStatus::selling,
        }
    }
    fn check_selling(self: ReinforcementTrade) {
        GenTradeTrait::<u32, ReinforcementTrade>::check_selling(@self);
    }
    fn is_owner(self: ReinforcementTrade, caller: ContractAddress) -> bool {
        self.seller == caller
    }
    fn set_status(ref self: ReinforcementTrade, status: u8) {
        self.status = status;
    }
    fn set_price(ref self: ReinforcementTrade, price: u128) {
        self.price = price;
    }
    fn set_sold(ref self: ReinforcementTrade, buyer: ContractAddress) -> (ContractAddress, u128) {
        self.status = TradeStatus::sold;
        self.buyer = buyer;
        (self.seller, self.price)
    }
}

impl OutpostTradeImpl of TradeTrait<Position, OutpostTrade> {
    fn new(
        game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: Position
    ) -> OutpostTrade {
        OutpostTrade {
            game_id,
            trade_type: TradeType::outpost,
            trade_id,
            seller,
            buyer: starknet::contract_address_const::<0x0>(),
            price,
            offer,
            status: TradeStatus::selling,
        }
    }
    fn check_selling(self: OutpostTrade) {
        GenTradeTrait::<Position, OutpostTrade>::check_selling(@self);
    }
    fn is_owner(self: OutpostTrade, caller: ContractAddress) -> bool {
        self.seller == caller
    }
    fn set_status(ref self: OutpostTrade, status: u8) {
        self.status = status;
    }
    fn set_price(ref self: OutpostTrade, price: u128) {
        self.price = price;
    }
    fn set_sold(ref self: OutpostTrade, buyer: ContractAddress) -> (ContractAddress, u128) {
        self.status = TradeStatus::sold;
        self.buyer = buyer;
        (self.seller, self.price)
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
