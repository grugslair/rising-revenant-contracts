use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use starknet::{ClassHash, ContractAddress, SyscallResultTrait, syscalls::deploy_syscall};
#[starknet::interface]
pub trait IERC20MintableBurnable<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, amount: u256);
    fn burn_from(ref self: TContractState, account: ContractAddress, amount: u256);
}

fn erc20_mint(contract_address: ContractAddress, recipient: ContractAddress, amount: u256) {
    IERC20MintableBurnableDispatcher { contract_address }.mint(recipient, amount);
}

fn erc20_burn_from(contract_address: ContractAddress, account: ContractAddress, amount: u256) {
    IERC20MintableBurnableDispatcher { contract_address }.burn_from(account, amount);
}

fn erc20_transfer(contract_address: ContractAddress, recipient: ContractAddress, amount: u256) {
    ERC20ABIDispatcher { contract_address }.transfer(recipient, amount);
}

fn erc20_transfer_from(
    contract_address: ContractAddress,
    sender: ContractAddress,
    recipient: ContractAddress,
    amount: u256,
) {
    ERC20ABIDispatcher { contract_address }.transfer_from(sender, recipient, amount);
}

fn erc20_balance_of(contract_address: ContractAddress, account: ContractAddress) -> u256 {
    ERC20ABIDispatcher { contract_address }.balance_of(account)
}

fn deploy_erc20_mintable_burnable(
    class_hash: ClassHash,
    salt: felt252,
    name: ByteArray,
    symbol: ByteArray,
    decimals: u8,
    default_admin: ContractAddress,
    minter: ContractAddress,
) -> ContractAddress {
    let mut calldata = ArrayTrait::<felt252>::new();

    name.serialize(ref calldata);
    symbol.serialize(ref calldata);
    calldata.append_span([decimals.into(), default_admin.into(), minter.into()].span());
    let (contract_address, _) = deploy_syscall(class_hash, salt, calldata.span(), true)
        .unwrap_syscall();
    contract_address
}

#[starknet::contract]
mod erc20_mintable_burnable {
    use openzeppelin_access::accesscontrol::{AccessControlComponent, DEFAULT_ADMIN_ROLE};
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc20::{ERC20Component, ERC20HooksEmptyImpl, interface::IERC20Metadata};
    use starknet::{ContractAddress, get_caller_address};
    use super::IERC20MintableBurnable;

    const MINTER_ROLE: felt252 = 'MINTER_ROLE';

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    // External
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl AccessControlMixinImpl =
        AccessControlComponent::AccessControlMixinImpl<ContractState>;

    // Internal
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        decimals: u8,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        decimals: u8,
        default_admin: ContractAddress,
        minter: ContractAddress,
    ) {
        self.erc20.initializer(name, symbol);
        self.decimals.write(decimals);
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, default_admin);
        self.accesscontrol._grant_role(MINTER_ROLE, minter);
    }

    #[abi(embed_v0)]
    impl ERC20MetadataImpl of IERC20Metadata<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            self.erc20.name()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self.erc20.symbol()
        }

        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }
    }

    #[abi(embed_v0)]
    impl ERC20MintableBurnableImpl of IERC20MintableBurnable<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.accesscontrol.assert_only_role(MINTER_ROLE);
            self.erc20.mint(recipient, amount);
        }
        fn burn(ref self: ContractState, amount: u256) {
            self.erc20.burn(get_caller_address(), amount);
        }
        fn burn_from(ref self: ContractState, account: ContractAddress, amount: u256) {
            self.erc20._spend_allowance(account, get_caller_address(), amount);
            self.erc20.burn(account, amount);
        }
    }
}
