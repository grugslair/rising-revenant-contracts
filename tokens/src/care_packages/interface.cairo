use starknet::ContractAddress;
use super::models::Rarity;

#[starknet::interface]
pub trait ICarePackage<TContractState> {
    fn mint(ref self: TContractState, to: ContractAddress, rarity: Rarity);
    fn burn_from(ref self: TContractState, token_id: u256);
    fn set_writer(ref self: TContractState, writer: ContractAddress, authorized: bool);
    fn get_rarity(self: @TContractState, token_id: u256) -> Rarity;
}

