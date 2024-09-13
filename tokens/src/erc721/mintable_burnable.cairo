use starknet::ContractAddress;
#[starknet::interface]
trait IERC721MintableBurnable<TContractState> {
    fn set_writer(ref self: TContractState, writer: ContractAddress, authorized: bool);
    fn mint(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn burn_from(ref self: TContractState, from: ContractAddress, token_id: u256);
}


#[starknet::contract]
mod MyNFT {
    use core::num::traits::Zero;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{
        ContractAddress, get_caller_address,
        storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map}
    };
    use super::IERC721MintableBurnable;
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
        ref self: ContractState, name: ByteArray, symbol: ByteArray, base_uri: ByteArray
    ) {
        self.erc721.initializer(name, symbol, base_uri);
    }

    impl ERC721MintableBurnableImpl of IERC721MintableBurnable<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            assert(
                self.writers.entry(get_caller_address()).read(),
                ERC721Component::Errors::UNAUTHORIZED
            );
            self.erc721.mint(to, token_id);
        }

        fn burn_from(ref self: ContractState, from: ContractAddress, token_id: u256) {
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
