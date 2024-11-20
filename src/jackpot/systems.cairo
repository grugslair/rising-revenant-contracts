use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use super::models::{JackpotTotal, JackpotClaimed, JackpotSplit, Claimant, Claimed};
use rising_revenant::contribution::ContributionTrait;

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
    /// Returns the total jackpot model for a specific game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `JackpotTotal` - The total jackpot model containing all jackpot information
    fn get_jackpot_total_model(self: @WorldStorage, game_id: felt252) -> JackpotTotal {
        self.read_model(game_id)
    }

    /// Returns the total amount in the jackpot for a specific game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The total jackpot amount
    fn get_jackpot_total_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<JackpotTotal>::ptr_from_keys(game_id), selector!("total"))
    }

    /// Returns the claimed jackpot model for a specific game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `JackpotClaimed` - The claimed jackpot model
    fn get_jackpot_claimed(self: @WorldStorage, game_id: felt252) -> JackpotClaimed {
        self.read_model(game_id)
    }

    /// Calculates the remaining unclaimed amount in the jackpot.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount remaining to be claimed
    fn get_jackpot_left(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_total_amount(game_id) - self.get_jackpot_claimed(game_id).amount
    }

    /// Increases the total jackpot amount by a specified value.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `value` - The amount to add to the jackpot
    fn increase_jackpot_total(ref self: WorldStorage, game_id: felt252, value: u256) {
        let mut model = self.get_jackpot_total_model(game_id);
        model.total += value;
        self.write_model(@model);
    }

    /// Returns the developer's share in permille (parts per thousand).
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The developer's share in permille
    fn get_dev_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self.read_member(Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("dev_permille"))
    }

    /// Returns the contribution share in permille.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The contribution share in permille
    fn get_contribution_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self.read_member(Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("contribution_permille"))
    }

    /// Calculates the winner's share in permille (1000 - dev - contribution).
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The winner's share in permille
    fn get_win_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        1000 - self.get_dev_permille(game_id) - self.get_contribution_permille(game_id)
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
    fn get_contribution_amount(self: @WorldStorage, game_id: felt252, user: ContractAddress) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
            * self.get_contribution_score(game_id, user).into()
            / self.get_total_contribution_score(game_id).into()
    }

    /// Calculates the winner's share amount.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount allocated to the winner
    fn get_win_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_win_permille(game_id))
    }

    /// Returns the claim status for a specific claimant.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `claimant` - The type of claimant (Dev, Winner, or Contributor)
    /// # Returns
    /// * `Claimed` - The claim status model
    fn get_claimant(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> Claimed {
        self.read_model((game_id, claimant))
    }

    /// Checks if a specific claimant has already claimed their share.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// * `claimant` - The type of claimant (Dev, Winner, or Contributor)
    /// # Returns
    /// * `bool` - True if already claimed, false otherwise
    fn get_claimed(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> bool {
        self.read_member(Model::<Claimed>::ptr_from_keys((game_id, claimant)), selector!("claimed"))
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
        self.write_model(@claimed);
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
        self.write_model(@claimed);
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
        self.write_model(@claimed);
        remainder
    }
}
