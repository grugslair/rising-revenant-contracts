use starknet::{ContractAddress, ClassHash, SyscallResultTrait, syscalls::deploy_syscall};
use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};

#[starknet::interface]
pub trait IERC721Mintable<TContractState> {
    fn mint(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn safe_mint(
        ref self: TContractState, recipient: ContractAddress, token_id: u256, data: Span<felt252>,
    );
    fn safeMint(
        ref self: TContractState, recipient: ContractAddress, tokenId: u256, data: Span<felt252>,
    );
}

fn deploy_erc721_mintable(
    class_hash: ClassHash,
    salt: felt252,
    name: ByteArray,
    symbol: ByteArray,
    base_uri: ByteArray,
    default_admin: ContractAddress,
    minter: ContractAddress,
) -> ContractAddress {
    let mut calldata = ArrayTrait::<felt252>::new();

    name.serialize(ref calldata);
    symbol.serialize(ref calldata);
    base_uri.serialize(ref calldata);
    calldata.append_span([default_admin.into(), minter.into()].span());
    let (contract_address, _) = deploy_syscall(class_hash, salt, calldata.span(), true)
        .unwrap_syscall();
    contract_address
}

fn erc721_mint(contract_address: ContractAddress, to: ContractAddress, token_id: u256) {
    IERC721MintableDispatcher { contract_address }.mint(to, token_id)
}

fn erc721_owner_of(contract_address: ContractAddress, token_id: u256) -> ContractAddress {
    ERC721ABIDispatcher { contract_address }.owner_of(token_id)
}

#[starknet::contract]
mod erc721_mintable {
    use core::{poseidon::poseidon_hash_span};
    use openzeppelin_access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, get_contract_address};
    use super::IERC721Mintable;
    const MINTER_ROLE: felt252 = 'MINTER_ROLE';

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlCamelImpl =
        AccessControlComponent::AccessControlCamelImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        default_admin: ContractAddress,
        minter: ContractAddress
    ) {
        self.erc721.initializer(name, symbol, base_uri);
        self.accesscontrol.initializer();

        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, default_admin);
        self.accesscontrol._grant_role(MINTER_ROLE, minter);
    }

    #[abi(embed_v0)]
    impl IERC721MintableImpl of IERC721Mintable<ContractState> {
        fn mint(ref self: ContractState, to: ContractAddress, token_id: u256) {
            self.accesscontrol.assert_only_role(MINTER_ROLE);
            self.erc721.mint(to, token_id);
        }
        fn safe_mint(
            ref self: ContractState,
            recipient: ContractAddress,
            token_id: u256,
            data: Span<felt252>,
        ) {
            self.accesscontrol.assert_only_role(MINTER_ROLE);
            self.erc721.safe_mint(recipient, token_id, data);
        }
        fn safeMint(
            ref self: ContractState, recipient: ContractAddress, tokenId: u256, data: Span<felt252>,
        ) {
            self.safe_mint(recipient, tokenId, data);
        }
    }
}
