use starknet::{
    ContractAddress,
    storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map,}
};
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};


#[dojo::model]
#[derive(Drop, Serde)]
struct JackpotAddress {
    #[key]
    game_id: felt252,
    contract_address: ContractAddress,
}

/// Represents the total amount in a jackpot for a specific game
/// @param game_id - Unique identifier for the game
/// @param total - Total amount in the jackpot in wei
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotTotal {
    #[key]
    game_id: felt252,
    total: u256,
}

/// Tracks whether a specific claimant has claimed their share for a game
/// @param game_id - Unique identifier for the game
/// @param claimant - Type of claimant (Dev, Winner, or Contributor)
/// @param claimed - Boolean indicating if the share has been claimed
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct ContributorClaimed {
    #[key]
    game_id: felt252,
    #[key]
    user: ContractAddress,
    claimed: bool,
}


/// Tracks whether a specific claimant has claimed their share for a game
/// @param game_id - Unique identifier for the game
/// @param claimant - Type of claimant (Dev, Winner, or Contributor)
/// @param claimed - Boolean indicating if the share has been claimed
#[dojo::model]
#[derive(Drop, Serde)]
struct WinnerClaimed {
    #[key]
    game_id: felt252,
    claimed: bool,
}


/// Defines how the jackpot is split between different parties
/// @param game_id - Unique identifier for the game
/// @param winner_permille - Winner's share in permille (parts per thousand)
/// @param contribution_permille - Contributors' share in permille
#[dojo::model]
#[derive(Drop, Serde, IntrospectPacked)]
struct JackpotSplit {
    #[key]
    game_id: felt252,
    winner_permille: u16,
    contribution_permille: u16,
}

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
impl JackpotImpl of JackpotStorage {
    /// Returns the total amount in the jackpot for a specific game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The total jackpot amount
    fn get_jackpot_total(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<JackpotTotal>::ptr_from_keys(game_id), selector!("total"))
    }

    fn set_jackpot_total(ref self: WorldStorage, game_id: felt252, amount: u256) {
        self.write_model(@JackpotTotal { game_id, total: amount });
    }

    fn get_jackpot_winner_claimed(self: @WorldStorage, game_id: felt252) -> bool {
        self.read_member(Model::<WinnerClaimed>::ptr_from_keys(game_id), selector!("claimed"))
    }

    fn set_jackpot_winner_claimed(ref self: WorldStorage, game_id: felt252) {
        assert(!self.get_jackpot_winner_claimed(game_id), 'Already claimed');
        self.write_model(@WinnerClaimed { game_id, claimed: true });
    }

    fn get_jackpot_contributor_claimed(
        self: @WorldStorage, game_id: felt252, user: ContractAddress,
    ) -> bool {
        self
            .read_member(
                Model::<ContributorClaimed>::ptr_from_keys((game_id, user)), selector!("claimed")
            )
    }

    fn set_jackpot_contributor_claimed(
        ref self: WorldStorage, game_id: felt252, user: ContractAddress,
    ) {
        assert(!self.get_jackpot_contributor_claimed(game_id, user), 'Already claimed');
        self.write_model(@ContributorClaimed { game_id, user, claimed: true });
    }


    /// Returns the winner's share in permille (parts per thousand).
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The wi's share in permille
    fn get_winner_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self
            .read_member(
                Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("winner_permille")
            )
    }

    /// Returns the contribution share in permille.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The contribution share in permille
    fn get_contribution_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        self
            .read_member(
                Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("contribution_permille")
            )
    }

    fn get_jackpot_address(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        self
            .read_member(
                Model::<JackpotAddress>::ptr_from_keys(game_id), selector!("contract_address")
            )
    }

    fn set_jackpot_address(
        ref self: WorldStorage, game_id: felt252, contract_address: ContractAddress,
    ) {
        self.write_model(@JackpotAddress { game_id, contract_address });
    }
}
