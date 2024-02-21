use option::OptionTrait;
use traits::{Into, TryInto, BitNot};

use starknet::{ContractAddress, get_contract_address};


#[derive(Copy, Drop, Serde)]
struct Random {
    seed: felt252,
    nonce: usize,
}

#[generate_trait]
impl RandomImpl of RandomTrait {
    // one instance by contract, then passed by ref to sub fns
    fn new() -> Random {
        Random { seed: seed(get_contract_address()), nonce: 0 }
    }

    fn next_seed(ref self: Random) -> felt252 {
        self.nonce += 1;
        self.seed = pedersen::pedersen(self.seed, self.nonce.into());
        self.seed
    }

    fn next<T, +Into<T, u256>, +Into<u8, T>, +TryInto<u256, T>, +BitNot<T>>(ref self: Random) -> T {
        let seed: u256 = self.next_seed().into();
        let mask: T = BitNot::bitnot(0_u8.into());
        (mask.into() & seed).try_into().unwrap()
    }

    fn next_capped<T, +Into<T, u256>, +TryInto<u256, T>, +Drop<T>>(ref self: Random, cap: T) -> T {
        let seed: u256 = self.next_seed().into();
        (seed % cap.into()).try_into().unwrap()
    }
}

fn seed(salt: ContractAddress) -> felt252 {
    pedersen::pedersen(starknet::get_tx_info().unbox().transaction_hash, salt.into())
}

const U64: u128 = 0xffffffffffffffff_u128; // 2**64-1 

fn rotl(x: u128, k: u128) -> u128 {
    assert(k <= 64, 'invalid k');
    // (x << k) | (x >> (64 - k))
    (x * pow2(k)) | rshift(x, 64 - k)
}

// https://xoshiro.di.unimi.it/splitmix64.c
fn splitmix(x: u128) -> u128 {
    let z = (x + 0x9e3779b97f4a7c15) & U64;
    let z = ((z ^ rshift(z, 30)) * 0xbf58476d1ce4e5b9) & U64;
    let z = ((z ^ rshift(z, 27)) * 0x94d049bb133111eb) & U64;
    (z ^ rshift(z, 31)) & U64
}

fn rshift(v: u128, b: u128) -> u128 {
    v / pow2(b)
}

fn pow2(mut i: u128) -> u128 {
    let mut p = 1;
    loop {
        if i == 0 {
            break p;
        }
        p *= 2;
        i -= 1;
    }
}

