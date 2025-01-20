use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, ModelValueStorage}};
use rising_revenant::fortifications::{Fortification, Fortifications, FortificationStorageTrait};
use tokens::erc20::interfaces::{IERC20Dispatcher, IERC20DispatcherTrait};


#[generate_trait]
impl FortificationImpl of FortificationMintTrait {
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
                IERC20Dispatcher { contract_address: *addresses.at(i) }
                    .mint_to(recipient, (*amounts.at(i)).into());
            };
    }
}
