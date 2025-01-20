use cubit::f128::types::fixed::{Fixed, FixedTrait, ONE};


trait FixedToDecimal<T> {
    fn to_decimal(self: @T, places: u8) -> u256;
    fn decimal_to_fixed(self: @u256, places: u8) -> T;
}

// Converts a Fixed to a decimal and vice versa number for use with tokens.
impl FixedU128ToDecimalImpl of FixedToDecimal<Fixed> {
    fn to_decimal(self: @Fixed, mut places: u8) -> u256 {
        assert(!*self.sign, 'Negative value');
        let mut value: u256 = (*self.mag).into();
        for _ in 0..places {
            value *= 10;
        };
        value / ONE.into()
    }

    fn decimal_to_fixed(self: @u256, mut places: u8) -> Fixed {
        let mut pow: u128 = 1;
        loop {
            if places == 0 {
                break;
            }
            pow *= 10;
            places -= 1;
        };
        let value = *self * ONE.into() / pow.into();
        FixedTrait::new(value.try_into().unwrap(), false)
    }
}

#[cfg(test)]
fn test_places() {
    let fixed = FixedTrait::new(100, false);
    let decimal = fixed.to_decimal(2);
    assert(decimal == 10000.into(), "Decimal conversion failed");
    let fixed = FixedTrait::new(100, false);
    let decimal = fixed.to_decimal(3);
    assert(decimal == 100000.into(), "Decimal conversion failed");
    let decimal = 10000.into();
}
