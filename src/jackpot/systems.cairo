use starknet::{ContractAddress, get_caller_address};
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::{world::{WorldStorage, WorldStorageTrait}, model::{ModelStorage, Model}};
use rising_revenant::{
    jackpot::JackpotStorage, contribution::Contribution, game::{GameStorage, GameTrait, GameWallet},
    tokens::{erc20_transfer, erc20_transfer_from, erc20_balance_of}
};

/// The JackpotTrait provides a comprehensive system for managing game jackpots.
/// It handles:
/// * Tracking total and claimed jackpot amounts
/// * Managing distribution shares between developers, winners, and contributors
/// * Processing claims and verifying claim eligibility
/// * Calculating various jackpot fractions and amounts
///
/// The system uses permille (parts per thousand) for precise share calculations,
/// allowing for flexible distribution ratios between different stakeholders.
#[generate_trait]
impl JackpotImpl of JackpotTrait {
    fn payout(ref self: WorldStorage, game_id: felt252, recipient: ContractAddress, amount: u256) {
        erc20_transfer(self.get_game_erc20_token(game_id), recipient, amount);
    }

    fn pay_into_jackpot(
        ref self: WorldStorage, game_id: felt252, from: ContractAddress, amount: u256
    ) {
        let GameWallet { erc20_address, wallet_address } = self.get_game_wallet(game_id);
        erc20_transfer_from(erc20_address, from, wallet_address, amount);
    }

    /// Calculates a fraction of the jackpot based on permille value.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `permille` - The fraction in permille to calculate
    /// # Returns
    /// * `u256` - The calculated fraction of the jackpot
    fn get_jackpot_fraction(self: @WorldStorage, game_id: felt252, permille: u16) -> u256 {
        self.get_jackpot_total(game_id) * 1000 / permille.into()
    }

    fn get_contribution_jackpot_fraction(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
    }

    /// Calculates a specific user's contribution share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `user` - The address of the contributor
    /// # Returns
    /// * `u256` - The amount allocated to the contributor
    fn get_contributor_payout(
        self: @WorldStorage, game_id: felt252, user: ContractAddress
    ) -> u256 {
        self.get_contribution_jackpot_fraction(game_id)
            * self.get_contribution_amount(game_id, user).into()
            / self.get_total_contribution_amount(game_id).into()
    }

    /// Calculates the winner's share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount allocated to the winner
    fn get_winner_payout(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_winner_permille(game_id))
    }

    fn claim_winning_payout(ref self: WorldStorage, game_id: felt252) {
        self.assert_game_claiming(game_id);
        let winner = self.get_owner_of_winning_outpost(game_id);
        assert(winner == get_caller_address(), 'Not owner of winning outpost');
        let amount = self.get_winner_payout(game_id);
        self.payout(game_id, winner, amount);
        self.set_jackpot_winner_claimed(game_id);
    }

    fn claim_contributor_payout(ref self: WorldStorage, game_id: felt252, user: ContractAddress) {
        self.assert_game_claiming(game_id);
        let amount = self.get_contributor_payout(game_id, user);
        self.payout(game_id, user, amount);
        self.set_jackpot_contributor_claimed(game_id, user);
    }

    fn get_jackpot_current_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        let GameWallet { erc20_address, wallet_address } = self.get_game_wallet(game_id);
        erc20_balance_of(erc20_address, wallet_address)
    }

    fn get_self_current_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        erc20_balance_of(self.get_game_erc20_token(game_id), get_caller_address())
    }

    fn finalise_jackpot_total(ref self: WorldStorage, game_id: felt252) {
        self.set_jackpot_total(game_id, self.get_jackpot_current_amount(game_id));
    }
}
