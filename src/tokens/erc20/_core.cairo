use starknet::ContractAddress;
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};

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

const ERC20_CONTRACT_ADDRESS: felt252 = 0;

fn get_erc20_core_dispatcher() -> IERC20CoreDispatcher {
    IERC20CoreDispatcher { contract_address: ERC20_CONTRACT_ADDRESS.try_into().unwrap(), }
}

#[dojo::interface]
trait IERC20Core {
    fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn burn(ref self: ContractState, account: ContractAddress, amount: u256) -> bool;
    fn get_total_supply(self: @ContractState) -> u256;
    fn set_total_supply(ref self: ContractState, total_supply: u256);
    fn increase_total_supply(ref self: ContractState, amount: u256);
    fn decrease_total_supply(ref self: ContractState, amount: u256);
    fn get_balance(self: @ContractState, account: ContractAddress) -> u256;
    fn set_balance(ref self: ContractState, account: ContractAddress, amount: u256);
    fn increase_balance(ref self: ContractState, account: ContractAddress, amount: u256);
    fn decrease_balance(ref self: ContractState, account: ContractAddress, amount: u256);
    fn get_allowance(
        self: @ContractState, owner: ContractAddress, spender: ContractAddress
    ) -> u256;
    fn set_allowance(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
    );
    fn increase_allowance(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
    );
    fn decrease_allowance(
        ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
    );
    fn transfer(
        ref self: ContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
        use_allowance: bool
    ) -> bool;
}
#[dojo::contract]
mod erc20_core {
    use dojo::model::Model;
    use starknet::{ContractAddress, get_caller_address};
    use super::super::{
        models::{
            ERC20TotalSupplyModel, ERC20AllowanceModel, ERC20BalanceModel,
            ERC20TotalSupplyModelStore, ERC20AllowanceModelStore, ERC20BalanceModelStore,
        }
    };
    use super::{IERC20Core, Errors};

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

    #[abi(embed_v0)]
    impl ERC20CoreImpl of IERC20Core<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            self.increase_total_supply_value(amount);
            self.increase_balance_value(recipient, amount);
            true
        }
        fn burn(ref self: ContractState, account: ContractAddress, amount: u256) -> bool {
            self.decrease_total_supply_value(amount);
            self.decrease_balance_value(account, amount);
            true
        }
        fn get_total_supply(self: @ContractState) -> u256 {
            self.get_total_supply_value()
        }
        fn set_total_supply(ref self: ContractState, total_supply: u256) {
            self.set_total_supply_value(total_supply)
        }
        fn increase_total_supply(ref self: ContractState, amount: u256) {
            self.increase_total_supply_value(amount);
        }
        fn decrease_total_supply(ref self: ContractState, amount: u256) {
            self.decrease_total_supply_value(amount);
        }
        fn get_balance(self: @ContractState, account: ContractAddress) -> u256 {
            self.get_balance_value(account)
        }
        fn set_balance(ref self: ContractState, account: ContractAddress, amount: u256) {
            self.set_balance_value(account, amount)
        }
        fn increase_balance(ref self: ContractState, account: ContractAddress, amount: u256) {
            self.increase_balance_value(account, amount)
        }
        fn decrease_balance(ref self: ContractState, account: ContractAddress, amount: u256) {
            self.decrease_balance_value(account, amount)
        }
        fn get_allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.get_allowance_value(owner, spender)
        }
        fn set_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            self.set_allowance_value(owner, spender, amount)
        }
        fn increase_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let allowance = self.get_allowance_value(owner, spender);
            self.set_allowance_value(owner, spender, allowance + amount);
        }
        fn decrease_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            self.decrease_allowance_value(owner, spender, amount);
        }
        fn transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
            use_allowance: bool
        ) -> bool {
            let world = self.world();
            if use_allowance {
                self.decrease_allowance_value(sender, recipient, amount);
            }
            let transfer = Transfer { from: sender, to: recipient, value: amount };
            self.decrease_balance_value(sender, amount);
            self.increase_balance_value(recipient, amount);
            self.emit(transfer.clone());
            emit!(world, (transfer));
            true
        }
    }


    #[generate_trait]
    impl ERC20ModelImpl of ERC20ModelTrait {
        fn get_total_supply_value(self: @ContractState) -> u256 {
            ERC20TotalSupplyModelStore::get_total_supply(*self.world(), get_caller_address())
        }

        fn set_total_supply_value(self: ContractState, total_supply: u256) {
            let total_supply_model = ERC20TotalSupplyModel {
                token: get_caller_address(), total_supply
            };
            total_supply_model.set(self.world())
        }

        fn increase_total_supply_value(self: ContractState, amount: u256) {
            let total_supply = self.get_total_supply_value();
            self.set_total_supply_value(total_supply + amount);
        }
        fn decrease_total_supply_value(self: ContractState, amount: u256) {
            let total_supply = self.get_total_supply_value();
            assert(total_supply >= amount, Errors::INSUFFICIENT_TOTAL_SUPPLY);
            self.set_total_supply_value(total_supply - amount);
        }

        fn get_balance_value(self: @ContractState, account: ContractAddress) -> u256 {
            ERC20BalanceModelStore::get_amount(*self.world(), get_caller_address(), account)
        }

        fn set_balance_value(self: ContractState, account: ContractAddress, amount: u256) {
            let balance_model = ERC20BalanceModel { token: get_caller_address(), account, amount };
            balance_model.set(self.world());
        }
        fn increase_balance_value(self: ContractState, account: ContractAddress, amount: u256) {
            let balance = self.get_balance_value(account);
            self.set_balance_value(account, balance + amount);
        }
        fn decrease_balance_value(self: ContractState, account: ContractAddress, amount: u256) {
            let balance = self.get_balance_value(account);
            assert(balance >= amount, Errors::INSUFFICIENT_BALANCE);
            self.set_balance_value(account, balance - amount);
        }

        fn get_allowance_value(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            ERC20AllowanceModelStore::get_amount(
                *self.world(), get_caller_address(), owner, spender
            )
        }

        fn set_allowance_value(
            self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let world = self.world();
            let allowance_model = ERC20AllowanceModel {
                token: get_caller_address(), owner, spender, amount
            };
            let approval = Approval { owner, spender, value: amount };
            allowance_model.set(world);
            self.emit(approval.clone());
            emit!(world, (approval));
        }
        fn decrease_allowance_value(
            self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            let allowance = self.get_allowance_value(owner, spender);
            assert(allowance >= amount, Errors::INSUFFICIENT_ALLOWANCE);
            self.set_allowance_value(owner, spender, allowance - amount);
        }
    }
}
