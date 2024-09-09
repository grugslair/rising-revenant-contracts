use starknet::{ContractAddress, get_contract_address, event::EventEmitter};
use dojo::world::{IWorldProvider, IWorldDispatcher, IWorldDispatcherTrait};

use super::{
    ERC721Read, IERC721CoreDispatcher, IERC721CoreDispatcherTrait, IERC721CoreBasicDispatcher,
    IERC721CoreBasicDispatcherTrait, IERC721CoreEnumerableDispatcher,
    IERC721CoreEnumerableDispatcherTrait,
};


trait GetERC721CoreDispatcherTrait<TContractState> {
    fn get_erc721_core_dispatcher(self: @TContractState) -> IERC721CoreDispatcher;
    fn get_erc721_core_basic_dispatcher(self: @TContractState) -> IERC721CoreBasicDispatcher;
    fn get_erc721_core_enumerable_dispatcher(
        self: @TContractState
    ) -> IERC721CoreEnumerableDispatcher;
}


#[derive(Copy, Drop, Serde, starknet::Event)]
struct Approval {
    owner: ContractAddress,
    approved: ContractAddress,
    token_id: u256
}

#[derive(Copy, Drop, Serde, starknet::Event)]
struct ApprovalForAll {
    owner: ContractAddress,
    operator: ContractAddress,
    approved: bool
}

#[derive(Copy, Drop, Serde, starknet::Event)]
struct Transfer {
    from: ContractAddress,
    to: ContractAddress,
    token_id: u256
}

#[event]
#[derive(Copy, Drop, Serde, starknet::Event)]
enum ERC721Event {
    Approval: Approval,
    ApprovalForAll: ApprovalForAll,
    Transfer: Transfer,
}


#[generate_trait]
impl ERC721CoreInternalImpl<
    TContractState,
    +IWorldProvider<TContractState>,
    +Drop<TContractState>,
    +GetERC721CoreDispatcherTrait<TContractState>,
    +EventEmitter<TContractState, ERC721Event>,
> of ERC721CoreInternalTrait<TContractState> {
    fn get_balance(self: @TContractState, account: ContractAddress) -> u128 {
        self.world().get_balance(get_contract_address(), account)
    }

    fn get_owner(self: @TContractState, token_id: u256) -> ContractAddress {
        self.world().get_owner(get_contract_address(), token_id)
    }

    fn get_approval(self: @TContractState, token_id: u256) -> ContractAddress {
        self.world().get_approval(get_contract_address(), token_id)
    }

    fn set_approval(ref self: TContractState, token_id: u256, address: ContractAddress) {
        self.get_erc721_core_dispatcher().set_approval(token_id, address)
    }
    fn get_approval_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool {
        self.world().get_approval_for_all(get_contract_address(), owner, operator)
    }

    fn set_approval_for_all(
        ref self: TContractState, owner: ContractAddress, operator: ContractAddress, approved: bool
    ) {
        self.get_erc721_core_dispatcher().set_approval_for_all(owner, operator, approved)
    }

    fn is_operator(self: @TContractState, owner: ContractAddress, caller: ContractAddress) -> bool {
        caller == owner || self.get_approval_for_all(owner, caller)
    }

    fn emit_approval_event(
        ref self: TContractState, owner: ContractAddress, approved: ContractAddress, token_id: u256
    ) {
        let event = Approval { owner, approved, token_id };
        self.emit(event.clone());
        emit!(self.world(), (ERC721Event::Approval(event)));
    }
    fn emit_approval_for_all_event(
        ref self: TContractState, owner: ContractAddress, operator: ContractAddress, approved: bool
    ) {
        let event = ApprovalForAll { owner, operator, approved };
        self.emit(event.clone());
        emit!(self.world(), (ERC721Event::ApprovalForAll(event)));
    }
    fn emit_transfer_event(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    ) {
        let event = Transfer { from, to, token_id };
        self.emit(event.clone());
        emit!(self.world(), (ERC721Event::Transfer(event)));
    }
}

#[generate_trait]
impl ERC721BasicInternalImpl<
    TContractState,
    +IWorldProvider<TContractState>,
    +Drop<TContractState>,
    +GetERC721CoreDispatcherTrait<TContractState>,
    +EventEmitter<TContractState, ERC721Event>,
> of ERC721BasicInternalTrait<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, token_id: u256) {
        self.get_erc721_core_basic_dispatcher().mint(recipient, token_id)
    }
    fn burn(ref self: TContractState, token_id: u256) {
        self.get_erc721_core_basic_dispatcher().burn(token_id)
    }

    fn transfer(ref self: TContractState, token_id: u256, recipient: ContractAddress) {
        self.get_erc721_core_basic_dispatcher().transfer(token_id, recipient)
    }
}

#[generate_trait]
impl ERC721EnumerableInternalImpl<
    TContractState,
    +IWorldProvider<TContractState>,
    +Drop<TContractState>,
    +GetERC721CoreDispatcherTrait<TContractState>,
    +EventEmitter<TContractState, ERC721Event>,
> of ERC721EnumerableInternalTrait<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, token_id: u256) {
        self.get_erc721_core_enumerable_dispatcher().mint_enumerable(recipient, token_id)
    }
    fn burn(ref self: TContractState, token_id: u256) {
        self.get_erc721_core_enumerable_dispatcher().burn_enumerable(token_id)
    }
    fn get_total_supply(self: @TContractState) -> u128 {
        self.get_erc721_core_enumerable_dispatcher().get_total_supply()
    }
    fn transfer(ref self: TContractState, token_id: u256, recipient: ContractAddress) {
        self.get_erc721_core_enumerable_dispatcher().transfer_enumerable(token_id, recipient)
    }
    fn get_id_by_index(self: @TContractState, index: u128) -> u256 {
        self.get_erc721_core_enumerable_dispatcher().get_id_by_index(index)
    }
    fn get_id_from_owner_index(self: @TContractState, owner: ContractAddress, index: u128) -> u256 {
        self.get_erc721_core_enumerable_dispatcher().get_id_from_owner_index(owner, index)
    }
}

