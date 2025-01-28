use starknet::{
    ContractAddress,
    storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map},
};
use dojo::{world::WorldStorage, model::{ModelStorage, Model}, meta::Introspect};


/// Represents the total amount in a game_pot for a specific game
/// @param game_id - Unique identifier for the game
/// @param total - Total amount in the game_pot in wei
/// @param winner_permille - Winner's share in permille (parts per thousand)
/// @param contribution_permille - Contributors' share in permille
#[dojo::model]
#[derive(Drop, Serde)]
struct GamePot {
    #[key]
    game_id: felt252,
    purchases: u256,
    contributors: u256,
    winners: u256,
    winner_purchases_permille: u16,
    contribution_purchases_permille: u16,
    pot_address: ContractAddress,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct PotAmounts {
    purchases: u256,
    contributors: u256,
    winners: u256,
}

#[derive(Drop, Serde, Introspect)]
struct IncreasePurchasesAmount {
    purchases: u256,
    pot_address: ContractAddress,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct IncreaseWinnersAmount {
    winners: u256,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct IncreaseContributorsAmount {
    contributors: u256,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct WinnersAmountRead {
    purchases: u256,
    winners: u256,
    winner_purchases_permille: u16,
}

#[derive(Drop, Serde, Introspect)]
struct ContributorsAmountRead {
    purchases: u256,
    contributors: u256,
    contribution_purchases_permille: u16,
}

#[derive(Drop, Serde, Introspect)]
struct WinnersAmountPay {
    purchases: u256,
    winners: u256,
    winner_purchases_permille: u16,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct ContributorsAmountPay {
    purchases: u256,
    contributors: u256,
    contribution_purchases_permille: u16,
    token_address: ContractAddress,
}

#[derive(Drop, Serde)]
struct TransferTo {
    token_address: ContractAddress,
    recipient: ContractAddress,
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

fn get_permille(amount: u256, permille: u16) -> u256 {
    amount * permille.into() / 1000
}

/// The GamePotTrait provides a comprehensive system for managing game game_pots.
/// It handles:
/// * Tracking total and claimed game_pot amounts
/// * Managing distribution shares between developers, winners, and contributors
/// * Processing claims and verifying claim eligibility
/// * Calculating various game_pot fractions and amounts
///
/// The system uses permille (parts per thousand) for precise share calculations,
/// allowing for flexible distribution ratios between different stakeholders.
#[generate_trait]
impl GamePotImpl of GamePotStorage {
    fn read_game_pot_schema<T, +Introspect<T>, +Serde<T>>(
        self: @WorldStorage, game_id: felt252,
    ) -> T {
        self.read_schema(Model::<GamePot>::ptr_from_keys(game_id))
    }

    fn read_game_pot_member<T, +Serde<T>>(
        self: @WorldStorage, game_id: felt252, field_selector: felt252,
    ) -> T {
        self.read_member(Model::<GamePot>::ptr_from_keys(game_id), field_selector)
    }

    fn write_game_pot_member<T, +Serde<T>, +Drop<T>>(
        ref self: WorldStorage, game_id: felt252, field_selector: felt252, value: T,
    ) {
        self.write_member(Model::<GamePot>::ptr_from_keys(game_id), field_selector, value);
    }

    fn get_game_token_address(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        self.read_game_pot_member(game_id, selector!("token_address"))
    }

    fn get_game_pot_winner_claimed(self: @WorldStorage, game_id: felt252) -> bool {
        self.read_member(Model::<WinnerClaimed>::ptr_from_keys(game_id), selector!("claimed"))
    }

    fn set_game_pot_winner_claimed(ref self: WorldStorage, game_id: felt252) {
        assert(!self.get_game_pot_winner_claimed(game_id), 'Already claimed');
        self.write_model(@WinnerClaimed { game_id, claimed: true });
    }

    fn get_game_pot_contributor_claimed(
        self: @WorldStorage, game_id: felt252, user: ContractAddress,
    ) -> bool {
        self
            .read_member(
                Model::<ContributorClaimed>::ptr_from_keys((game_id, user)), selector!("claimed"),
            )
    }

    fn set_game_pot_contributor_claimed(
        ref self: WorldStorage, game_id: felt252, user: ContractAddress,
    ) {
        assert(!self.get_game_pot_contributor_claimed(game_id, user), 'Already claimed');
        self.write_model(@ContributorClaimed { game_id, user, claimed: true });
    }

    fn read_winners_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        let WinnersAmountRead {
            purchases, winners, winner_purchases_permille,
        } = self.read_game_pot_schema(game_id);
        winners + get_permille(purchases, winner_purchases_permille)
    }
    fn read_contributors_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        let ContributorsAmountRead {
            purchases, contributors, contribution_purchases_permille,
        } = self.read_game_pot_schema(game_id);
        contributors + get_permille(purchases, contribution_purchases_permille)
    }

    fn get_contributors_payout(self: @WorldStorage, game_id: felt252) -> ContributorsAmountPay {
        self.read_game_pot_schema(game_id)
    }

    fn get_winners_payout(self: @WorldStorage, game_id: felt252) -> WinnersAmountPay {
        self.read_game_pot_schema(game_id)
    }

    fn get_purchases_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<GamePot>::ptr_from_keys(game_id), selector!("purchases"))
    }

    fn get_contributors_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<GamePot>::ptr_from_keys(game_id), selector!("contributors"))
    }

    fn get_winners_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<GamePot>::ptr_from_keys(game_id), selector!("winners"))
    }


    fn increase_purchases_amount(
        ref self: WorldStorage, game_id: felt252, amount: u256,
    ) -> TransferTo {
        let data: IncreasePurchasesAmount = self.read_game_pot_schema(game_id);
        self.write_game_pot_member(game_id, selector!("purchases"), amount + data.purchases);

        TransferTo { token_address: data.token_address, recipient: data.pot_address }
    }

    fn increase_contributors_amount(
        ref self: WorldStorage, game_id: felt252, amount: u256,
    ) -> ContractAddress {
        let data: IncreaseContributorsAmount = self.read_game_pot_schema(game_id);
        self.write_game_pot_member(game_id, selector!("contributors"), amount + data.contributors);
        data.token_address
    }

    fn increase_winners_amount(
        ref self: WorldStorage, game_id: felt252, amount: u256,
    ) -> ContractAddress {
        let data: IncreaseWinnersAmount = self.read_game_pot_schema(game_id);
        self.write_game_pot_member(game_id, selector!("winners"), amount + data.winners);
        data.token_address
    }


    fn create_game_pot(
        ref self: WorldStorage,
        game_id: felt252,
        winner_purchases_permille: u16,
        contribution_purchases_permille: u16,
        pot_address: ContractAddress,
        token_address: ContractAddress,
    ) {
        self
            .write_model(
                @GamePot {
                    game_id,
                    purchases: 0,
                    contributors: 0,
                    winners: 0,
                    winner_purchases_permille,
                    contribution_purchases_permille,
                    pot_address,
                    token_address,
                },
            )
    }
}
