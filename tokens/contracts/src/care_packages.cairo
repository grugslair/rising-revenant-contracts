#[starknet::contract]
mod care_package {
    use core::num::traits::Zero;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{
        ContractAddress, get_caller_address,
        storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map}
    };
    use rr_tokens::care_packages::{interface::ICarePackage, Rarity};
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
        owner: ContractAddress,
        writers: Map<ContractAddress, bool>,
        rarity: Map<u256, Rarity>,
        total_minted: u256,
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
        self.owner.write(owner);
    }

    impl CarePackageImpl of ICarePackage<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, rarity: Rarity) {
            assert(
                self.writers.entry(get_caller_address()).read(),
                ERC721Component::Errors::UNAUTHORIZED
            );
            let token_id = self.total_minted.read();
            self.total_minted.write(token_id + 1);
            self.rarity.entry(token_id).write(rarity);
            self.erc721.mint(to, token_id);
        }

        fn burn_from(ref self: ContractState, token_id: u256) {
            let previous_owner = self.erc721.update(Zero::zero(), token_id, get_caller_address());
            assert(!previous_owner.is_zero(), ERC721Component::Errors::INVALID_TOKEN_ID);
        }
        fn set_writer(ref self: ContractState, writer: ContractAddress, authorized: bool) {
            assert(
                self.owner.read() == get_caller_address(), ERC721Component::Errors::UNAUTHORIZED
            );
            self.writers.entry(writer).write(authorized);
        }
        fn get_rarity(self: @ContractState, token_id: u256) -> Rarity {
            self.rarity.entry(token_id).read()
        }
    }
}
