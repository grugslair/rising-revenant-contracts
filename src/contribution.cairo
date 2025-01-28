use starknet::{get_caller_address, ContractAddress};
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use core::num::traits::Zero;

/// Represents different types of contribution events in the game
#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum ContributionEvent {
    /// Event when something is created
    EventCreated,
    /// Event when something is applied
    EventApplied,
    /// Event when an outpost is destroyed
    OutpostDestroyed,
}

/// Tracks the contribution score for a user in a specific game
#[dojo::model]
#[derive(Drop, Serde)]
struct UserContribution {
    /// Unique identifier for the game
    #[key]
    game_id: felt252,
    /// Address of the contributing user
    #[key]
    user: ContractAddress,
    /// Total contribution score for this user
    amount: u128,
}


/// Defines the weight/value of different contribution events
#[dojo::model]
#[derive(Drop, Serde)]
struct ContributionWeight {
    /// Unique identifier for the game
    #[key]
    game_id: felt252,
    /// Type of contribution event
    #[key]
    event: ContributionEvent,
    /// Weight value for this event type
    value: u128,
}

#[generate_trait]
impl ContributionImpl of Contribution {
    /// Gets the weight value for a specific contribution event type
    fn get_contribution_value(
        self: @WorldStorage, game_id: felt252, event: ContributionEvent,
    ) -> u128 {
        self
            .read_member(
                Model::<ContributionWeight>::ptr_from_keys((game_id, event)), selector!("value"),
            )
    }

    /// Retrieves the contribution score for a specific user in a game
    fn get_contribution_amount(
        self: @WorldStorage, game_id: felt252, user: ContractAddress,
    ) -> u128 {
        self
            .read_member(
                Model::<UserContribution>::ptr_from_keys((game_id, user)), selector!("amount"),
            )
    }

    /// Gets the total contribution score for all users in a game
    fn get_total_contribution_amount(self: @WorldStorage, game_id: felt252) -> u128 {
        self.get_contribution_amount(game_id, Zero::zero())
    }

    /// Increases the contribution score for a specific user and updates the total
    fn increase_contribution(
        ref self: WorldStorage, game_id: felt252, user: ContractAddress, event: ContributionEvent,
    ) {
        let value = self.get_contribution_value(game_id, event);
        self
            .write_models(
                [
                    @UserContribution {
                        game_id, user, amount: self.get_contribution_amount(game_id, user) + value,
                    },
                    @UserContribution {
                        game_id,
                        user: Zero::zero(),
                        amount: self.get_contribution_amount(game_id, Zero::zero()) + value,
                    },
                ]
                    .span(),
            );
    }

    /// Increases the contribution score for the calling user
    fn increase_caller_contribution(
        ref self: WorldStorage, game_id: felt252, event: ContributionEvent,
    ) {
        self.increase_contribution(game_id, get_caller_address(), event);
    }

    fn get_contribution_portion(
        self: @WorldStorage, game_id: felt252, user: ContractAddress, total: u256,
    ) -> u256 {
        self.get_contribution_amount(game_id, user).into()
            * total
            / self.get_total_contribution_amount(game_id).into()
    }
}

