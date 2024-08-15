use starknet::{ContractAddress, get_caller_address, get_contract_address};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
use super::{
    basic::{
        Transfer, Approval, IERC20MetadataTrait, IERC20TotalSupplyTrait, IERC20BalanceTrait,
        IERC20TransferTrait, IERC20AllowanceTrait, Errors, Event, IERC20MintTrait
    },
    models::{
        ERC20TotalSupplyModel, ERC20AllowanceModel, ERC20BalanceModel, ERC20TotalSupplyModelStore,
        ERC20AllowanceModelStore, ERC20BalanceModelStore,
    },
    core::{IERC20CoreDispatcher, IERC20CoreDispatcherTrait, get_erc20_core_dispatcher}
};

impl ERC20BasicTotalSupplyImpl of IERC20TotalSupplyTrait {
    fn total_supply(self: @IWorldDispatcher) -> u256 {
        self.get_total_supply().total_supply
    }
}

impl ERC20BasicBalanceImpl of IERC20BalanceTrait {
    fn balance_of(self: @IWorldDispatcher, account: ContractAddress) -> u256 {
        let balance = ERC20BalanceModelStore::get(*self, get_contract_address(), account);
        balance.amount
    }
}

impl ERC20BasicTransferImpl of IERC20TransferTrait {
    fn transfer(self: IWorldDispatcher, recipient: ContractAddress, amount: u256) -> Transfer {
        let caller = get_caller_address();

        self.make_transfer(caller, recipient, amount)
    }

    fn transfer_from(
        self: IWorldDispatcher, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> (Transfer, Approval) {
        let caller = get_caller_address();
        let approval_event = self.spend_allowance(sender, caller, amount);
        (self.make_transfer(sender, recipient, amount), approval_event)
    }
}

impl ERC20BasicAllowanceImpl of IERC20AllowanceTrait {
    fn allowance(
        self: @IWorldDispatcher, owner: ContractAddress, spender: ContractAddress
    ) -> u256 {
        self.get_allowance(owner, spender).amount
    }

    fn approve(self: IWorldDispatcher, spender: ContractAddress, amount: u256) -> Approval {
        let caller = get_caller_address();
        let allowance = ERC20AllowanceModel {
            token: get_contract_address(), owner: caller, spender: spender, amount: amount
        };
        self.set_allowance(allowance);
        Approval { owner: caller, spender, value: amount }
    }
}

#[generate_trait]
impl ERC20MintImpl of ERC20MintTrait {
    fn mint_token(self: IWorldDispatcher, recipient: ContractAddress, amount: u256) -> Transfer {
        self.increase_total_supply(amount);
        self.increase_balance(recipient, amount);
        let transfer_event = Transfer { from: Zeroable::zero(), to: recipient, value: amount };
        emit!(self, (Event::Transfer(transfer_event.clone())));
        transfer_event
    }
}

#[generate_trait]
impl ERC20TotalSupplyImpl of ERC20TotalSupplyTrait {
    fn get_total_supply(self: @IWorldDispatcher) -> ERC20TotalSupplyModel {
        ERC20TotalSupplyModelStore::get(*self, get_contract_address())
    }
    fn increase_total_supply(self: IWorldDispatcher, amount: u256) {
        let mut total_supply = self.get_total_supply();
        total_supply.total_supply += amount;
        total_supply.set(self);
    }
    fn decrease_total_supply(self: IWorldDispatcher, amount: u256) {
        let mut total_supply = self.get_total_supply();
        assert(total_supply.total_supply >= amount, Errors::INSUFFICIENT_TOTAL_SUPPLY);
        total_supply.total_supply -= amount;
        total_supply.set(self);
    }
}

#[generate_trait]
impl ERC20AllowanceImpl of ERC20AllowanceTrait {
    fn get_allowance(
        self: @IWorldDispatcher, owner: ContractAddress, spender: ContractAddress
    ) -> ERC20AllowanceModel {
        ERC20AllowanceModelStore::get(*self, get_contract_address(), owner, spender)
    }
    fn set_allowance(self: IWorldDispatcher, allowance: ERC20AllowanceModel) {
        assert(!allowance.owner.is_zero(), Errors::APPROVE_FROM_ZERO);
        assert(!allowance.spender.is_zero(), Errors::APPROVE_TO_ZERO);
        allowance.set(self);

        let approval_event = Approval {
            owner: allowance.owner, spender: allowance.spender, value: allowance.amount
        };

        emit!(self, (Event::Approval(approval_event)));
    }
    fn spend_allowance(
        self: IWorldDispatcher, owner: ContractAddress, spender: ContractAddress, amount: u256
    ) -> Approval {
        let mut allowance = self.get_allowance(owner, spender);
        assert(allowance.amount >= amount, Errors::INSUFFICIENT_ALLOWANCE);
        allowance.amount -= amount;
        self.set_allowance(allowance);
        Approval { owner, spender, value: allowance.amount }
    }
}

#[generate_trait]
impl ERC20BalanceImpl of ERC20BalanceTrait {
    fn get_balance(self: @IWorldDispatcher, account: ContractAddress) -> ERC20BalanceModel {
        ERC20BalanceModelStore::get(*self, get_contract_address(), account)
    }
    fn increase_balance(self: IWorldDispatcher, account: ContractAddress, amount: u256) {
        let mut balance = self.get_balance(account);
        balance.amount += amount;
        balance.set(self);
    }
    fn decrease_balance(self: IWorldDispatcher, account: ContractAddress, amount: u256) {
        let mut balance = self.get_balance(account);
        assert(balance.amount >= amount, Errors::INSUFFICIENT_BALANCE);
        balance.amount -= amount;
        balance.set(self);
    }
}

#[generate_trait]
impl ERC20TransferImpl of ERC20TransferTrait {
    fn make_transfer(
        self: IWorldDispatcher,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
        use_allowance: bool
    ) -> Transfer {
        assert(!sender.is_zero(), Errors::TRANSFER_FROM_ZERO);
        assert(!recipient.is_zero(), Errors::TRANSFER_TO_ZERO);
        get_erc20_core_dispatcher().transfer(sende, recipient, amount, use_allowance);
        let transfer_event = Transfer { from: sender, to: recipient, value: amount };
        emit!(self, (Event::Transfer(transfer_event.clone())));
        transfer_event
    }
}

