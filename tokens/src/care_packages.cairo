#[starknet::interface]
pub trait ICarePackage<TContractState> {
    fn purchase(ref self: TContractState) -> u256;
}

#[starknet::contract]
mod care_package {
    use super::ICarePackage;
    use core::num::traits::Zero;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{ContractAddress, get_caller_address,};
    use rr_tokens::vrgda::{LogisticVRGDA, VRGDATrait};
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
        market: LogisticVRGDA,
        total_minted: u128,
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
        owner: ContractAddress
    ) {
        self.erc721.initializer(name, symbol, base_uri);
    }

    #[abi(embed_v0)]
    impl CarePackageImpl of ICarePackage<ContractState> {
        fn purchase(ref self: ContractState) -> u256 {
            let market = self.market.read();
            let caller = get_caller_address();
            let token_id = self.total_minted;
            self.total_minted += 1;
            self.erc721.mint(caller, token_id);
            token_id
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn get_price(self: @ContractState, sold: u128) -> LogisticVRGDA {
            self.storage().market
        }
    }
}
