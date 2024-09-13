use starknet::ContractAddress;
use rising_revenant::fortifications::models::Fortification;
const CARE_PACKAGE_SELECTOR: felt252 = 'erc721-care-packages';

#[dojo::interface]
pub trait ICarePackage<TContractState> {
    fn set_fortification_address(
        ref self: TContractState,
        fortification_type: Fortification,
        fortification_address: ContractAddress
    );
    fn purchase(ref self: TContractState);
    fn open(ref self: TContractState, token_id: u256);
}


#[dojo::contract]
mod care_package {
    use starknet::{get_caller_address, ContractAddress};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    use rr_tokens::care_packages::{ICarePackageDispatcher, ICarePackageDispatcherTrait, Rarity};
    use rising_revenant::{addresses::GetAddressTrait, fortifications::models::Fortification};
    use super::CARE_PACKAGE_SELECTOR;
    use super::super::systems::{get_fortifications_types, get_number_of_fortifications};
    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn min_fortifications(
            self: IWorldDispatcher,
            fortification: Fortification,
            recipient: ContractAddress,
            amount: u256
        ) {
            IERC20MintableBurnableDispatcher { contract_address: self.get_address(fortification), }
                .mint(recipient, amount);
        }

        fn open_care_package(self: IWorldDispatcher, token_id: u256, randomness: felt252) {
            let caller = get_caller_address();
            let erc721_contract_address = self.get_address_from_selector(CARE_PACKAGE_SELECTOR);
            let custom_dispatcher = ICarePackageDispatcher {
                contract_address: erc721_contract_address,
            };
            let erc721_dispatcher = ERC721ABIDispatcher {
                contract_address: erc721_contract_address,
            };
            assert(caller == erc721_dispatcher.owner_of(token_id), 'Unauthorized');
            let rarity = custom_dispatcher.get_rarity(token_id);
            custom_dispatcher.burn_from(token_id);
            let num_of_fortifications = get_number_of_fortifications(rarity, randomness);
        }
    }
}
