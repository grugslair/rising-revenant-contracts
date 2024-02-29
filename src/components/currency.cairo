use risingrevenant::constants::{
    DEMIDECIMAL_MULTIPLIER, DEMIDECIMAL_MULTIPLIER_128, DECIMAL_MULTIPLIER
};

// Currency can be in u32, u128, or u256 these represent different decimal representations:
// u32 has no decimals so   1¤ = 1 u32 
// u128 is to 9 dp so       1¤ = 1_000_000_000 u128
// u256 is to 18 dp so      1¤ = 1_000_000_000_000_000_000 u256

trait CurrencyTrait<T1, T2> {
    fn convert(self: T1) -> T2;
}


impl Convert32To32Impl of CurrencyTrait<u32, u32> {
    fn convert(self: u32) -> u32 {
        self
    }
}

impl Convert32To128Impl of CurrencyTrait<u32, u128> {
    fn convert(self: u32) -> u128 {
        self.into() * DEMIDECIMAL_MULTIPLIER_128
    }
}

impl Convert32To256Impl of CurrencyTrait<u32, u256> {
    fn convert(self: u32) -> u256 {
        self.into() * DECIMAL_MULTIPLIER
    }
}


impl Convert128To32Impl of CurrencyTrait<u128, u32> {
    fn convert(self: u128) -> u32 {
        (self / DEMIDECIMAL_MULTIPLIER_128).try_into().unwrap()
    }
}

impl Convert128To128Impl of CurrencyTrait<u128, u128> {
    fn convert(self: u128) -> u128 {
        self
    }
}

impl Convert128To256Impl of CurrencyTrait<u128, u256> {
    fn convert(self: u128) -> u256 {
        self.into() * DEMIDECIMAL_MULTIPLIER
    }
}


impl Convert256To32Impl of CurrencyTrait<u256, u32> {
    fn convert(self: u256) -> u32 {
        (self / DECIMAL_MULTIPLIER).try_into().unwrap()
    }
}

impl Convert256To128Impl of CurrencyTrait<u256, u128> {
    fn convert(self: u256) -> u128 {
        (self / DEMIDECIMAL_MULTIPLIER).try_into().unwrap()
    }
}

impl Convert256To256Impl of CurrencyTrait<u256, u256> {
    fn convert(self: u256) -> u256 {
        self
    }
}
