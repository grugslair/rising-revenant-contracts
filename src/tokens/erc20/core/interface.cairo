use starknet::ContractAddress;

#[dojo::interface]
trait IERC20Core<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, account: ContractAddress, amount: u256);
    fn get_total_supply(self: @TContractState) -> u256;
    fn set_total_supply(ref self: TContractState, total_supply: u256);
    fn increase_total_supply(ref self: TContractState, amount: u256);
    fn decrease_total_supply(ref self: TContractState, amount: u256);
    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;
    fn set_balance(ref self: TContractState, account: ContractAddress, amount: u256);
    fn increase_balance(ref self: TContractState, account: ContractAddress, amount: u256);
    fn decrease_balance(ref self: TContractState, account: ContractAddress, amount: u256);
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
