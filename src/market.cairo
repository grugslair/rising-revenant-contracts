use starknet::{ContractAddress, get_contract_address};
use dojo::{world::WorldStorage, model::ModelStorage};
use openzeppelin_token::{
    erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait},
    erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait}
};

#[derive(Copy, Drop, Serde, Introspect)]
struct ERC20Amount {
    contract_address: ContractAddress,
    amount: u256
}

#[derive(Copy, Drop, Serde, Introspect)]
struct ERC721Token {
    contract_address: ContractAddress,
    token_id: u256
}

#[derive(Copy, Drop, Serde, Introspect)]
enum Token {
    ERC20: ERC20Amount,
    ERC721: ERC721Token,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct AuctionOffer {
    #[key]
    offer_id: u128,
    seller: ContractAddress,
    offer: Goods,
    expiration: u64,
    open: bool,
    accepted_bid: u128,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct AuctionBid {
    #[key]
    bid_id: u128,
    offer_id: u128,
    bidder: ContractAddress,
    bid: Goods,
    expiration: u64,
    open: bool
}

trait TTokenTrait<T, D> {
    fn get_dispatcher(self: @T) -> D;
    fn is_allowed(self: @T, owner: ContractAddress) -> bool;
    fn check_allowed(self: @T, owner: ContractAddress);
    fn transfer(self: @T, from: ContractAddress, to: ContractAddress);
}


impl ERC20TokenImpl of TTokenTrait<ERC20Amount, ERC20ABIDispatcher> {
    fn get_dispatcher(self: @ERC20Amount) -> ERC20ABIDispatcher {
        ERC20ABIDispatcher { contract_address: *self.contract_address }
    }
    fn is_allowed(self: @ERC20Amount, owner: ContractAddress) -> bool {
        let dispatcher = self.get_dispatcher();
        dispatcher.balance_of(owner) >= *self.amount
            || dispatcher.allowance(owner, get_contract_address()) >= *self.amount
    }
    fn check_allowed(self: @ERC20Amount, owner: ContractAddress) {
        assert(self.is_allowed(owner), 'Not Allowed');
    }
    fn transfer(self: @ERC20Amount, from: ContractAddress, to: ContractAddress) {
        self.check_allowed(from);
        let dispatcher = self.get_dispatcher();
        dispatcher.transfer_from(from, to, *self.amount);
    }
}


impl ERC721TokenImpl of TTokenTrait<ERC721Token, ERC721ABIDispatcher> {
    fn get_dispatcher(self: @ERC721Token) -> ERC721ABIDispatcher {
        ERC721ABIDispatcher { contract_address: *self.contract_address }
    }
    fn is_allowed(self: @ERC721Token, owner: ContractAddress) -> bool {
        let dispatcher = self.get_dispatcher();
        let contract_address = get_contract_address();
        dispatcher.owner_of(*self.token_id) == owner
            && (dispatcher.is_approved_for_all(owner, contract_address)
                || contract_address == dispatcher.get_approved(*self.token_id))
    }
    fn check_allowed(self: @ERC721Token, owner: ContractAddress) {
        assert(self.is_allowed(owner), 'Not Allowed');
    }
    fn transfer(self: @ERC721Token, from: ContractAddress, to: ContractAddress) {
        self.check_allowed(from);
        let dispatcher = self.get_dispatcher();
        dispatcher.transfer_from(from, to, *self.token_id);
    }
}

#[generate_trait]
impl EnumTokenImpl of EnumTokenTrait {
    fn is_allowed(self: @Token, owner: ContractAddress) -> bool {
        match self {
            Token::ERC20(token) => token.is_allowed(owner),
            Token::ERC721(token) => token.is_allowed(owner),
        }
    }
    fn check_allowed(self: @Token, owner: ContractAddress) {
        assert(self.is_allowed(owner), 'Not Allowed');
    }
    fn transfer(self: @Token, from: ContractAddress, to: ContractAddress) {
        match self {
            Token::ERC20(token) => token.transfer(from, to),
            Token::ERC721(token) => token.transfer(from, to),
        };
    }
}

type Goods = Array<Token>;

trait CheckOpen<T> {
    fn is_open(self: @T, timestamp: u64) -> bool;
    fn check_open(self: @T, timestamp: u64);
}

impl AuctionOfferOpenImpl of CheckOpen<AuctionOffer> {
    fn is_open(self: @AuctionOffer, timestamp: u64) -> bool {
        *self.open && *self.expiration > timestamp
    }
    fn check_open(self: @AuctionOffer, timestamp: u64) {
        assert(self.is_open(timestamp), 'Offer is closed');
    }
}

impl AuctionBidOpenImpl of CheckOpen<AuctionBid> {
    fn is_open(self: @AuctionBid, timestamp: u64) -> bool {
        *self.open && *self.expiration > timestamp
    }
    fn check_open(self: @AuctionBid, timestamp: u64) {
        assert(self.is_open(timestamp), 'Bid is closed');
    }
}

#[dojo::interface]
trait IDiscretionaryAuction<TContractState> {
    fn offer(ref self: ContractState, offer: Goods, expiration: u64) -> u128;
    fn bid(ref self: ContractState, offer_id: u128, bid: Goods, expiration: u64) -> u128;
    fn accept(ref self: ContractState, offer_id: u128, bid_id: u128);
    fn rescind_offer(ref self: ContractState, offer_id: u128);
    fn rescind_bid(ref self: ContractState, bid_id: u128);
}


#[dojo::contract]
mod discretionary_auction {
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
    use dojo::model::Model;
    use super::{
        IDiscretionaryAuction, AuctionOffer, AuctionBid, Token, ERC20Amount, ERC721Token, Goods,
        EnumTokenTrait, CheckOpen, AuctionOfferStore, AuctionBidStore
    };
    use openzeppelin_token::{
        erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait},
        erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait}
    };

    impl IDiscretionaryAuctionImpl of IDiscretionaryAuction<ContractState> {
        fn offer(ref self: ContractState, mut offer: Goods, expiration: u64) -> u128 {
            let seller = get_caller_address();
            let offer_id = world.uuid().into();
            AuctionOffer {
                offer_id, seller, offer: offer.clone(), expiration, open: true, accepted_bid: 0
            }
                .set(world);
            assert(offer.has_goods(seller), 'Not allowed');

            offer_id
        }
        fn bid(ref self: ContractState, offer_id: u128, mut bid: Goods, expiration: u64) -> u128 {
            let bidder = get_caller_address();
            let bid_id = world.uuid().into();
            AuctionBid { bid_id, offer_id, bidder, bid: bid.clone(), expiration, open: true }
                .set(world);

            assert(bid.has_goods(bidder), 'Not allowed');
            bid_id
        }
        fn accept(ref self: ContractState, offer_id: u128, bid_id: u128) {
            let caller = get_caller_address();
            let mut offer: AuctionOffer = AuctionOfferStore::get(world, offer_id);
            assert(offer.seller == caller, 'Not allowed');

            let mut bid: AuctionBid = AuctionBidStore::get(world, bid_id);
            let timestamp = get_block_timestamp();
            offer.check_open(timestamp);
            bid.check_open(timestamp);

            offer.offer.clone().transfer_goods(bid.bidder, offer.seller);
            bid.bid.clone().transfer_goods(offer.seller, bid.bidder);

            offer.open = false;
            bid.open = false;
            offer.accepted_bid = bid_id;

            offer.set_open(world, false);
            offer.set_accepted_bid(world, bid_id);
            bid.set_open(world, false);
        }
        fn rescind_offer(ref self: ContractState, offer_id: u128) {
            let mut offer = AuctionOfferStore::get(world, offer_id);
            let caller = get_caller_address();
            assert(offer.seller == caller, 'Not allowed');
            offer.check_open(get_block_timestamp());
            offer.set_open(world, false);
        }
        fn rescind_bid(ref self: ContractState, bid_id: u128) {
            let mut bid = AuctionBidStore::get(world, bid_id);
            let caller = get_caller_address();
            assert(bid.bidder == caller, 'Not allowed');
            bid.check_open(get_block_timestamp());
            bid.set_open(world, false);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn has_goods(mut self: Goods, owner: ContractAddress) -> bool {
            loop {
                match self.pop_front() {
                    Option::Some(token) => { if !token.is_allowed(owner) {
                        break false;
                    } },
                    Option::None => { break true; },
                };
            }
        }
        fn transfer_goods(mut self: Goods, from: ContractAddress, to: ContractAddress) {
            loop {
                match self.pop_front() {
                    Option::Some(token) => { token.transfer(from, to); },
                    Option::None => { break; },
                };
            }
        }
    }
}
