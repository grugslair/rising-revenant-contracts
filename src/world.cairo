use starknet::{get_caller_address, ContractAddress, storage_read_syscall};
use dojo::{
    world::{WorldStorage, IWorldDispatcher, IWorldDispatcherTrait}, model::ModelStorage,
    contract::{IContractDispatcherTrait, IContractDispatcher}
};
use rising_revenant::hash::hash_value;

const WORLD_STORAGE_ADDRESS: felt252 =
    0x01704e5494cfadd87ce405d38a662ae6a1d354612ea0ebdc9fefdeb969065774;

fn get_default_namespace() -> @ByteArray {
    @"rising_revenant"
}

#[generate_trait]
impl WorldImpl of WorldTrait {
    fn assert_caller_is_creator(self: @WorldStorage) -> ContractAddress {
        let caller = get_caller_address();
        assert((*self.dispatcher).is_owner(0, caller), 'Not Admin');
        caller
    }
    fn assert_caller_is_admin(self: @WorldStorage, selector_hash: felt252) -> ContractAddress {
        let caller = get_caller_address();
        assert((*self.dispatcher).is_owner(selector_hash, caller), 'Not Admin');
        caller
    }
    fn uuid(ref self: WorldStorage) -> felt252 {
        let mut value: UUID = self.read_model(0);
        value.value += 1;
        self.write_model(@value);
        hash_value(('uuid', value.value))
    }
}


fn default_namespace() -> @ByteArray {
    @"rising_revenant"
}


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct UUID {
    #[key]
    id: felt252,
    value: felt252,
}
