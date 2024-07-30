use cubit::f128::types::fixed::{Fixed, FixedTrait, ONE_u128};

use risingrevenant::constants::{
    DEMIDECIMAL_MULTIPLIER, DEMIDECIMAL_MULTIPLIER_128, DECIMAL_MULTIPLIER
};

const ONE_u256: u256 = 18446744073709551616_u256; // 2 ** 64

// Currency can be in u32, u128, or u256 these represent different decimal representations:
// u32 has no decimals so   1¤ = 1 u32 
// u128 is to 9 dp so       1¤ = 1_000_000_000 u128
// u256 is to 18 dp so      1¤ = 1_000_000_000_000_000_000 u256

trait CurrencyTrait<T1, T2> {
    fn convert(self: T1) -> T2;
}


// impl Convert32To32Impl of CurrencyTrait<u32, u32> {
//     fn convert(self: u32) -> u32 {
//         self
//     }
// }

// impl Convert32To128Impl of CurrencyTrait<u32, u128> {
//     fn convert(self: u32) -> u128 {
//         self.into() * DEMIDECIMAL_MULTIPLIER_128
//     }
// }

// impl Convert32To256Impl of CurrencyTrait<u32, u256> {
//     fn convert(self: u32) -> u256 {
//         self.into() * DECIMAL_MULTIPLIER
//     }
// }

// impl Convert32ToFixedImpl of CurrencyTrait<u32, Fixed> {
//     fn convert(self: u32) -> Fixed {
//         FixedTrait::new_unscaled(self.into(), false)
//     }
// }

// impl Convert128To32Impl of CurrencyTrait<u128, u32> {
//     fn convert(self: u128) -> u32 {
//         (self / DEMIDECIMAL_MULTIPLIER_128).try_into().unwrap()
//     }
// }

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

impl Convert128ToFixedImpl of CurrencyTrait<u128, Fixed> {
    fn convert(self: u128) -> Fixed {
        FixedTrait::new(
            (self.into() * ONE_u256 / DEMIDECIMAL_MULTIPLIER).try_into().unwrap(), false
        )
    }
}


// impl Convert256To32Impl of CurrencyTrait<u256, u32> {
//     fn convert(self: u256) -> u32 {
//         (self / DECIMAL_MULTIPLIER).try_into().unwrap()
//     }
// }

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

impl Convert256ToFixedImpl of CurrencyTrait<u256, Fixed> {
    fn convert(self: u256) -> Fixed {
        FixedTrait::new((self * ONE_u256 / DECIMAL_MULTIPLIER).try_into().unwrap(), false)
    }
}


// impl ConvertFixedTo32Impl of CurrencyTrait<Fixed, u32> {
//     fn convert(self: Fixed) -> u32 {
//         self.try_into().unwrap()
//     }
// }

impl ConvertFixedTo128Impl of CurrencyTrait<Fixed, u128> {
    fn convert(self: Fixed) -> u128 {
        (self.mag.into() * DEMIDECIMAL_MULTIPLIER / ONE_u256).try_into().unwrap()
    }
}

impl ConvertFixedTo256Impl of CurrencyTrait<Fixed, u256> {
    fn convert(self: Fixed) -> u256 {
        (self.mag.into() * DECIMAL_MULTIPLIER / ONE_u256).try_into().unwrap()
    }
}

impl ConvertFixedToFixedImpl of CurrencyTrait<Fixed, Fixed> {
    fn convert(self: Fixed) -> Fixed {
        self
    }
}
