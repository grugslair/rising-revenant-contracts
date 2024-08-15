use starknet::ContractAddress;

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct ERC20TotalSupplyModel {
    #[key]
    pub token: ContractAddress,
    pub total_supply: u256,
}


#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ERC20BalanceModel {
    #[namespace]
    namespace: felt252,
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
