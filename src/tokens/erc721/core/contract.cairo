#[dojo::contract]
mod erc20_core {
    use zeroable::Zeroable;
    use dojo::model::Model;
    use starknet::{ContractAddress, get_caller_address};
    use super::super::{models::{ERC721Read, ERC721Write,}, interface::{IERC721Core, IERC721CoreBasic, IERC721CoreEnumerable}};

    mod Errors {
        const CALLER_IS_NOT_OWNER: felt252 = 'ERC721: caller is not owner';
        const TRANSFER_FROM_ZERO: felt252 = 'ERC721: transfer from 0';
        const TRANSFER_TO_ZERO: felt252 = 'ERC721: transfer to 0';
        const APPROVE_FROM_ZERO: felt252 = 'ERC721: approve from 0';
        const APPROVE_TO_ZERO: felt252 = 'ERC721: approve to 0';
        const INVALID_TOKEN_ID: felt252 = 'ERC721: invalid token ID';
        const INVALID_ACCOUNT: felt252 = 'ERC721: invalid account';
        const UNAUTHORIZED: felt252 = 'ERC721: unauthorized caller';
        const APPROVAL_TO_OWNER: felt252 = 'ERC721: approval to owner';
        const SELF_APPROVAL: felt252 = 'ERC721: self approval';
        const INVALID_RECEIVER: felt252 = 'ERC721: invalid receiver';
        const ALREADY_MINTED: felt252 = 'ERC721: token already minted';
        const NOT_MINTED: felt252 = 'ERC721: token not minted';
        const WRONG_SENDER: felt252 = 'ERC721: wrong sender';
        const SAFE_MINT_FAILED: felt252 = 'ERC721: safe mint failed';
        const SAFE_TRANSFER_FAILED: felt252 = 'ERC721: safe transfer failed';
        const INSUFFICIENT_TOTAL_SUPPLY: felt252 = 'ERC721: insufficient supply';
        const INSUFFICIENT_BALANCE: felt252 = 'ERC721: insufficient balance';
    }


    #[abi(embed_v0)]
    impl ERC721CoreImpl of IERC721Core<ContractState> {
        

        fn get_balance(self: @ContractState, account: ContractAddress) -> u128 {
            self.get_balance_value(account)
        }

        fn get_owner(self: @ContractState, token_id: u256) -> ContractAddress {
            self.get_owner_value(token_id)
        }

        fn get_approval(self: @ContractState, token_id: u256) -> ContractAddress {
            self.get_approval_value(token_id)
        }

        fn set_approval(ref self: ContractState, token_id: u256, address: ContractAddress) {
            let owner = self.get_owner_value(token_id);
            assert(owner != address, Errors::SELF_APPROVAL);
            self.set_approval_value(token_id, address);
        }
        fn get_approval_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.get_approval_for_all_value(owner, operator) || owner == operator
        }
        fn set_approval_for_all(
            ref self: ContractState,
            owner: ContractAddress,
            operator: ContractAddress,
            approved: bool
        ) {
            assert(owner.is_non_zero(), Errors::APPROVE_FROM_ZERO);
            assert(operator.is_non_zero(), Errors::APPROVE_TO_ZERO);
            assert(owner != operator, Errors::SELF_APPROVAL);
            self.set_approval_for_all_value(owner, operator, approved);
        }
    }

    #[abi(embed_v0)]
    impl IERC721CoreBasicImpl of IERC721CoreBasic<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, token_id: u256) {
            self.mint_token(recipient, token_id);
        }

        fn burn(ref self: ContractState, token_id: u256) {
            self.burn_token(token_id);
        }

        fn transfer(ref self: ContractState, token_id: u256, recipient: ContractAddress) {
            let sender = self.get_owner_value(token_id);
            self.transfer_token(token_id, sender, recipient);
        }
    }


    #[abi(embed_v0)]
    impl IERC721CoreEnumerableImpl of IERC721CoreEnumerable<ContractState> {
        fn get_total_supply(self: @ContractState) -> u128 {
            self.get_total_supply_value()
        }

        fn get_id_by_index(self: @ContractState, index: u128) -> u256 {
            self.get_id_from_index_value(index)
        }

        fn get_id_from_owner_index(self: @ContractState, owner:ContractAddress, index: u128)->u256 {
            self.get_id_from_owner_index_value(owner, index)
        }

        fn mint_enumerable(ref self: ContractState, recipient: ContractAddress, token_id: u256) {
            self.add_token_index(token_id);
            self.add_token_to_owner(token_id, recipient);
            self.mint_token(recipient, token_id);
            self.increase_total_supply_value(1);
            
        }

        fn burn_enumerable(ref self: ContractState, token_id: u256) {
            let owner = self.get_owner_value(token_id);
            self.remove_token_index(token_id);
            self.remove_token_from_owner(token_id, owner);
            self.burn_token(token_id);
            self.decrease_total_supply_value(1);

        }

        fn transfer_enumerable(
            ref self: ContractState, token_id: u256, recipient: ContractAddress
        ) {
            let sender = self.get_owner_value(token_id);
            self.remove_token_from_owner(token_id, sender);
            self.add_token_to_owner(token_id, recipient);
            self.transfer_token(token_id, sender, recipient);
        }
    }


    #[generate_trait]
    impl ERC721ModelImpl of ERC721ModelTrait {
        fn mint_token(ref self: ContractState, recipient: ContractAddress, token_id: u256) {
            assert(self.get_owner_value(token_id).is_zero(), Errors::ALREADY_MINTED);
            assert(recipient.is_non_zero(), Errors::INVALID_RECEIVER);
            self.set_owner_value(token_id, recipient);
            self.increase_balance_value(recipient, 1);
        }
        fn burn_token(ref self: ContractState, token_id: u256) {
            let owner = self.get_owner_value(token_id);
            assert(owner.is_non_zero(), Errors::NOT_MINTED);
            self.set_owner_value(token_id, Zeroable::zero());
            self.set_approval_value(token_id, Zeroable::zero());
            self.decrease_balance_value(owner, 1);
        }
        fn get_total_supply_value(self: @ContractState) -> u128 {
            self.world().get_total_supply(get_caller_address())
        }

        fn set_total_supply_value(ref self: ContractState, total_supply: u128) {
            self.world().set_total_supply(get_caller_address(), total_supply);
        }

        fn increase_total_supply_value(ref self: ContractState, amount: u128) {
            let total_supply = self.get_total_supply_value();
            self.set_total_supply_value(total_supply + amount);
        }
        fn decrease_total_supply_value(ref self: ContractState, amount: u128) {
            let total_supply = self.get_total_supply_value();
            assert(total_supply >= amount, Errors::INSUFFICIENT_TOTAL_SUPPLY);
            self.set_total_supply_value(total_supply - amount);
        }

        fn get_balance_value(self: @ContractState, account: ContractAddress) -> u128 {
            self.world().get_balance(get_caller_address(), account)
        }

        fn set_balance_value(ref self: ContractState, account: ContractAddress, amount: u128) {
            self.world().set_balance(get_caller_address(), account, amount)
        }

        fn increase_balance_value(ref self: ContractState, account: ContractAddress, amount: u128) {
            let balance = self.get_balance_value(account);
            self.set_balance_value(account, balance + amount);
        }
        fn decrease_balance_value(ref self: ContractState, account: ContractAddress, amount: u128) {
            let balance = self.get_balance_value(account);
            assert(balance >= amount, Errors::INSUFFICIENT_BALANCE);
            self.set_balance_value(account, balance - amount);
        }

        fn get_owner_value(self: @ContractState, token_id: u256) -> ContractAddress {
            self.world().get_owner(get_caller_address(), token_id)
        }

        fn set_owner_value(ref self: ContractState, token_id: u256, owner: ContractAddress) {
            self.world().set_owner(get_caller_address(), token_id, owner)
        }

        fn get_approval_value(self: @ContractState, token_id: u256) -> ContractAddress {
            self.world().get_approval(get_caller_address(), token_id)
        }

        fn set_approval_value(ref self: ContractState, token_id: u256, address: ContractAddress) {
            self.world().set_approval(get_caller_address(), token_id, address)
        }

        fn get_approval_for_all_value(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.world().get_approval_for_all(get_caller_address(), owner, operator)
        }

        fn set_approval_for_all_value(
            ref self: ContractState,
            owner: ContractAddress,
            operator: ContractAddress,
            approved: bool
        ) {
            self.world().set_approval_for_all(get_caller_address(), owner, operator, approved)
        }

        fn transfer_token(
            ref self: ContractState,
            token_id: u256,
            sender: ContractAddress,
            recipient: ContractAddress
        ) {
            assert(sender.is_non_zero(), Errors::NOT_MINTED);
            assert(recipient.is_non_zero() && recipient != sender, Errors::INVALID_RECEIVER);

            self.set_owner_value(token_id, recipient);
            self.decrease_balance_value(sender, 1);
            self.increase_balance_value(recipient, 1);
            self.set_approval_value(token_id, Zeroable::zero());
        }

        fn get_id_from_index_value(self: @ContractState, index: u128) -> u256 {
            self.world().get_id_from_index(get_caller_address(), index)
        }

        fn set_id_from_index_value(ref self: ContractState, index: u128, token_id: u256) {
            self.world().set_id_from_index(get_caller_address(), index, token_id)
        }

        fn get_index_from_id_value(self: @ContractState, token_id: u256) -> u128 {
            self.world().get_index_from_id(get_caller_address(), token_id)
        }

        fn set_index_from_id_value(ref self: ContractState, token_id: u256, index: u128) {
            self.world().set_index_from_id(get_caller_address(), token_id, index)
        }

        fn get_id_from_owner_index_value(
            self: @ContractState, owner: ContractAddress, index: u128
        ) -> u256 {
            self.world().get_id_from_owner_index(get_caller_address(), owner, index)
        }

        fn set_id_from_owner_index_value(
            ref self: ContractState, owner: ContractAddress, index: u128, token_id: u256
        ) {
            self.world().set_id_from_owner_index(get_caller_address(), owner, index, token_id)
        }

        fn get_owner_index_from_id_value(
            self: @ContractState, owner: ContractAddress, token_id: u256
        ) -> u128 {
            self.world().get_owner_index_from_id(get_caller_address(), owner, token_id)
        }

        fn set_owner_index_from_id_value(
            ref self: ContractState, token_id: u256, owner: ContractAddress, index: u128
        ) {
            self.world().set_owner_index_from_id(get_caller_address(), owner, token_id, index);
        }


        fn set_id_and_index(ref self: ContractState, token_id: u256, index: u128) {
            self.set_id_from_index_value(index, token_id);
            self.set_index_from_id_value(token_id, index);
        }
        fn set_owner_id_and_index(
            ref self: ContractState, owner: ContractAddress, token_id: u256, index: u128
        ) {
            self.set_id_from_owner_index_value(owner, index, token_id);
            self.set_owner_index_from_id_value(token_id, owner, index);
        }

        fn add_token_index(ref self: ContractState, token_id: u256) {
            let total_supply = self.get_total_supply_value();
            self.set_id_and_index(token_id, total_supply);
        }
        fn remove_token_index(ref self: ContractState, token_id: u256) {
            let index = self.get_index_from_id_value(token_id);
            let last_index = self.get_total_supply_value() - 1;
            let last_token_id = self.get_id_from_index_value(last_index);
            self.set_id_and_index(last_token_id, index);
            self.set_id_from_index_value(last_index, 0);
        }
        fn add_token_to_owner(ref self: ContractState, token_id: u256, owner: ContractAddress) {
            let balance = self.get_balance_value(owner);
            self.set_owner_id_and_index(owner, token_id, balance);
        }
        fn remove_token_from_owner(
            ref self: ContractState, token_id: u256, owner: ContractAddress
        ) {
            let index = self.get_owner_index_from_id_value(owner, token_id);
            let last_index = self.get_balance_value(owner) - 1;
            let last_token_id = self.get_id_from_owner_index_value(owner, last_index);
            self.set_owner_id_and_index(owner, last_token_id, index);
            self.set_id_from_owner_index_value(owner, last_index, 0);
        }
    }
}
