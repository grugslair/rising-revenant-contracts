use starknet::{ContractAddress};


#[derive(Model, Copy, Drop, Serde, SerdeLen)]
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


#[generate_trait]
impl TradeImpl<T> of TradeTrait<T> {
    fn new(
        game_id: u128,
        trade_type: u8,
        trade_id: u128,
        seller: ContractAddress,
        price: u128,
        offer: T
    ) -> Trade<T> {
        Trade {
            game_id,
            trade_type,
            trade_id,
            seller,
            buyer: starknet::contract_address_const::<0x0>(),
            price,
            offer,
            status: TradeStatus::selling,
        }
    }


    fn check_selling(self: @Trade<T>) {
        assert(*self.status != TradeStatus::not_created, 'trade not exist');
        assert(*self.status != TradeStatus::sold, 'trade had been sold');
        assert(*self.status != TradeStatus::revoked, 'trade had been revoked');
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
