use core::integer::u128_safe_divmod;
use rising_revenant::core::ToNonZero;

trait SeedProbability {
    fn get_outcome<T, +Into<T, u128>>(ref self: u128, scale: NonZero<u128>, probability: T) -> bool;
    fn get_value(ref self: u128, scale: NonZero<u128>) -> u128;
    fn split_value(ref self: u128, value: u128) -> (u128, u128);
}

impl SeedProbabilityImpl of SeedProbability {
    fn get_outcome<T, +Into<T, u128>>(
        ref self: u128, scale: NonZero<u128>, probability: T,
    ) -> bool {
        let (seed, value) = u128_safe_divmod(self, scale);
        self = seed;
        value < probability.into()
    }

    fn get_value(ref self: u128, scale: NonZero<u128>) -> u128 {
        if scale == 1 {
            return 0;
        };
        let (seed, value) = u128_safe_divmod(self, scale);
        self = seed;
        value
    }
    fn split_value(ref self: u128, value: u128) -> (u128, u128) {
        if value.is_zero() {
            return (0, 0);
        };
        let split = self.get_value((value + 1).non_zero());
        (split, value - split)
    }
}
