use starknet::{ContractAddress, get_caller_address};
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::{world::{WorldStorage, WorldStorageTrait}, model::{ModelStorage, Model}};
use super::models::{JackpotTotal, JackpotClaimed, JackpotSplit, Claimant, Claimed, JackpotStorage};
use rising_revenant::{
    contribution::Contribution, game::GameStorage,
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
        let jackpot_address = match self.dns(@"jackpot_actions") {
            Option::Some((address, _)) => address,
            Option::None => panic!("Jackpot contract not deployed"),
        };
        let contract_address = self.get_game_erc20_token(game_id);
        ERC20ABIDispatcher { contract_address }.transfer_from(from, jackpot_address, amount);
        self.increase_jackpot_total(game_id, amount);
    }

    /// Increases the total jackpot amount by a specified value.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `value` - The amount to add to the jackpot
    fn increase_jackpot_total(ref self: WorldStorage, game_id: felt252, value: u256) {
        self.set_jackpot_total_amount(game_id, self.get_jackpot_total_amount(game_id) + value);
    }

    /// Calculates a fraction of the jackpot based on permille value.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `permille` - The fraction in permille to calculate
    /// # Returns
    /// * `u256` - The calculated fraction of the jackpot
    fn get_jackpot_fraction(self: @WorldStorage, game_id: felt252, permille: u16) -> u256 {
        self.get_jackpot_total_amount(game_id).into() * 1000 / permille.into()
    }

    /// Calculates the developer's share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount allocated to developers
    fn get_dev_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_dev_permille(game_id))
    }

    /// Calculates a specific user's contribution share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `user` - The address of the contributor
    /// # Returns
    /// * `u256` - The amount allocated to the contributor
    fn get_contribution_amount(
        self: @WorldStorage, game_id: felt252, user: ContractAddress
    ) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
            * self.get_contribution_amount(game_id, user).into()
            / self.get_total_contribution_amount(game_id).into()
    }

    /// Calculates the winner's share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount allocated to the winner
    fn get_win_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_win_permille(game_id))
    }

    /// Marks a claim as processed for a specific claimant.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `claimant` - The type of claimant (Dev, Winner, or Contributor)
    /// # Panics
    /// * If the claim was already made
    fn make_claim(ref self: WorldStorage, game_id: felt252, claimant: Claimant) {
        let mut claimed = self.get_claimant(game_id, claimant);
        assert(!claimed.claimed, 'Already claimed');
        claimed.claimed = true;
        self.set_claimant(claimed);
    }

    /// Updates the total claimed amount for a game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `amount` - The amount being claimed
    /// # Panics
    /// * If there are insufficient funds available
    fn set_amount_claimed(ref self: WorldStorage, game_id: felt252, amount: u256) {
        let total = self.get_jackpot_total_amount(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        assert(claimed.amount + amount <= total, 'Insufficient funds');
        claimed.amount += amount;
        self.set_jackpot_claimed(claimed);
    }

    /// Calculates the claimable amount for a specific claimant type.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `claimant` - The type of claimant (Dev, Winner, or Contributor)
    /// # Returns
    /// * `u256` - The amount that can be claimed
    fn get_claim_amount(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> u256 {
        match claimant {
            Claimant::Dev => self.get_dev_amount(game_id),
            Claimant::Winner => self.get_win_amount(game_id),
            Claimant::Contributor(user) => self.get_contribution_amount(game_id, user),
        }
    }

    /// Processes a claim and returns the claimed amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `claimant` - The type of claimant (Dev, Winner, or Contributor)
    /// # Returns
    /// * `u256` - The amount claimed
    /// # Panics
    /// * If there is no amount to claim
    fn claim_amount(ref self: WorldStorage, game_id: felt252, claimant: Claimant) -> u256 {
        let amount = self.get_claim_amount(game_id, claimant);
        assert(amount > 0, 'No amount to claim');
        self.make_claim(game_id, claimant);
        self.set_amount_claimed(game_id, amount);
        amount
    }

    /// Claims any remaining unclaimed amount in the jackpot.
    /// This function can be used to collect any dust or remaining amounts
    /// after all primary claims have been processed.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount claimed from the remainder
    fn claim_remainder(ref self: WorldStorage, game_id: felt252) -> u256 {
        let total = self.get_jackpot_total_amount(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        let remainder = total - claimed.amount;
        claimed.amount = total;
        self.set_jackpot_claimed(claimed);
        remainder
    }
}
