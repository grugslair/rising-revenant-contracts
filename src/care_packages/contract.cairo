use starknet::ContractAddress;
use rising_revenant::fortifications::models::Fortification;
const CARE_PACKAGE_SELECTOR: felt252 = 'erc721-care-packages';


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
    fn get_price(self: @TContractState, game_id: felt252) -> u256;
    fn purchase(ref self: TContractState, game_id: felt252);
    fn open(ref self: TContractState, token_id: u256);
}


#[dojo::contract]
mod care_package {
    use dojo::world::WorldStorage;
    use starknet::{get_caller_address, ContractAddress, get_block_timestamp};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use tokens::erc20::interfaces::{IERC20Dispatcher, IERC20DispatcherTrait};
    use rising_revenant::{
        addresses::{AddressBook, GetDispatcher},
        fortifications::models::{Fortification, Fortifications}, finance::{Finance},
        utils::{felt252_to_u128, hash_value}, game::GameTrait,
        care_packages::{
            Rarity, N_RARITIES, systems::{get_fortifications, get_rarity, CarePackageMarketTrait},
            ICarePackageTokenDispatcher, ICarePackageTokenDispatcherTrait
        },
        world::default_namespace, vrf::{VRF, Source},
    };

    use rising_revenant::vrgda::{LogisticVRGDA, VRGDATrait};
    use super::{CARE_PACKAGE_SELECTOR, ICarePackage};


    #[abi(embed_v0)]
    impl CarePackagesImpl of ICarePackage<ContractState> {
        fn get_price(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.assert_preparing(game_id);
            let market = world.get_care_package_market(game_id);
            market.get_price(get_block_timestamp())
        }
        fn purchase(ref self: ContractState, game_id: felt252) {
            let mut world = self.world(default_namespace());

            world.assert_preparing(game_id);
            let caller = get_caller_address();

            let mut account = world.get_finance_account();
            let mut market = world.get_care_package_market(game_id);

            account.receive(caller, market.get_price(get_block_timestamp()));
            market.sold += 1;

            let rarity = get_rarity(world.randomness(Source::Nonce(caller)));
            world.get_care_package_dispatcher().mint(caller, rarity);
        }

        fn open(ref self: ContractState, token_id: u256) {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();
            let key: felt252 = token_id.try_into().unwrap();

            let token_dispatcher = world.get_care_package_dispatcher();
            assert(caller == token_dispatcher.owner_of(token_id), 'Not Owner');

            token_dispatcher.burn_from(token_id);

            let randomness = world.randomness(Source::Salt(key));
            let rarity = token_dispatcher.get_rarity(token_id);
            let fortifications = get_fortifications(rarity, randomness);

            world.mint_fortifications(caller, fortifications);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        /// Retrieves the care package dispatcher from the world storage.
        ///
        /// # Returns
        /// An instance of `ICarePackageTokenDispatcher`.
        fn get_care_package_dispatcher(self: @WorldStorage) -> ICarePackageTokenDispatcher {
            self.get_dispatcher()
        }

        /// Mints a specified amount of a fortification type to a recipient.
        ///
        /// # Parameters
        /// - `fortification`: The type of fortification to mint.
        /// - `recipient`: The address of the recipient.
        /// - `amount`: The amount of fortification to mint.
        fn mint_fortification(
            ref self: WorldStorage,
            fortification: Fortification,
            recipient: ContractAddress,
            amount: u64
        ) {
            IERC20Dispatcher { contract_address: self.get_address(fortification), }
                .mint_to(recipient, amount.into());
        }

        /// Mints various types of fortifications to a recipient.
        ///
        /// # Parameters
        /// - `recipient`: The address of the recipient.
        /// - `fortifications`: The fortifications to mint, including palisades, trenches, walls, and basements.
        fn mint_fortifications(
            ref self: WorldStorage, recipient: ContractAddress, fortifications: Fortifications,
        ) {
            self.mint_fortification(Fortification::Palisade, recipient, fortifications.palisades);
            self.mint_fortification(Fortification::Trench, recipient, fortifications.trenches);
            self.mint_fortification(Fortification::Wall, recipient, fortifications.walls);
            self.mint_fortification(Fortification::Basement, recipient, fortifications.basements);
        }
    }
}
