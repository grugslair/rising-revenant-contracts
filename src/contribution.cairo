use starknet::{get_caller_address, ContractAddress};
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use core::num::traits::Zero;

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum ContributionEvent {
    EventCreated,
    EventApplied,
    OutpostDestroyed,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct Contribution {
    #[key]
    game_id: felt252,
    #[key]
    user: ContractAddress,
    score: u128,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct ContributionWeight {
    #[key]
    game_id: felt252,
    #[key]
    event: ContributionEvent,
    value: u128,
}


#[generate_trait]
impl ContributionImpl of ContributionTrait {
    fn get_contribution(
        self: @WorldStorage, game_id: felt252, user: ContractAddress
    ) -> Contribution {
        self.read_model((game_id, user))
    }
    fn get_contribution_value(self: @WorldStorage, game_id: felt252, event: ContributionEvent) -> u128 {
        self.read_member(Model::<ContributionWeight>::ptr_from_keys((game_id, event)), selector!("value"))
    }
    fn get_contribution_score(
        self: @WorldStorage, game_id: felt252, user: ContractAddress
    ) -> u128 {
        self.read_member(Model::<Contribution>::ptr_from_keys((game_id, user)), selector!("score"))
    }
    fn get_total_contribution_score(self: @WorldStorage, game_id: felt252) -> u128 {
        self.get_contribution_score(game_id, Zero::zero())
    }
    fn increase_contribution(
        ref self: WorldStorage, game_id: felt252, user: ContractAddress, event: ContributionEvent
    ) {
        let value = self.get_contribution_value(game_id, event);
        let mut model = self.get_contribution(game_id, user);
        let mut total = self.get_contribution(game_id, Zero::zero());
        model.score += value;
        total.score += value;
        self.write_model(@model);
        self.write_model(@total);
    }
    fn increase_caller_contribution(
        ref self: WorldStorage, game_id: felt252, event: ContributionEvent
    ) {
        self.increase_contribution(game_id, get_caller_address(), event);
    }
}

