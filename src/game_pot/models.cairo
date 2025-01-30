use starknet::ContractAddress;
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
    winner_purchases_permille: u16,
    contribution_purchases_permille: u16,
    pot_address: ContractAddress,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct IncreasePurchasesAmount {
    purchases: u256,
    pot_address: ContractAddress,
    token_address: ContractAddress,
}

#[derive(Drop, Serde, Introspect)]
struct WinnersAmountRead {
    purchases: u256,
    winner_purchases_permille: u16,
}

#[derive(Drop, Serde, Introspect)]
struct ContributorsAmountRead {
    purchases: u256,
    contribution_purchases_permille: u16,
}

#[derive(Drop, Serde)]
struct TransferTo {
    token_address: ContractAddress,
    recipient: ContractAddress,
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

    fn get_winners_purchases_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        let WinnersAmountRead {
            purchases, winner_purchases_permille,
        } = self.read_game_pot_schema(game_id);
        get_permille(purchases, winner_purchases_permille)
    }
    fn get_contributors_purchases_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        let ContributorsAmountRead {
            purchases, contribution_purchases_permille,
        } = self.read_game_pot_schema(game_id);
        get_permille(purchases, contribution_purchases_permille)
    }

    fn get_purchases_amount(self: @WorldStorage, game_id: felt252) -> u256 {
        self.read_member(Model::<GamePot>::ptr_from_keys(game_id), selector!("purchases"))
    }

    fn increase_purchases_amount(
        ref self: WorldStorage, game_id: felt252, amount: u256,
    ) -> TransferTo {
        let data: IncreasePurchasesAmount = self.read_game_pot_schema(game_id);
        self.write_game_pot_member(game_id, selector!("purchases"), amount + data.purchases);

        TransferTo { token_address: data.token_address, recipient: data.pot_address }
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
                    winner_purchases_permille,
                    contribution_purchases_permille,
                    pot_address,
                    token_address,
                },
            )
    }
}
