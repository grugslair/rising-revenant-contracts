use starknet::{ContractAddress, get_caller_address};
use super::{
    basic::{IERC20TotalSupplyTrait, IERC20BalanceTrait, IERC20TransferTrait, IERC20AllowanceTrait,},
    core::{IERC20CoreDispatcher, IERC20CoreDispatcherTrait, get_erc20_core_dispatcher}
};


#[generate_trait]
impl ERC20CoreImpl of ERC20CoreTrait {
    fn get_dispatcher(self: @ContractState) -> IERC20CoreDispatcher {
        IERC20CoreDispatcher { contract_address: self.core_contract_address.read() }
    }
}

impl ERC20BasicTotalSupplyImpl of IERC20TotalSupplyTrait {
    fn total_supply(self: @ContractState) -> u256 {
        self.get_dispatcher().get_total_supply()
    }
}

impl ERC20BasicBalanceImpl of IERC20BalanceTrait {
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        self.get_dispatcher().get_balance(account)
    }
}

impl ERC20BasicTransferImpl of IERC20TransferTrait {
    fn transfer(self: ContractState, recipient: ContractAddress, amount: u256) -> Transfer {
        self.get_dispatcher().transfer(get_caller_address(), recipient, amount);
    }

    fn transfer_from(
        self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> (Transfer, Approval) {
        self.get_dispatcher().transfer_from(get_caller_address(), sender, recipient, amount);
    }
}

impl ERC20BasicAllowanceImpl of IERC20AllowanceTrait {
    fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
        self.get_dispatcher().get_allowance(owner, spender)
    }

    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
        self.get_dispatcher().approve(get_caller_address(), spender, amount);
    }
}

#[generate_trait]
impl ERC20MintImpl of ERC20MintTrait {
    fn mint_token(self: ContractState, recipient: ContractAddress, amount: u256) -> Transfer {
        self.increase_total_supply(amount);
        self.increase_balance(recipient, amount);
        let transfer_event = Transfer { from: Zeroable::zero(), to: recipient, value: amount };
        emit!(self, (Event::Transfer(transfer_event.clone())));
        transfer_event
    }
}

