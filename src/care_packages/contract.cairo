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
    fn reveal_rarity(ref self: TContractState, game_id: felt252, token_id: felt252);
    fn open(ref self: TContractState, game_id: felt252, token_id: felt252);
    fn get_rarity(self: @TContractState, game_id: felt252, token_id: felt252) -> Rarity;
    fn is_opened(self: @TContractState, game_id: felt252, token_id: felt252) -> bool;
    fn get_owner(self: @TContractState, game_id: felt252, token_id: felt252) -> ContractAddress
}


#[dojo::contract]
mod care_package {
    use core::poseidon::poseidon_hash_span;
    use starknet::{get_caller_address, ContractAddress, get_block_timestamp};
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use tokens::erc20::interfaces::{IERC20Dispatcher, IERC20DispatcherTrait};
    use rising_revenant::{
        addresses::{AddressBook, GetDispatcher},
        fortifications::{Fortification, Fortifications, systems::FortificationMintTrait},
        finance::{Finance}, game::GameTrait,
        care_packages::{
            Rarity, N_RARITIES, systems::{get_fortifications, get_rarity}, CarePackageTrait,
            CarePackageStorage
        },
        world::default_namespace, vrf::{VRF, Source},
    };

    use rising_revenant::vrgda::{LogisticVRGDA, VRGDATrait};
    use super::{ICarePackage};


    #[abi(embed_v0)]
    impl CarePackagesImpl of ICarePackage<ContractState> {
        fn reveal_rarity(ref self: ContractState, game_id: felt252, token_id: felt252) {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();

            let rarity = get_rarity(world
                .randomness(Source::Salt(poseidon_hash_span([game_id, token_id, 'rarity'].span()))));
        }

        fn open(ref self: ContractState, game_id: felt252, token_id: felt252) {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();
            assert(caller == world.get_care_package_owner(game_id, token_id), 'Not Owner');
            let randomness = world.randomness(Source::Salt(poseidon_hash_span([game_id, token_id, 'rarity'].span())));
            world.open_care_package(game_id, token_id, caller, randomness);
        }
        fn get_rarity(self: @ContractState, game_id: felt252, token_id: felt252) -> Rarity {
            let world = self.world(default_namespace());
            world.get_care_package_rarity(game_id, token_id)
        }
        fn is_opened(self: @ContractState, game_id: felt252, token_id: felt252) -> bool {
            let world = self.world(default_namespace());
            world.get_care_package_opened(game_id, token_id)
        }
        fn get_owner(self: @ContractState, game_id: felt252, token_id: felt252) -> ContractAddress {
            let world = self.world(default_namespace());
            world.get_care_package_owner(game_id, token_id)
        }
    }
}
