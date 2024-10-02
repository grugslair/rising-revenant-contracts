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
        loop {
            if places == 0 {
                break;
            }
            value *= 10;
            places -= 1;
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
