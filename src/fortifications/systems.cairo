use core::poseidon::poseidon_hash_span;
use starknet::{ContractAddress, ClassHash};
use dojo::{world::WorldStorage, model::{ModelStorage, ModelValueStorage}};
use rising_revenant::{
    fortifications::{
        Fortification, Fortifications, FortificationTrait, FortificationStorage,
        FortificationTokens, FORTIFICATION_CLASS_HASH_SELECTOR,
    },
    game::{GameStorage, ClassHashVariant}, utils::deploy_contract,
    tokens::{
        deploy_erc20_mintable_burnable, IERC20MintableBurnableDispatcher,
        IERC20MintableBurnableDispatcherTrait, erc20_mint
    },
    world::WorldTrait
};


#[generate_trait]
impl FortificationTokenImpl of FortificationTokenTrait {
    fn mint_fortifications(
        ref self: WorldStorage,
        game_id: felt252,
        recipient: ContractAddress,
        fortifications: Fortifications,
    ) {
        let addresses = self.get_fortification_contract_addresses(game_id);
        let amounts: Array<u64> = fortifications.into();

        for i in 0_usize..4 {
            erc20_mint(*addresses.at(i), recipient, (*amounts.at(i)).into());
        };
    }

    fn deploy_fortification_token(
        ref self: WorldStorage,
        class_hash: ClassHash,
        game_id: felt252,
        game_name: @ByteArray,
        admin: ContractAddress,
        minter: ContractAddress,
        fortification: Fortification
    ) -> ContractAddress {
        let fortification_felt: felt252 = fortification.into();
        deploy_erc20_mintable_burnable(
            class_hash,
            poseidon_hash_span([game_id, fortification_felt].span()),
            format!("RR {} {}", fortification_felt, game_name),
            fortification.symbol(),
            0,
            admin,
            minter,
        )
    }

    fn deploy_fortification_tokens(
        ref self: WorldStorage, game_id: felt252, game_name: @ByteArray, admin: ContractAddress,
    ) {
        let minter = self.get_contract_address("care_package_actions");
        let class_hash = self.get_class_hash(ClassHashVariant::ERC20MintableBurnable);
        self
            .set_fortifications_contract_address(
                game_id,
                self
                    .deploy_fortification_token(
                        class_hash, game_id, game_name, admin, minter, Fortification::Palisade
                    ),
                self
                    .deploy_fortification_token(
                        class_hash, game_id, game_name, admin, minter, Fortification::Trench
                    ),
                self
                    .deploy_fortification_token(
                        class_hash, game_id, game_name, admin, minter, Fortification::Wall
                    ),
                self
                    .deploy_fortification_token(
                        class_hash, game_id, game_name, admin, minter, Fortification::Basement
                    ),
            );
    }

    fn burn_fortification(
        ref self: WorldStorage,
        game_id: felt252,
        fortification: Fortification,
        from: ContractAddress,
        amount: u256
    ) {
        IERC20MintableBurnableDispatcher {
            contract_address: self.get_fortification_contract_address(game_id, fortification),
        }
            .burn_from(from, amount);
    }
}
