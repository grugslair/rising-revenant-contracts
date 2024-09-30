struct Outpost {
    game_id: u128,
    outpost_id: u128,
    position: Point,
    fortifications: Fortifications,
    hp: u64,
}

trait IOutpost<TContractState> {
    fn get_outpost() -> Outpost;
}

#[starknet::contract]
mod outpost {
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
        total_minted: u256,
        outpost_contract_address: ContractAddress,
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
        owner: ContractAddress,
        outpost_contract_address: ContractAddress,
    ) {
        self.erc721.initializer(name, symbol, base_uri);
        self.owner.write(owner);
    }
    #[abi(embed_v0)]
    impl OutpostERC721Impl of IOutpostERC721<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            assert(
                self.writers.entry(get_caller_address()).read(),
                ERC721Component::Errors::UNAUTHORIZED
            );
            let token_id = self.total_minted.read();
            self.total_minted.write(token_id + 1);
            self.erc721.mint(to, token_id);
        }
        fn set_outpost_contract_adddress(
            ref self: ContractState, outpost_contract_address: ContractAddress
        ) {
            assert(
                self.owner.read() == get_caller_address(), ERC721Component::Errors::UNAUTHORIZED
            );
            self.outpost_contract_address.write(outpost_contract_address);
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
    }
}
