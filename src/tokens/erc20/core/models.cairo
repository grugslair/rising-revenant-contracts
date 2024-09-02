use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC20TotalSupplyModel {
    #[key]
    token: ContractAddress,
    total_supply: u256,
}


#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ERC20BalanceModel {
    #[key]
    token: ContractAddress,
    #[key]
    account: ContractAddress,
    amount: u256,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ERC20AllowanceModel {
    #[key]
    token: ContractAddress,
    #[key]
    owner: ContractAddress,
    #[key]
    spender: ContractAddress,
    amount: u256,
}

#[generate_trait]
impl ERC20ReadImpl of ERC20Read {
    fn get_total_supply(self: @IWorldDispatcher, token: ContractAddress) -> u256 {
        ERC20TotalSupplyModelStore::get_total_supply(*self, token)
    }

    fn get_balance(
        self: @IWorldDispatcher, token: ContractAddress, account: ContractAddress
    ) -> u256 {
        ERC20BalanceModelStore::get_amount(*self, token, account)
    }

    fn get_allowance(
        self: @IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        spender: ContractAddress
    ) -> u256 {
        ERC20AllowanceModelStore::get_amount(*self, token, owner, spender)
    }
}

#[generate_trait]
impl ERC20WriteImpl of ERC20Write {
    fn set_total_supply(self: IWorldDispatcher, token: ContractAddress, total_supply: u256) {
        let total_supply_model = ERC20TotalSupplyModel { token, total_supply, };
        total_supply_model.set(self);
    }

    fn set_balance(
        self: IWorldDispatcher, token: ContractAddress, account: ContractAddress, amount: u256
    ) {
        let balance_model = ERC20BalanceModel { token, account, amount, };
        balance_model.set(self);
    }

    fn set_allowance(
        self: IWorldDispatcher,
        token: ContractAddress,
        owner: ContractAddress,
        spender: ContractAddress,
        amount: u256,
    ) {
        let allowance_model = ERC20AllowanceModel { token, owner, spender, amount, };
        allowance_model.set(self);
    }
}
