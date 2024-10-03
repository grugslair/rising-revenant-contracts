use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use super::models::{
    JackpotTotal, JackpotClaimed, JackpotSplit, JackpotTotalStore, JackpotClaimedStore,
    JackpotSplitStore, Claimant, Claimed, ClaimedStore
};
use rising_revenant::contribution::ContributionTrait;


#[generate_trait]
impl JackpotImpl of JackpotTrait {
    fn get_jackpot_total(self: @IWorldDispatcher, game_id: felt252) -> u256 {
        JackpotTotalStore::get_total(*self, game_id)
    }
    fn get_jackpot_claimed(self: @IWorldDispatcher, game_id: felt252) -> JackpotClaimed {
        JackpotClaimedStore::get(*self, game_id)
    }
    fn get_jackpot_left(self: @IWorldDispatcher, game_id: felt252) -> u256 {
        self.get_jackpot_total(game_id) - self.get_jackpot_claimed(game_id).amount
    }
    fn increase_jackpot_total(self: IWorldDispatcher, game_id: felt252, value: u256) {
        let mut model = JackpotTotalStore::get(self, game_id);
        model.total += value;
        model.set(self);
    }
    fn get_dev_permille(self: @IWorldDispatcher, game_id: felt252) -> u16 {
        JackpotSplitStore::get_dev_permille(*self, game_id)
    }
    fn get_contribution_permille(self: @IWorldDispatcher, game_id: felt252) -> u16 {
        JackpotSplitStore::get_contribution_permille(*self, game_id)
    }
    fn get_win_permille(self: @IWorldDispatcher, game_id: felt252) -> u16 {
        1000 - self.get_dev_permille(game_id) - self.get_contribution_permille(game_id)
    }
    fn get_jackpot_fraction(self: @IWorldDispatcher, game_id: felt252, permille: u16) -> u256 {
        self.get_jackpot_total(game_id).into() * 1000 / permille.into()
    }
    fn get_dev_amount(self: @IWorldDispatcher, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_dev_permille(game_id))
    }
    fn get_contribution_amount(
        self: @IWorldDispatcher, game_id: felt252, user: ContractAddress
    ) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
            * self.get_contribution_score(game_id, user).into()
            / self.get_total_contribution_score(game_id).into()
    }
    fn get_win_amount(self: @IWorldDispatcher, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_win_permille(game_id))
    }
    fn get_claimant(self: @IWorldDispatcher, game_id: felt252, claimant: Claimant) -> Claimed {
        ClaimedStore::get(*self, game_id, claimant)
    }
    fn get_claimed(self: @IWorldDispatcher, game_id: felt252, claimant: Claimant) -> bool {
        self.get_claimant(game_id, claimant).claimed
    }
    fn make_claim(self: IWorldDispatcher, game_id: felt252, claimant: Claimant) {
        let mut claimed = self.get_claimant(game_id, claimant);
        assert(!claimed.claimed, 'Already claimed');
        claimed.claimed = true;
        claimed.set(self);
    }
    fn set_amount_claimed(self: IWorldDispatcher, game_id: felt252, amount: u256) {
        let total = self.get_jackpot_total(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        assert(claimed.amount + amount <= total, 'Incifiicent funds');
        claimed.amount += amount;
        claimed.set(self);
    }

    fn get_claim_amount(self: @IWorldDispatcher, game_id: felt252, claimant: Claimant) -> u256 {
        match claimant {
            Claimant::Dev => self.get_dev_amount(game_id),
            Claimant::Winner => self.get_win_amount(game_id),
            Claimant::Contributor(user) => self.get_contribution_amount(game_id, user),
        }
    }

    fn claim_amount(self: IWorldDispatcher, game_id: felt252, claimant: Claimant) -> u256 {
        let amount = self.get_claim_amount(game_id, claimant);
        assert(amount > 0, 'No amount to claim');
        self.make_claim(game_id, claimant);
        self.set_amount_claimed(game_id, amount);
        amount
    }

    fn claim_remainder(self: IWorldDispatcher, game_id: felt252) -> u256 {
        let total = self.get_jackpot_total(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        let remainder = total - claimed.amount;
        claimed.amount = total;
        claimed.set(self);
        remainder
    }
}
