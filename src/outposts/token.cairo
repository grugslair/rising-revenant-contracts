use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;
use rising_revenant::{
    addresses::{AddressBook, GetDispatcher}, address_selectors::OUTPOST_TOKEN_SELECTOR
};

#[starknet::interface]
pub trait IOutpostToken<TContractState> {
    fn mint(ref self: TContractState, to: ContractAddress);
    fn burn_from(ref self: TContractState, token_id: u256);
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
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

impl CarePackageTokenImpl of GetDispatcher<IOutpostTokenDispatcher> {
    fn get_dispatcher(self: @IWorldDispatcher) -> IOutpostTokenDispatcher {
        IOutpostTokenDispatcher { contract_address: self.get_address(OUTPOST_TOKEN_SELECTOR) }
    }
}
