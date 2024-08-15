use starknet::{ContractAddress, ClassHash};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IERC20Debris<TState> {

    fn world(self: @TState,) -> IWorldDispatcher;
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
    fn dojo_resource(self: @TState,) -> felt252;

    // IERC20Metadata
    fn decimals(self: @TState,) -> u8;
    fn name(self: @TState,) -> felt252;
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
mod ERC20_debris_component {
    use super::IERC20Debris;

    use starknet::{ContractAddress, get_contract_address};
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };
    
    use origami_token::components::token::erc20::{
        erc20_metadata::{
            ERC20MetadataModel, ERC20MetadataModelTrait
        },
        erc20_balance::{
            ERC20BalanceModel, ERC20BalanceModelTrait
        }
        erc20_allowance::{
            ERC20AllowanceModel, ERC20AllowanceModelTrait
        }
    };


    #[storage]
    struct Storage {
        erc20_metadata: ERC20MetadataModel,
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
    #[derive(Copy, Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer
    }

    
    mod Errors {
        const CALLER_IS_NOT_OWNER: felt252 = 'ERC20: caller is not owner';
        const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
        const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
        const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
        const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
    }

    #[embeddable_as(ERC20DebrisImpl)]
    impl ERC20Debris<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of IERC20Debris<ComponentState<TContractState>> {
        fn name(self: @ComponentState<TContractState>) -> felt252 {
            self.get_metadata().name
        }
        fn symbol(self: @ComponentState<TContractState>) -> felt252 {
            self.get_metadata().symbol
        }
        fn decimals(self: @ComponentState<TContractState>) -> u8 {
            self.get_metadata().decimals
        }
        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            self.get_metadata().total_supply
        }
        fn totalSupply(self: @ComponentState<TContractState>) -> u256 {
            self.total_supply()
        }
        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            self.get_balance(account).amount
        }

        fn transfer(
            ref self: ComponentState<TContractState>, recipient: ContractAddress, amount: u256
        ) -> bool {
            let sender = get_caller_address();
            self.transfer_internal(sender, recipient, amount);
            true
        }

        fn transfer_from(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let caller = get_caller_address();
            let mut erc20_allowance = get_dep_component_mut!(ref self, ERC20Allowance);
            erc20_allowance.spend_allowance(sender, caller, amount);
            self.transfer_internal(sender, recipient, amount);
            true
        }
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            self.balance_of(account)
        }

        fn transferFrom(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            self.transfer_from(sender, recipient, amount)
        }
    }   

    #[generate_trait]
    impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
    > of InternalTrait<TContractState> {
        fn get_metadata(self: @ComponentState<TContractState>) -> ERC20MetadataModel {

            ERC20MetadataModelTrait::get(self.get_contract().world(), get_contract_address())
        }

        fn get_balance(
            self: @ComponentState<TContractState>, account: ContractAddress
        ) -> ERC20BalanceModel {
            ERC20BalanceModelTrait::get(self.get_contract().world(), (get_contract_address(), account))
        }

        fn get_allowance(
            self: @ComponentState<TContractState>, owner: ContractAddress, spender: ContractAddress,
        ) -> ERC20AllowanceModel {
            ERC20AllowanceModelTrait::get(self.get_contract().world(), (get_contract_address(), owner, spender))
        }

        fn initialize(
            ref self: ComponentState<TContractState>, name: felt252, symbol: felt252, decimals: u8
        ) {

        }

        // Helper function to update total_supply model
        fn update_total_supply(
            ref self: ComponentState<TContractState>, subtract: u256, add: u256
        ) {
            let mut meta = self.get_metadata();
            // adding and subtracting is fewer steps than if
            meta.total_supply = meta.total_supply - subtract;
            meta.total_supply = meta.total_supply + add;
            meta.set(self.get_contract().world());
        }
        
        fn update_balance(
            ref self: ComponentState<TContractState>,
            account: ContractAddress,
            subtract: u256,
            add: u256
        ) {
            let mut balance = self.get_balance(account);
            // adding and subtracting is fewer steps than if
            balance.amount = balance.amount - subtract;
            balance.amount = balance.amount + add;
            balance.set(self.get_contract().world());
        }

        fn transfer_internal(
            ref self: ComponentState<TContractState>,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            assert(!sender.is_zero(), Errors::TRANSFER_FROM_ZERO);
            assert(!recipient.is_zero(), Errors::TRANSFER_TO_ZERO);
            self.update_balance(sender, amount, 0);
            self.update_balance(recipient, 0, amount);

            let transfer_event = Transfer { from: sender, to: recipient, value: amount };

            self.emit(transfer_event.clone());
            emit!(self.get_contract().world(), (Event::Transfer(transfer_event)));
        }
    }
}