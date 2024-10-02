use cubit::f128::types::fixed::{Fixed, FixedTrait};
use rising_revenant::fixed::{FixedToDecimal};

#[test]
#[available_gas(3000000000)]
fn test_fixed_into_decimal() {
    let fixed = FixedTrait::new_unscaled(100, false);
    let decimal = fixed.to_decimal(18);
    println!("Fixed: {} Decimal: {}", fixed.mag, decimal);
}

#[test]
#[available_gas(3000000000)]
fn test_decimal_into_fixed() {
    let decimal = 101_000_000_000_000_000_000_u256;
    let fixed: Fixed = decimal.decimal_to_fixed(18);
    let fixed_u128: u128 = fixed.try_into().unwrap();
    println!("Decimal: {} Fixed: {}", decimal, fixed_u128);
}
