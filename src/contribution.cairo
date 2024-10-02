use starknet::{get_caller_address, ContractAddress};
use dojo::world::{IWorldDispatcher};
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
    claimed: bool
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct ContributionValue {
    #[key]
    game_id: felt252,
    #[key]
    event: ContributionEvent,
    value: u128,
}


#[generate_trait]
impl ContributionImpl of ContributionTrait {
    fn get_contribution(self: @IWorldDispatcher, game_id: felt252, user: ContractAddress) -> u128 {
        ContributionStore::get(*self, game_id, user)
    }
    fn get_contribution_score(
        self: @IWorldDispatcher, game_id: felt252, user: ContractAddress
    ) -> u128 {
        ContributionStore::get_score(*self, game_id, user)
    }
    fn get_total_contribution(self: @IWorldDispatcher, game_id: felt252) -> u128 {
        self.get_contribution(game_id, Zero::zero())
    }
    fn increase_contribution(
        self: IWorldDispatcher, game_id: felt252, user: ContractAddress, event: ContributionEvent
    ) {
        let value = ContributionValueStore::get_value(self, game_id, event);
        let mut model = ContributionStore::get(self, game_id, user);
        let mut total = ContributionStore::get(self, game_id, Zero::zero());
        model.score += value;
        total.score += value;
        model.set(self);
        total.set(self);
    }
    fn increase_caller_contribution(
        self: IWorldDispatcher, game_id: felt252, event: ContributionEvent
    ) {
        self.increase_contribution(game_id, get_caller_address(), event);
    }
}

