use starknet::{get_caller_address, ContractAddress};
use dojo::{world::{WorldStorage, Resource}, utils::selector_from_names};

fn get_default_namespace() -> @ByteArray {
    @"rising_revenant"
}

#[generate_trait]
impl WorldImpl of WorldTrait {
    fn assert_caller_is_owner(self: @WorldStorage) {
        self.assert_is_owner(get_caller_address());
    }
    fn assert_is_owner(self: @WorldStorage, caller: ContractAddress) {
        assert((*self).is_owner(0, caller), 'Not Owner');
    }
    fn get_contract_address(
        self: @WorldStorage, gamespace: ByteArray, name: ByteArray
    ) -> ContractAddress {
        match (*self).resource(selector_from_names(@namespace, @name)) {
            Resource::Contract((_, contract_address)) => contract_address,
            _ => panic!("Not a contract")
        }
    }
}
