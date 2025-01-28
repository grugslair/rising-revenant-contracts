use starknet::ContractAddress;
use dojo::world::{WorldStorage, IWorldDispatcherTrait};
use rising_revenant::care_packages::Rarity;


#[starknet::interface]
pub trait ICarePackage<TContractState> {
    fn get_price(self: @TContractState) -> u256;
    fn purchase(ref self: TContractState) -> u256;
}

#[starknet::contract]
mod care_package {
    use super::ICarePackage;
    use core::{num::traits::Zero, poseidon::poseidon_hash_span};
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, get_contract_address};
    use rising_revenant::{
        vrgda::{LogisticVRGDA, LogisticVRGDAStore, VRGDATrait}, fixed::FixedToDecimal,
        jackpot::{IJackpotDispatcher, IJackpotDispatcherTrait}
    };
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        total_minted: u128,
        erc20_token_address: ContractAddress,
        erc20_decimals: u8,
        jackpot_address: ContractAddress,
        mint_start: u64,
        mint_end: u64,
        market: LogisticVRGDAStore,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        erc20_token_address: ContractAddress,
        erc20_decimals: u8,
        jackpot_address: ContractAddress,
        mint_start: u64,
        mint_end: u64,
        market: LogisticVRGDAStore,
    ) {
        self.erc721.initializer(name, symbol, base_uri);
        self.jackpot_address.write(jackpot_address);
        self.erc20_token_address.write(erc20_token_address);
        self.erc20_decimals.write(erc20_decimals);
        self.mint_start.write(mint_start);
        self.mint_end.write(mint_end);
        self.market.write(market);
    }

    #[abi(embed_v0)]
    impl CarePackageImpl of ICarePackage<ContractState> {
        fn get_price(self: @ContractState) -> u256 {
            self._get_price(self.total_minted.read())
        }

        fn purchase(ref self: ContractState) -> u256 {
            let total_minted = self.total_minted.read();
            let caller = get_caller_address();
            let jackpot_address = self.jackpot_address.read();
            let price = self._get_price(total_minted);
            ERC20ABIDispatcher { contract_address: self.erc20_token_address.read() }
                .transfer_from(caller, jackpot_address, price);
            IJackpotDispatcher { contract_address: jackpot_address }.increase_jackpot_amount(price);
            let total_minted = total_minted + 1;
            self.total_minted.write(total_minted);
            let token_id = poseidon_hash_span(
                [get_contract_address().into(), total_minted.into()].span()
            )
                .into();
            self.erc721.mint(caller, token_id);
            token_id
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn _get_price(self: @ContractState, sold: u128) -> u256 {
            let timestamp = get_block_timestamp();
            let start_time = self.mint_start.read();
            assert(
                start_time <= timestamp && timestamp <= self.mint_end.read(),
                'Not in minting period'
            );
            let market: LogisticVRGDA = self.market.read().into();
            market
                .get_vrgda_price((timestamp - start_time).into(), sold.into())
                .to_decimal(self.erc20_decimals.read())
        }
    }
}
