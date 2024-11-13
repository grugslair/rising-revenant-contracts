use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use super::models::{JackpotTotal, JackpotClaimed, JackpotSplit, Claimant, Claimed};
use rising_revenant::contribution::ContributionTrait;


#[generate_trait]
impl JackpotImpl of JackpotTrait {
    fn get_jackpot_total_model(self: @WorldStorage, game_id: felt252) -> JackpotTotal {
        self.read_model(game_id)
    }
    fn get_jackpot_total_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<JackpotTotal>::ptr_from_keys(game_id), selector!("total"))
    }
    fn get_jackpot_claimed(self: @WorldStorage, game_id: felt252) -> JackpotClaimed {
        self.read_model(game_id)
    }
    fn get_jackpot_left(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_total_amount(game_id) - self.get_jackpot_claimed(game_id).amount
    }
    fn increase_jackpot_total(ref self: WorldStorage, game_id: felt252, value: u256) {
        let mut model = self.get_jackpot_total_model(game_id);
        model.total += value;
        self.write_model(@model);
    }
    fn get_dev_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self.read_member(Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("dev_permille"))
    }
    fn get_contribution_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self
            .read_member(
                Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("contribution_permille")
            )
    }
    fn get_win_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        1000 - self.get_dev_permille(game_id) - self.get_contribution_permille(game_id)
    }
    fn get_jackpot_fraction(self: @WorldStorage, game_id: felt252, permille: u16) -> u256 {
        self.get_jackpot_total_amount(game_id).into() * 1000 / permille.into()
    }
    fn get_dev_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_dev_permille(game_id))
    }
    fn get_contribution_amount(
        self: @WorldStorage, game_id: felt252, user: ContractAddress
    ) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_contribution_permille(game_id))
            * self.get_contribution_score(game_id, user).into()
            / self.get_total_contribution_score(game_id).into()
    }
    fn get_win_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_fraction(game_id, self.get_win_permille(game_id))
    }
    fn get_claimant(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> Claimed {
        self.read_model((game_id, claimant))
    }
    fn get_claimed(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> bool {
        self.read_member(Model::<Claimed>::ptr_from_keys((game_id, claimant)), selector!("claimed"))
    }
    fn make_claim(ref self: WorldStorage, game_id: felt252, claimant: Claimant) {
        let mut claimed = self.get_claimant(game_id, claimant);
        assert(!claimed.claimed, 'Already claimed');
        claimed.claimed = true;
        self.write_model(@claimed);
    }
    fn set_amount_claimed(ref self: WorldStorage, game_id: felt252, amount: u256) {
        let total = self.get_jackpot_total_amount(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        assert(claimed.amount + amount <= total, 'Incifiicent funds');
        claimed.amount += amount;
        self.write_model(@claimed);
    }

    fn get_claim_amount(self: @WorldStorage, game_id: felt252, claimant: Claimant) -> u256 {
        match claimant {
            Claimant::Dev => self.get_dev_amount(game_id),
            Claimant::Winner => self.get_win_amount(game_id),
            Claimant::Contributor(user) => self.get_contribution_amount(game_id, user),
        }
    }

    fn claim_amount(ref self: WorldStorage, game_id: felt252, claimant: Claimant) -> u256 {
        let amount = self.get_claim_amount(game_id, claimant);
        assert(amount > 0, 'No amount to claim');
        self.make_claim(game_id, claimant);
        self.set_amount_claimed(game_id, amount);
        amount
    }

    fn claim_remainder(ref self: WorldStorage, game_id: felt252) -> u256 {
        let total = self.get_jackpot_total_amount(game_id);
        let mut claimed = self.get_jackpot_claimed(game_id);
        let remainder = total - claimed.amount;
        claimed.amount = total;
        self.write_model(@claimed);
        remainder
    }
}
