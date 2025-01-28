use starknet::{
    ContractAddress, get_caller_address, get_contract_address, ClassHash, SyscallResultTrait,
    syscalls::deploy_syscall,
};
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::{world::{WorldStorage, WorldStorageTrait}, model::{ModelStorage, Model}};

use rising_revenant::{
    game_pot::{
        GamePotStorage, models::{TransferTo, get_permille, WinnersAmountPay, ContributorsAmountPay},
    },
    contribution::Contribution, game::{GameStorage, GameTrait, GameWallet, ClassHashVariant},
    tokens::{erc20_transfer, erc20_transfer_from, erc20_balance_of}, utils::deploy_contract,
};

#[generate_trait]
impl TransferToImpl of TransferToTrait {
    fn transfer_from(self: TransferTo, sender: ContractAddress, amount: u256) {
        erc20_transfer_from(self.token_address, sender, self.recipient, amount);
    }
}

/// The GamePotTrait provides a comprehensive system for managing game game_pots.
/// It handles:
/// * Tracking total and claimed game_pot amounts
/// * Managing distribution shares between developers, winners, and contributors
/// * Processing claims and verifying claim eligibility
/// * Calculating various game_pot fractions and amounts
///
/// The system uses permille (parts per thousand) for precise share calculations,
/// allowing for flexible distribution ratios between different stakeholders.
#[generate_trait]
impl GamePotImpl of GamePotTrait {
    fn payout(ref self: WorldStorage, game_id: felt252, recipient: ContractAddress, amount: u256) {
        erc20_transfer(self.get_game_erc20_token(game_id), recipient, amount);
    }

    fn pay_into_purchases_pot(
        ref self: WorldStorage, game_id: felt252, from: ContractAddress, amount: u256,
    ) {
        self.increase_purchases_amount(game_id, amount).transfer_from(from, amount);
    }

    fn pay_into_contributors_pot(
        ref self: WorldStorage, game_id: felt252, from: ContractAddress, amount: u256,
    ) {
        erc20_transfer_from(
            self.increase_contributors_amount(game_id, amount),
            from,
            get_contract_address(),
            amount,
        );
    }

    fn pay_into_winners_pot(
        ref self: WorldStorage, game_id: felt252, from: ContractAddress, amount: u256,
    ) {
        erc20_transfer_from(
            self.increase_winners_amount(game_id, amount), from, get_contract_address(), amount,
        );
    }

    fn payout_winners_pot(ref self: WorldStorage, game_id: felt252, caller: ContractAddress) {
        let WinnersAmountPay {
            purchases, winners, winner_purchases_permille, token_address,
        } = self.get_winners_payout(game_id);
        let amount = winners + get_permille(purchases, winner_purchases_permille);
        self.set_game_pot_winner_claimed(game_id);
        erc20_transfer(token_address, caller, amount);
    }

    fn payout_contributors_pot(ref self: WorldStorage, game_id: felt252, caller: ContractAddress) {
        let ContributorsAmountPay {
            purchases, contributors, contribution_purchases_permille, token_address,
        } = self.get_contributors_payout(game_id);
        let amount = self
            .get_contribution_portion(
                game_id,
                caller,
                contributors + get_permille(purchases, contribution_purchases_permille),
            );
        self.set_game_pot_contributor_claimed(game_id, caller);
        erc20_transfer(token_address, caller, amount);
    }

    fn deploy_game_pot_contract(
        ref self: WorldStorage, game_id: felt252, owner: ContractAddress,
    ) -> ContractAddress {
        let calldata = [
            self.dispatcher.contract_address.into(), self.namespace_hash, game_id, owner.into(),
        ]
            .span();
        deploy_contract(self.get_class_hash(ClassHashVariant::GamePot), calldata, game_id)
    }

    fn setup_game_pot(
        ref self: WorldStorage,
        game_id: felt252,
        owner: ContractAddress,
        winner_purchases_permille: u16,
        contribution_purchases_permille: u16,
        token_address: ContractAddress,
    ) {
        self
            .create_game_pot(
                game_id,
                winner_purchases_permille,
                contribution_purchases_permille,
                self.deploy_game_pot_contract(game_id, owner),
                token_address,
            );
    }
}
