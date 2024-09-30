use starknet::ContractAddress;
use rising_revenant::fortifications::models::Fortification;
const CARE_PACKAGE_SELECTOR: felt252 = 'erc721-care-packages';

#[dojo::interface]
pub trait ICarePackage<TContractState> {
    fn purchase(ref self: TContractState) -> felt252;
    fn receive(ref self: TContractState);
    fn open(ref self: TContractState, token_id: u256);
}


#[dojo::contract]
mod care_package {
    use starknet::{get_caller_address, ContractAddress};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    use rr_tokens::care_packages::{
        ICarePackageDispatcher, ICarePackageDispatcherTrait, Rarity, N_RARITIES
    };
    use rising_revenant::{
        addresses::GetAddressTrait, fortifications::models::{Fortification, Fortifications},
        accounts::{AccountInfo, Account}, utils::{felt252_to_u128, hash_value},
        care_packages::systems::{
            get_fortifications_types, get_number_of_fortifications, get_rarity
        },
    };
    use super::{CARE_PACKAGE_SELECTOR, ICarePackage};
    #[abi(embed_v0)]
    impl CarePackagesImpl of ICarePackage<ContractState> {
        fn purchase(ref world: IWorldDispatcher) -> felt252 {
            let caller = get_caller_address();
            let account = world.get_account();
            let key = hash_value((caller, 'purchase'));
            account.receive(caller, world.get_care_package_price());
            key
        }

        fn receive(world: @IWorldDispatcher) {
            let caller = get_caller_address();
            let randomness = 12; //TODO: get_randomness();
            let key = hash_value((caller, 'purchase'));
            let rarity = get_rarity(randomness);
            let dispatcher = world.get_care_package_dispatcher().mint(caller, rarity);
        }

        fn open(ref world: IWorldDispatcher, token_id: u256) {
            let key = hash_value((token_id, 'open'));
            let caller = get_caller_address();
            let dispatcher = self.get_care_package_dispatcher();
            assert(caller == dispatcher.owner_of(token_id), 'Not Owner');
            let rarity = dispatcher.get_rarity(token_id);
            let erc721_dispatcher = dispatcher.burn_from(token_id);
            let randomness: felt252 = 0;

            let num_of_fortifications = get_number_of_fortifications(rarity, randomness);
            let fortifications = get_fortifications_types(
                rarity, hash_value((randomness, 'types'))
            );

            self.mint_fortifications(caller, fortifications);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn get_care_package_dispatcher(self: IWorldDispatcher) -> ICarePackageDispatcher {
            ICarePackageDispatcher {
                contract_address: self.get_address_from_selector(CARE_PACKAGE_SELECTOR),
            }
        }
        fn mint_fortification(
            self: IWorldDispatcher,
            fortification: Fortification,
            recipient: ContractAddress,
            amount: u64
        ) {
            IERC20MintableBurnableDispatcher { contract_address: self.get_address(fortification), }
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

        fn get_care_package_price(self: IWorldDispatcher) -> u256 {
            12
        }
    }
}
