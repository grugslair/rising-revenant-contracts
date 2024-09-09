use starknet::ContractAddress;

const ERC20_DOMAIN: felt252 = 'ERC20';
const ERC20_CORE_PATH: felt252 = 'core';


#[dojo::interface]
trait IERC20Core<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, account: ContractAddress, amount: u256);
    fn get_total_supply(self: @TContractState) -> u256;
    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;
    fn get_allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress
    ) -> u256;
    fn set_allowance(
        ref self: TContractState, owner: ContractAddress, spender: ContractAddress, amount: u256,
    );
    fn increase_allowance(
        ref self: TContractState, owner: ContractAddress, spender: ContractAddress, amount: u256,
    );
    fn decrease_allowance(
        ref self: TContractState, owner: ContractAddress, spender: ContractAddress, amount: u256,
    );
    fn transfer(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    );
    fn transfer_from(
        ref self: TContractState,
        caller: ContractAddress,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    );
}
