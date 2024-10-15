use starknet::ContractAddress;
use rising_revenant::fortifications::models::Fortification;
const CARE_PACKAGE_SELECTOR: felt252 = 'erc721-care-packages';

#[dojo::interface]
pub trait ICarePackage<TContractState> {
    fn get_price(self: @IWorldDispatcher, game_id: felt252) -> u64;
    fn purchase(ref self: TContractState, game_id: felt252);
    fn open(ref self: TContractState, token_id: u256);
}


#[dojo::contract]
mod care_package {
    use starknet::{get_caller_address, ContractAddress};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    use rising_revenant::{
        addresses::{AddressBook, GetDispatcher}, fortifications::models::{Fortification, Fortifications},
        finance::{Finance}, utils::{felt252_to_u128, hash_value},
        game::GameTrait,
        care_packages::{Rarity, N_RARITIES, systems::{
            get_fortifications, get_rarity, CarePackageMarketTrait
        }, ICarePackageTokenDispatcher, ICarePackageTokenDispatcherTrait},
        vrf::{VRF, Source},

    };
    
    use rising_revenant::vrgda::{LogisticVRGDA, VRGDATrait};
    use super::{CARE_PACKAGE_SELECTOR, ICarePackage};


    #[abi(embed_v0)]
    impl CarePackagesImpl of ICarePackage<ContractState> {
        fn get_price(self: @IWorldDispatcher, game_id: felt252) -> u64 {
            self.assert_preparing(game_id);
            let market = self.get_care_package_market(game_id);
            market.get_price(game_id, get_block_timestamp())
        }
        fn purchase(ref world: IWorldDispatcher, game_id: felt252) {
            self.assert_preparing(game_id);
            let caller = get_caller_address();

            let mut account = world.get_finance_account();
            let mut market = self.get_care_package_market();
            
            account.receive(caller, market.get_price(game_id, get_block_timestamp()));
            market.sold += 1;

            let rarity = get_rarity(world.randomness(Source::Nonce(caller)));
            world.get_care_package_dispatcher().mint(caller, rarity);
        }

        fn open(ref world: IWorldDispatcher, token_id: u256) {
            let caller = get_caller_address();
            let key: felt252  = token_id.try_into().unwrap();

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
        fn get_care_package_dispatcher(self: @IWorldDispatcher) -> ICarePackageTokenDispatcher {
            self.get_dispatcher()
        }
        fn mint_fortification(
            self: IWorldDispatcher,
            fortification: Fortification,
            recipient: ContractAddress,
            amount: u64
        ) {
            IERC20MintableBurnableDispatcher {
                contract_address: self.get_address(fortification),
            }
                .mint(recipient, amount.into());
        }
        fn mint_fortifications(
            self: IWorldDispatcher, recipient: ContractAddress, fortifications: Fortifications,
        ) {
            self.mint_fortification(Fortification::Palisade, recipient, fortifications.palisades);
            self.mint_fortification(Fortification::Trench, recipient, fortifications.trenches);
            self.mint_fortification(Fortification::Wall, recipient, fortifications.walls);
            self.mint_fortification(Fortification::Basement, recipient, fortifications.basements);
        }
    }
}
