use core::poseidon::poseidon_hash_span;
use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, ModelValueStorage}};
use rising_revenant::{
    fortifications::{
        Fortification, Fortifications, FortificationTrait, FortificationStorage,
        FortificationTokens, FORTIFICATION_CLASS_HASH_SELECTOR,
    },
    game::GameStorage, utils::deploy_contract,
    erc20_mintable_burnable::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    },
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

        for i in 0_usize
            ..4 {
                IERC20MintableBurnableDispatcher { contract_address: *addresses.at(i) }
                    .mint(recipient, (*amounts.at(i)).into());
            };
    }

    fn deploy_fortification_token(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        admin: ContractAddress,
        minter: ContractAddress,
        fortification: Fortification
    ) -> ContractAddress {
        let mut calldata = array![];

        let fortification_felt: felt252 = fortification.into();
        let salt = poseidon_hash_span([game_id, fortification_felt].span());
        Serde::serialize(@format!("RR {} {}", fortification_felt, game_name), ref calldata);
        Serde::serialize(@fortification.symbol(), ref calldata);
        calldata.append_span([0, admin.into(), minter.into()].span());

        deploy_contract(
            self.get_class_hash(FORTIFICATION_CLASS_HASH_SELECTOR), calldata.span(), salt
        )
    }

    fn deploy_fortification_tokens(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        admin: ContractAddress,
        minter: ContractAddress
    ) {
        self
            .set_fortifications_contract_address(
                game_id,
                self
                    .deploy_fortification_token(
                        game_id, game_name, admin, minter, Fortification::Palisade
                    ),
                self
                    .deploy_fortification_token(
                        game_id, game_name, admin, minter, Fortification::Trench
                    ),
                self
                    .deploy_fortification_token(
                        game_id, game_name, admin, minter, Fortification::Wall
                    ),
                self
                    .deploy_fortification_token(
                        game_id, game_name, admin, minter, Fortification::Basement
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
