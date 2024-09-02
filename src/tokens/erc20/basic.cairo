use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use super::IERC20CoreDispatcher;
trait IERC20MintTrait {
    fn mint(
        self: IWorldDispatcher, core: IERC20CoreDispatcher, recipient: ContractAddress, amount: u256
    ) -> bool;
}

trait IERC20BurnTrait {
    fn burn(
        self: IWorldDispatcher, core: IERC20CoreDispatcher, account: ContractAddress, amount: u256
    ) -> bool;
}

trait IERC20MetadataTrait {
    fn name() -> ByteArray;
    fn symbol() -> felt252;
    fn decimals() -> u8;
}

#[starknet::interface]
trait IERC20Mint<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait IERC20Basic<TState> {
    fn decimals(self: @TState,) -> u8;
    fn name(self: @TState,) -> ByteArray;
    fn symbol(self: @TState,) -> felt252;

    fn total_supply(self: @TState,) -> u256;

    fn balance_of(self: @TState, account: ContractAddress) -> u256;

    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;

    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;

    fn totalSupply(self: @TState,) -> u256;
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
}

#[starknet::component]
pub mod ERC20_basic_component {
    use super::super::{ERC20Read, IERC20CoreDispatcher, IERC20CoreDispatcherTrait};
    use super::{IERC20Basic, IERC20MetadataTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };

    #[storage]
    struct Storage {
        core_contract_address: ContractAddress,
    }

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
        impl MetaDataImpl: IERC20MetadataTrait,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of IERC20Basic<ComponentState<TContractState>> {
        fn name(self: @ComponentState<TContractState>) -> ByteArray {
            MetaDataImpl::name()
        }
        fn symbol(self: @ComponentState<TContractState>) -> felt252 {
            MetaDataImpl::symbol()
        }
        fn decimals(self: @ComponentState<TContractState>) -> u8 {
            MetaDataImpl::decimals()
        }

        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            self.get_total_supply_value()
        }

        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            self.get_balance_value(account)
        }

        fn allowance(
            self: @ComponentState<TContractState>, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.get_allowance_value(owner, spender)
        }
        fn approve(
            ref self: ComponentState<TContractState>, spender: ContractAddress, amount: u256
        ) -> bool {
            let owner = get_caller_address();
            self.get_core_dispatcher().set_allowance(owner, spender, amount);
            self.emit_approval_event(owner, spender, amount);
            true
        }

        fn transfer(
            ref self: ComponentState<TContractState>, recipient: ContractAddress, amount: u256
        ) -> bool {
            let sender = get_caller_address();
            self.get_core_dispatcher().transfer(sender, recipient, amount);
            self.emit_transfer_event(sender, recipient, amount);
            true
        }
        fn transfer_from(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            self.get_core_dispatcher().transfer_from(caller, sender, recipient, amount);
            self.emit_transfer_event(sender, recipient, amount);
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


    #[generate_trait]
    impl PrivateImpl<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of PrivateTrait<TContractState> {
        fn get_total_supply_value(self: @ComponentState<TContractState>) -> u256 {
            self.get_contract().world().get_total_supply(get_contract_address())
        }
        fn get_balance_value(
            self: @ComponentState<TContractState>, account: ContractAddress
        ) -> u256 {
            self.get_contract().world().get_balance(get_contract_address(), account)
        }
        fn get_allowance_value(
            self: @ComponentState<TContractState>, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.get_contract().world().get_allowance(get_contract_address(), owner, spender)
        }
        fn get_core_dispatcher(self: @ComponentState<TContractState>) -> IERC20CoreDispatcher {
            IERC20CoreDispatcher { contract_address: self.core_contract_address.read() }
        }
        fn emit_transfer_event(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            value: u256
        ) {
            let transfer_event = Transfer { from, to, value };
            self.emit(transfer_event.clone());
            emit!(self.get_contract().world(), (Event::Transfer(transfer_event)));
        }
        fn emit_approval_event(
            ref self: ComponentState<TContractState>,
            owner: ContractAddress,
            spender: ContractAddress,
            value: u256
        ) {
            let approval_event = Approval { owner, spender, value };
            self.emit(approval_event.clone());
            emit!(self.get_contract().world(), (Event::Approval(approval_event)));
        }
    }
}
