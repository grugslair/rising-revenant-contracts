use starknet::ContractAddress;
use rising_revenant::care_packages::Rarity;

/// Interface for the Care Package contract.
///
/// This interface defines the methods for interacting with care packages in the game.
///
/// # Methods
/// - `get_price`: Retrieves the price of a care package for a given game ID.
/// - `purchase`: Purchases a care package for a given game ID.
/// - `open`: Opens a purchased care package using its token ID.
#[starknet::interface]
pub trait ICarePackage<TContractState> {
    fn purchase(ref self: TContractState, game_id: felt252) -> felt252;
    fn open(ref self: TContractState, token_id: felt252);
    fn get_rarity(self: @TContractState, token_id: felt252) -> Rarity;
    fn is_opened(self: @TContractState, token_id: felt252) -> bool;
    fn get_owner(self: @TContractState, token_id: felt252) -> ContractAddress;
    fn get_game_id(self: @TContractState, token_id: felt252) -> felt252;
    fn get_price(self: @TContractState, game_id: felt252) -> u256;
}


#[dojo::contract]
mod care_package_actions {
    use core::poseidon::poseidon_hash_span;
    use starknet::{get_caller_address, ContractAddress, get_contract_address, get_block_timestamp};
    use dojo::world::WorldStorage;
    use rising_revenant::{
        fortifications::FortificationTokenTrait, game::{GameTrait, GameStorage},
        care_packages::{Rarity, CarePackageTrait, CarePackageStorage, CarePackageMarketTrait},
        tokens::{erc721_owner_of}, world::default_namespace, vrf::{VRF, Source},
    };

    use rising_revenant::vrgda::{LogisticVRGDA, VRGDATrait};
    use super::{ICarePackage};


    #[abi(embed_v0)]
    impl CarePackagesImpl of ICarePackage<ContractState> {
        fn purchase(ref self: ContractState, game_id: felt252) -> felt252 {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();
            let randomness = world.randomness(Source::Nonce(caller));
            let id = world.purchase_care_package(game_id, caller, randomness);

            id
        }

        fn open(ref self: ContractState, token_id: felt252) {
            let mut world = self.world(default_namespace());
            let randomness = world.randomness(Source::Salt(token_id));

            world.open_care_package(token_id, randomness);
        }
        fn get_rarity(self: @ContractState, token_id: felt252) -> Rarity {
            let world = self.world(default_namespace());
            world.get_care_package_rarity(token_id)
        }
        fn is_opened(self: @ContractState, token_id: felt252) -> bool {
            let world = self.world(default_namespace());
            world.get_care_package_opened(token_id)
        }
        fn get_owner(self: @ContractState, token_id: felt252) -> ContractAddress {
            let world = self.world(default_namespace());
            world.get_care_package_owner_from_id(token_id)
        }
        fn get_game_id(self: @ContractState, token_id: felt252) -> felt252 {
            let world = self.world(default_namespace());
            world.get_care_package_game_id(token_id)
        }
        fn get_price(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            let market = world.get_care_package_market(game_id);
            market
                .get_care_package_price(
                    world.get_game_phase_prep_start(game_id), get_block_timestamp(),
                )
        }
    }
}
