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

trait TradeTrait<O> {
    fn new(
        game_id: u128, trade_id: u128, seller: ContractAddress, price: u128, offer: O
    ) -> Trade<O>;
}

#[generate_trait]
impl TradeImpl of GenTradeTrait {
    fn check_selling<O>(self: @Trade<O>) {
        assert(*self.status != TradeStatus::not_created, 'trade not exist');
        assert(*self.status != TradeStatus::sold, 'trade had been sold');
        assert(*self.status != TradeStatus::revoked, 'trade had been revoked');
    }
}

impl ReinforcementTradeImpl of TradeTrait<u32> {
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
}

impl OutpostTradeImpl of TradeTrait<Position> {
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
