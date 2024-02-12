use box::BoxTrait;
use option::OptionTrait;
use traits::{Into, TryInto};

#[derive(Drop)]
struct Random {
    s0: u128,
    s1: u128
}

trait RandomTrait {
    fn new(seed: felt252) -> Random;

    fn next(ref self: Random) -> u128;
    fn next_u32(ref self: Random, min: u32, max: u32) -> u32;
}

impl RandomImpl of RandomTrait {
    fn new(seed: felt252) -> Random {
        let seed256: u256 = seed.into();
        let s0 = splitmix(seed256.low);
        let s1 = splitmix(s0);

        Random { s0, s1 }
    }

    fn next(ref self: Random) -> u128 {
        let result = (rotl(self.s0 * 5, 7) * 9) & U64;

        let mut s1 = (self.s1 ^ self.s0) & U64;
        let s0 = (rotl(self.s0, 24) ^ s1 ^ (s1 * 65536)) & U64;
        s1 = (rotl(s1, 37) & U64);

        self.s0 = s0;
        self.s1 = s1;

        s0
    }

    fn next_u32(ref self: Random, min: u32, max: u32) -> u32 {
        assert(min < max, 'min should less than max');

        let random_num = self.next();
        let range: u128 = (max - min + 1).into();
        let result = (random_num % range) + min.into();

        result.try_into().unwrap()
    }
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

#[cfg(test)]
mod test {
    use super::RandomImpl;

    #[test]
    #[available_gas(3000000000)]
    fn test_random() {
        let seed = starknet::get_tx_info().unbox().transaction_hash;
        let mut random = RandomImpl::new(seed);

        let mut next = random.next_u32(30, 99);
        assert(next >= 30, 'Wrong random number range');
        assert(next <= 99, 'Wrong random number range');

        next = random.next_u32(12, 29);
        assert(next >= 12, 'Wrong random number range');
        assert(next <= 29, 'Wrong random number range');
    }
}
