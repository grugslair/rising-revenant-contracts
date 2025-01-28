use starknet::{
    ContractAddress,
    storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map,}
};
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};

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

/// Tracks the amount that has been claimed from a specific game's jackpot
/// @param game_id - Unique identifier for the game
/// @param amount - Amount that has been claimed in wei
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct JackpotClaimed {
    #[key]
    game_id: felt252,
    amount: u256,
}

/// Represents different types of entities that can claim from the jackpot
/// Dev: Game developers
/// Winner: Game winner
/// Contributor: Address of someone who contributed to the jackpot
#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Claimant {
    Dev,
    Winner,
    Contributor: ContractAddress,
}

/// Tracks whether a specific claimant has claimed their share for a game
/// @param game_id - Unique identifier for the game
/// @param claimant - Type of claimant (Dev, Winner, or Contributor)
/// @param claimed - Boolean indicating if the share has been claimed
#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Claimed {
    #[key]
    game_id: felt252,
    #[key]
    claimant: Claimant,
    claimed: bool,
}

/// Defines how the jackpot is split between different parties
/// @param game_id - Unique identifier for the game
/// @param dev_permille - Developer's share in permille (parts per thousand)
/// @param contribution_permille - Contributors' share in permille
#[dojo::model]
#[derive(Copy, Drop, Serde, IntrospectPacked)]
struct JackpotSplit {
    #[key]
    game_id: felt252,
    dev_permille: u16,
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

    fn set_jackpot_total_amount(ref self: WorldStorage, game_id: felt252, amount: u256) {
        self.write_model(@JackpotTotal { game_id, total: amount });
    }

    /// Returns the claimed jackpot model for a specific game.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `JackpotClaimed` - The claimed jackpot model
    fn get_jackpot_claimed(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<JackpotClaimed>::ptr_from_keys(game_id), selector!("amount"))
    }

    fn set_jackpot_claimed(ref self: WorldStorage, game_id: felt252, amount: u256) {
        self.write_model(@JackpotClaimed { game_id, amount });
    }

    /// Calculates the remaining unclaimed amount in the jackpot.
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u256` - The amount remaining to be claimed
    fn get_jackpot_left(self: @WorldStorage, game_id: felt252) -> u256 {
        self.get_jackpot_total_amount(game_id) - self.get_jackpot_claimed(game_id)
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
        self
            .read_member(
                Model::<JackpotSplit>::ptr_from_keys(game_id), selector!("contribution_permille")
            )
    }

    /// Calculates the winner's share in permille (1000 - dev - contribution).
    /// # Arguments
    /// * `game_id` - The unique identifier of the game
    /// # Returns
    /// * `u16` - The winner's share in permille
    fn get_win_permille(self: @WorldStorage, game_id: felt252) -> u16 {
        1000 - self.get_dev_permille(game_id) - self.get_contribution_permille(game_id)
    }

    fn set_claimant(ref self: WorldStorage, game_id: felt252, claimant: Claimant) {
        self.write_model(@Claimed { game_id, claimant, claimed: true });
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
}
