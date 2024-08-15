use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;


use ERC20_basic_component::{Transfer, Approval};

mod Errors {
    const CALLER_IS_NOT_OWNER: felt252 = 'ERC20: caller is not owner';
    const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
    const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
    const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
    const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
    const INSUFFICIENT_ALLOWANCE: felt252 = 'ERC20: insufficient allowance';
    const INSUFFICIENT_BALANCE: felt252 = 'ERC20: insufficient balance';
    const INSUFFICIENT_TOTAL_SUPPLY: felt252 = 'ERC20: insufficient supply';
}

#[event]
#[derive(Copy, Drop, starknet::Event)]
enum Event {
    Transfer: Transfer,
    Approval: Approval
}

trait IERC20MintTrait {
    fn mint(self: IWorldDispatcher, recipient: ContractAddress, amount: u256) -> Transfer;
}

trait IERC20BurnTrait {
    fn burn(self: IWorldDispatcher, account: ContractAddress, amount: u256) -> Transfer;
}

trait IERC20MetadataTrait {
    fn name(self: @IWorldDispatcher) -> ByteArray;
    fn symbol(self: @IWorldDispatcher) -> felt252;
    fn decimals(self: @IWorldDispatcher) -> u8;
}

trait IERC20TotalSupplyTrait {
    fn total_supply(self: @IWorldDispatcher) -> u256;
}

trait IERC20BalanceTrait {
    fn balance_of(self: @IWorldDispatcher, account: ContractAddress) -> u256;
}

trait IERC20TransferTrait {
    fn transfer(self: IWorldDispatcher, recipient: ContractAddress, amount: u256) -> Transfer;
    fn transfer_from(
        self: IWorldDispatcher, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> (Transfer, Approval);
}

trait IERC20AllowanceTrait {
    fn allowance(self: @IWorldDispatcher, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn approve(self: IWorldDispatcher, spender: ContractAddress, amount: u256) -> Approval;
}

#[starknet::interface]
trait IERC20Mint<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait IERC20Basic<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    // IERC20Metadata
    fn decimals(self: @TState,) -> u8;
    fn name(self: @TState,) -> ByteArray;
    fn symbol(self: @TState,) -> felt252;

    fn total_supply(self: @TState,) -> u256;
    fn totalSupply(self: @TState,) -> u256;

    // IERC20Balance
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;

    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;
}

#[starknet::component]
pub mod ERC20_basic_component {
    use super::{
        IERC20Basic, IERC20MintTrait, IERC20MetadataTrait, IERC20TotalSupplyTrait,
        IERC20BalanceTrait, IERC20TransferTrait, IERC20AllowanceTrait,
    };

    use starknet::ContractAddress;
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };

    #[storage]
    struct Storage {}

    #[derive(Copy, Drop, Serde, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256
    }

    #[derive(Copy, Drop, Serde, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256
    }

    #[event]
    #[derive(Copy, Drop, Serde, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval
    }

    #[embeddable_as(ERC20BasicImpl)]
    impl ERC20Basic<
        TContractState,
        impl MintImpl: IERC20MintTrait,
        impl MetaDataImpl: IERC20MetadataTrait,
        impl TotalSupplyImpl: IERC20TotalSupplyTrait,
        impl BalanceImpl: IERC20BalanceTrait,
        impl TransferImpl: IERC20TransferTrait,
        impl AllowanceImpl: IERC20AllowanceTrait,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of IERC20Basic<ComponentState<TContractState>> {
        fn mint(
            ref self: ComponentState<TContractState>, recipient: ContractAddress, amount: u256
        ) -> bool {
            self.emit(MintImpl::mint(self.get_contract().world(), recipient, amount));
            true
        }
        fn name(self: @ComponentState<TContractState>) -> ByteArray {
            MetaDataImpl::name(@self.get_contract().world())
        }
        fn symbol(self: @ComponentState<TContractState>) -> felt252 {
            MetaDataImpl::symbol(@self.get_contract().world())
        }
        fn decimals(self: @ComponentState<TContractState>) -> u8 {
            MetaDataImpl::decimals(@self.get_contract().world())
        }
        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            TotalSupplyImpl::total_supply(@self.get_contract().world(),)
        }

        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            BalanceImpl::balance_of(@self.get_contract().world(), account)
        }

        fn transfer(
            ref self: ComponentState<TContractState>, recipient: ContractAddress, amount: u256
        ) -> bool {
            self.emit(TransferImpl::transfer(self.get_contract().world(), recipient, amount));
            true
        }

        fn transfer_from(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let (transfer_event, approval_event) = TransferImpl::transfer_from(
                self.get_contract().world(), sender, recipient, amount
            );
            self.emit(transfer_event);
            self.emit(approval_event);
            true
        }

        fn allowance(
            self: @ComponentState<TContractState>, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            AllowanceImpl::allowance(@self.get_contract().world(), owner, spender)
        }
        fn approve(
            ref self: ComponentState<TContractState>, spender: ContractAddress, amount: u256
        ) -> bool {
            let approval_event = AllowanceImpl::approve(
                self.get_contract().world(), spender, amount
            );
            self.emit(approval_event);
            true
        }
        fn transferFrom(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            Self::transfer_from(ref self, sender, recipient, amount)
        }
        fn totalSupply(self: @ComponentState<TContractState>) -> u256 {
            Self::total_supply(self)
        }
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            Self::balance_of(self, account)
        }
    }
}
