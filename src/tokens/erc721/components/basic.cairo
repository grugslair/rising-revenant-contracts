use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use super::super::{ERC721BasicInternalTrait, GetERC721CoreDispatcherTrait};

trait IERC721BurnTrait {
    fn burn(
        self: IWorldDispatcher, core: IERC721CoreDispatcher, account: ContractAddress, amount: u256
    ) -> bool;
}

trait IERC721MetadataTrait {
    fn name() -> ByteArray;
    fn symbol() -> felt252;
    fn token_uri(token_id: u256) -> ByteArray;
}

#[starknet::interface]
trait IERC721Mint<TState> {
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait IERC721Core<TState> {
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);


    fn ownerOf(self: @TState, token_id: u256) -> ContractAddress;
    fn getApproved(self: @TState, token_id: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
}

#[starknet::interface]
trait IERC721Transfer<TState> {
    fn transfer(ref self: TState, recipient: ContractAddress);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: ByteArray
    );
    fn transferFrom(
        ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256
    ) -> bool;
    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: ByteArray
    );
}

#[starknet::interface]
trait IERC721Enumerable<TState> {
    fn total_supply(self: @TState) -> u256;
    fn token_by_index(self: @TState, index: u256) -> u256;
    fn token_of_owner_by_index(self: @TState, owner: ContractAddress, index: u256) -> u256;

    fn totalSupply(self: @TState) -> u256;
    fn tokenByIndex(self: @TState, index: u256) -> u256;
    fn tokenOfOwnerByIndex(self: @TState, owner: ContractAddress, index: u256) -> u256;
}


#[starknet::component]
pub mod ERC721_basic_component {
    use starknet::{ContractAddress, get_caller_address, get_contract_address, event::EventEmitter};
    use dojo::world::{
        IWorldProvider, IWorldProviderDispatcher, IWorldDispatcher, IWorldDispatcherTrait
    };

    use super::super::super::{ERC721CoreInternalTrait, ERC721Event, GetERC721CoreDispatcherTrait};
    use super::{IERC721Core, IERC721Transfer};


    #[storage]
    struct Storage {}

    #[embeddable_as(ERC721CoreImpl)]
    impl ERC721Core<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
        +Copy<TContractState>,
        +GetERC721CoreDispatcherTrait<TContractState>,
        +EventEmitter<TContractState, ERC721Event>,
    > of IERC721Core<ComponentState<TContractState>> {
        fn balance_of(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            self.get_contract().get_balance(account).into()
        }
        fn owner_of(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            self.get_contract().get_owner(token_id)
        }
        fn get_approved(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            self.get_contract().get_approval(token_id)
        }
        fn is_approved_for_all(
            self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.get_contract().get_approval_for_all(owner, operator)
        }
        fn approve(ref self: ComponentState<TContractState>, to: ContractAddress, token_id: u256) {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            let owner = contract.get_owner(token_id);
            assert(contract.is_operator(owner, caller), 'ERC721: caller is not operator');
            contract.set_approval(token_id, to);
            contract.emit_approval_event(caller, to, token_id);
        }
        fn set_approval_for_all(
            ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool
        ) {
            let caller = get_caller_address();
            assert(contract.is_operator(owner, caller), 'ERC721: caller is not operator');
            let mut contract = self.get_contract_mut();
            ERC721CoreInternalTrait::set_approval_for_all(ref contract, caller, operator, approved);
        }

        fn ownerOf(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            Self::owner_of(self, token_id)
        }
        fn getApproved(self: @ComponentState<TContractState>, token_id: u256) -> ContractAddress {
            Self::get_approved(self, token_id)
        }
        fn isApprovedForAll(
            self: @ComponentState<TContractState>, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            Self::is_approved_for_all(self, owner, operator)
        }
        fn balanceOf(self: @ComponentState<TContractState>, account: ContractAddress) -> u256 {
            Self::balance_of(self, account)
        }
        fn setApprovalForAll(
            ref self: ComponentState<TContractState>, operator: ContractAddress, approved: bool
        ) {
            Self::set_approval_for_all(ref self, operator, approved)
        }
    }

    #[embeddable_as(ERC721TransferImpl)]
    impl ERC721Transfer<
        TContractState,
        +HasComponent<TContractState>,
        +IWorldProvider<TContractState>,
        +Drop<TContractState>,
        +Copy<TContractState>,
        +GetERC721CoreDispatcherTrait<TContractState>,
        +EventEmitter<TContractState, ERC721Event>,
    > of IERC721Transfer<ComponentState<TContractState>> {
        fn transfer(ref self: ComponentState<TContractState>, recipient: ContractAddress) {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            let token_id = contract.get_balance(caller);
            contract.transfer_from(caller, recipient, token_id);
        }
        fn transfer_from(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256
        ) {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            contract.transfer_from(caller, from, to, token_id);
        }
        fn safe_transfer_from(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: ByteArray
        ) {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            contract.safe_transfer_from(caller, from, to, token_id, data);
        }
        fn transferFrom(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256
        ) -> bool {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            contract.transfer_from(caller, from, to, token_id);
            true
        }
        fn safeTransferFrom(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: ByteArray
        ) {
            let caller = get_caller_address();
            let mut contract = self.get_contract_mut();
            contract.safe_transfer_from(caller, from, to, token_id, data);
        }
    }
}
