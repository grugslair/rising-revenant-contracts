use starknet::ContractAddress;

const ERC20_DOMAIN: felt252 = 'ERC721';
const ERC20_CORE_PATH: felt252 = 'core';


#[dojo::interface]
trait IERC721CoreBasic<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, token_id: u256);
    fn burn(ref self: TContractState, token_id: u256);
    fn transfer(ref self: TContractState, token_id: u256, recipient: ContractAddress); 
}

#[dojo::interface]
trait IERC721Core<TContractState>{
    fn get_balance(self: @TContractState, account: ContractAddress) -> u128;
    fn get_owner(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_approval(self: @TContractState, token_id: u256) -> ContractAddress;
    fn set_approval(ref self: TContractState, token_id: u256, address: ContractAddress);
    fn get_approval_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn set_approval_for_all(
        ref self: TContractState, owner: ContractAddress, operator: ContractAddress, approved: bool
    );
}


#[dojo::interface]
trait IERC721CoreEnumerable<TContractState>{
    fn get_total_supply(self: @TContractState) -> u128;
    fn get_id_by_index(self: @TContractState, index: u128) -> u256 ;
    fn get_id_from_owner_index(self: @TContractState, owner:ContractAddress, index: u128)->u256 ;

    fn mint_enumerable(ref self: TContractState, recipient: ContractAddress, token_id: u256);
    fn burn_enumerable(ref self: TContractState, token_id: u256);
    fn transfer_enumerable(ref self: TContractState, token_id: u256, recipient: ContractAddress);
}