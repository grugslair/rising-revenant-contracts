use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use super::models::Rarity;
use rising_revenant::{addresses::{AddressBook,}, address_selectors::CARE_PACKAGE_TOKEN_SELECTOR};


#[starknet::interface]
pub trait ICarePackageToken<TContractState> {
    fn mint(ref self: TContractState, to: ContractAddress, rarity: Rarity);
    fn burn_from(ref self: TContractState, token_id: u256);
    fn set_writer(ref self: TContractState, writer: ContractAddress, authorized: bool);
    fn get_rarity(self: @TContractState, token_id: u256) -> Rarity;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
}

#[generate_trait]
impl CarePackageTokenImpl of GetDispatcher {
    fn get_dispatcher(self: @IWorldDispatcher) -> ICarePackageTokenDispatcher {
        ICarePackageTokenDispatcher {
            contract_address: self.get_address(CARE_PACKAGE_TOKEN_SELECTOR)
        }
    }
}
