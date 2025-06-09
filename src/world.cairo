use dojo::{
    contract::{IContractDispatcher, IContractDispatcherTrait}, model::ModelStorage,
    world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait},
};

// use dojo::{utils::deserialize_unwrap, model::{Model, ModelPtr, ModelIndex}, meta::Introspect};
use rising_revenant::hash::hash_value;
use starknet::{ContractAddress, get_caller_address, storage_read_syscall};

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
    fn assert_caller_is_writer(self: @WorldStorage, selector_hash: felt252) -> ContractAddress {
        let caller = get_caller_address();
        assert((*self.dispatcher).is_writer(selector_hash, caller), 'Not Writer');
        caller
    }
    fn get_contract_address(self: @WorldStorage, contract_name: ByteArray) -> ContractAddress {
        match self.dns(@contract_name) {
            Option::Some((address, _)) => address,
            Option::None => panic!("GamePot contract not deployed"),
        }
    }
}

trait WorldTrait<T> {
    fn storage(self: @T, namespace_hash: felt252) -> WorldStorage;
    fn default_storage(self: @T) -> WorldStorage {
        Self::storage(self, DEFAULT_NAMESPACE_HASH)
    }
}

#[generate_trait]
impl WorldModelImpl<S, M, +WorldTrait<S>, +Drop<S>, +Model<M>, +Drop<M>> of NsModelStorage<S, M> {
    fn write_ns_model(ref self: S, namespace: felt252, model: @M) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_model(ref storage, model);
    }
    fn write_ns_models(ref self: S, namespace: felt252, models: Span<@M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_models(ref storage, models);
    }
    fn read_ns_model<K, +Drop<K>, +Serde<K>>(self: @S, namespace: felt252, keys: K) -> M {
        ModelStorageWorldStorageImpl::<M>::read_model(@self.storage(namespace), keys)
    }
    fn read_ns_models<K, +Drop<K>, +Serde<K>>(
        self: @S, namespace: felt252, keys: Span<K>,
    ) -> Array<M> {
        ModelStorageWorldStorageImpl::<M>::read_models(@self.storage(namespace), keys)
    }
    fn erase_ns_model(ref self: S, namespace: felt252, model: @M) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_model(ref storage, model);
    }
    fn erase_ns_models(ref self: S, namespace: felt252, models: Span<@M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_models(ref storage, models);
    }
    fn erase_ns_model_ptr(ref self: S, namespace: felt252, ptr: ModelPtr<M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_model_ptr(ref storage, ptr);
    }
    fn erase_ns_models_ptrs(ref self: S, namespace: felt252, ptrs: Span<ModelPtr<M>>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_models_ptrs(ref storage, ptrs);
    }
    fn read_ns_member<T, +Serde<T>>(
        self: @S, namespace: felt252, ptr: ModelPtr<M>, field_selector: felt252,
    ) -> T {
        ModelStorageWorldStorageImpl::<
            M,
        >::read_member(@self.storage(namespace), ptr, field_selector)
    }
    fn read_ns_member_of_models<T, +Serde<T>, +Drop<T>>(
        self: @S, namespace: felt252, ptrs: Span<ModelPtr<M>>, field_selector: felt252,
    ) -> Array<T> {
        ModelStorageWorldStorageImpl::<
            M,
        >::read_member_of_models(@self.storage(namespace), ptrs, field_selector)
    }
    fn write_ns_member<T, +Serde<T>, +Drop<T>>(
        ref self: S, namespace: felt252, ptr: ModelPtr<M>, field_selector: felt252, value: T,
    ) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_member(ref storage, ptr, field_selector, value);
    }
    fn write_ns_member_of_models<T, +Serde<T>, +Drop<T>>(
        ref self: S,
        namespace: felt252,
        ptrs: Span<ModelPtr<M>>,
        field_selector: felt252,
        values: Span<T>,
    ) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<
            M,
        >::write_member_of_models(ref storage, ptrs, field_selector, values);
    }
    fn read_ns_schema<T, +Serde<T>, +Introspect<T>>(
        self: @S, namespace: felt252, ptr: ModelPtr<M>,
    ) -> T {
        ModelStorageWorldStorageImpl::<M>::read_schema(@self.storage(namespace), ptr)
    }
    fn read_ns_schemas<T, +Drop<T>, +Serde<T>, +Introspect<T>>(
        self: @S, namespace: felt252, ptrs: Span<ModelPtr<M>>,
    ) -> Array<T> {
        ModelStorageWorldStorageImpl::<M>::read_schemas(@self.storage(namespace), ptrs)
    }
}

impl IWorldDispatcherWorldImpl of WorldTrait<IWorldDispatcher> {
    fn storage(self: @IWorldDispatcher, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(*self, namespace_hash)
    }
}

impl WorldStorageWorldImpl of WorldTrait<WorldStorage> {
    fn storage(self: @WorldStorage, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(*self.dispatcher, namespace_hash)
    }
}

impl ContractStateWorldImpl<TState, +Drop<TState>, +WorldComponent<TState>> of WorldTrait<TState> {
    fn storage(self: @TState, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(self.get_component().world_dispatcher(), namespace_hash)
    }
}

#[generate_trait]
impl WorldDispatcherImpl<
    TContractState, +WorldComponent<TContractState>,
> of WorldDispatcher<TContractState> {
    fn world_dispatcher(self: @TContractState) -> IWorldDispatcher {
        self.get_component().world_dispatcher()
    }
}

fn default_namespace() -> @ByteArray {
    @"rising_revenant"
}
