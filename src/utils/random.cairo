use core::poseidon::{PoseidonTrait, HashState, HashStateTrait};
use starknet::{ContractAddress, get_contract_address, get_block_timestamp};
use core::integer::BoundedInt;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Model, Copy, Drop, Serde)]
struct Seed {
    #[key]
    id: bool,
    seed: felt252,
}

#[derive(Copy, Drop)]
struct RandomGenerator {
    seed: HashState,
    nonce: felt252,
}

#[generate_trait]
impl RandomImpl of RandomTrait {
    fn random_from_chain(self: IWorldDispatcher) -> felt252 {
        let mut seed: Seed = get!(self, true, Seed);
        let hash = PoseidonTrait::new()
            .update(get_block_timestamp().into())
            .update(starknet::get_tx_info().unbox().transaction_hash)
            .finalize();
        seed.seed = hash;
        set!(self, (seed,));
        hash
    }
    fn new_generator(seed: felt252) -> RandomGenerator {
        RandomGenerator { seed: PoseidonTrait::new().update(seed), nonce: 0 }
    }
    fn new_generator_from_chain(self: IWorldDispatcher) -> RandomGenerator {
        RandomTrait::new_generator(self.random_from_chain())
    }

    fn next_felt(ref self: RandomGenerator) -> felt252 {
        self.nonce += 1;
        self.seed.update(self.nonce).finalize()
    }

    fn next<T, +BoundedInt<T>, +Into<T, u256>, +TryInto<u256, T>>(ref self: RandomGenerator) -> T {
        let hash = self.next_felt();
        let mask: u256 = BoundedInt::<T>::max().into();
        (mask & hash.into()).try_into().unwrap()
    }

    fn next_capped<T, +Into<T, u256>, +TryInto<u256, T>, +Drop<T>>(
        ref self: RandomGenerator, cap: T
    ) -> T {
        let hash: u256 = self.next_felt().into();
        (hash % cap.into()).try_into().unwrap()
    }
}

