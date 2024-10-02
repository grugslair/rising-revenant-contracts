use super::models::{
    JackpotTotal, JackpotClaimed, JackpotSplit, JackpotTotalStore, JackpotClaimedStore,
    JackpotSplitStore
};
use rising_revenant::contributions::ContributionTrait;


#[generate_trait]
impl JackpotImpl of JackpotTrait {
    fn get_jackpot_total(self: @IWorldDispatcher, game_id: felt252) -> u128 {
        JackpotTotalStore::get_total(*self, game_id)
    }
    fn increase_jackpot_total(self: IWorldDispatcher, game_id: felt252, value: u128) {
        let mut model = JackpotTotalStore::get(self, game_id);
        model.total += value;
        model.set(self);
    }
    fn get_dev_permille(self: @IWorldDispatcher, game_id: felt252) -> u16 {
        JackpotSplitStore::get_dev_permille(self, game_id)
    }
    fn get_contribution_permille(self: @IWorldDispatcher, game_id: felt252) -> u16 {
        JackpotSplitStore::get_contribution_permille(self, game_id)
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
        self: @IWorldDispatcher, game_id: felt252, contribution: u128
    ) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
            * contribution
            / self.get_total_contribution(game_id)
    }
    fn get_win_amount(self: @IWorldDispatcher, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_win_permille(game_id))
    }
    fn claim_jackpot_amount(self: IWorldDispatcher, game_id: felt252, amount: u128) {
        let total = self.get_jackpot_total(game_id);
        let mut claimed = JackpotClaimedStore::get(self, game_id);
        assert(claimed.total + amount <= total, '');
        claimed.total += amount;
        claimed.set(self);
    }
}
