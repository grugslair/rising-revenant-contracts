use starknet::{
    ContractAddress, get_caller_address, get_contract_address, ClassHash, SyscallResultTrait,
    syscalls::deploy_syscall,
};
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::{world::{WorldStorage, WorldStorageTrait}, model::{ModelStorage, Model}};

use rising_revenant::{
    game_pot::{GamePotStorage, models::{TransferTo, get_permille}}, contribution::Contribution,
    game::{GameStorage, GameTrait, ClassHashVariant},
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
        erc20_transfer(self.get_game_token_address(game_id), recipient, amount);
    }

    fn pay_into_purchases_pot(
        ref self: WorldStorage, game_id: felt252, from: ContractAddress, amount: u256,
    ) {
        self.increase_purchases_amount(game_id, amount).transfer_from(from, amount);
    }

    fn deploy_game_pot_contract(
        ref self: WorldStorage,
        game_id: felt252,
        owner: ContractAddress,
        token_address: ContractAddress,
    ) -> ContractAddress {
        let calldata = [
            self.dispatcher.contract_address.into(), self.namespace_hash, game_id, owner.into(),
            token_address.into(),
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
                self.deploy_game_pot_contract(game_id, owner, token_address),
                token_address,
            );
    }
}
