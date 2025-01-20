use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, ModelValueStorage, Model}};
use rising_revenant::fortifications::{
    Fortification, FortificationTrait, models::{FortificationToken, FortificationTokenValue}
};
use tokens::erc20::interfaces::{IERC20Dispatcher, IERC20DispatcherTrait};


#[generate_trait]
impl FortificationStorageImpl of FortificationStorageTrait {
    fn get_fortification_contract_addresses(
        self: @WorldStorage, game_id: felt252,
    ) -> Array<ContractAddress> {
        let value: FortificationTokenValue = self.read_value(game_id);
        value.into()
    }
    fn get_fortification_contract_address(
        self: @WorldStorage, game_id: felt252, fortification: Fortification
    ) -> ContractAddress {
        self
            .read_member(
                Model::<FortificationToken>::ptr_from_keys(game_id), fortification.selector()
            )
    }
}
