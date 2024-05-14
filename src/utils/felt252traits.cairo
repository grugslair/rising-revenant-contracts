use core::traits::BitAnd;

impl BitAndFelt252Impl of BitAnd<felt252> {
    fn bitand(lhs: felt252, rhs: felt252) -> felt252 {
        let lhs_u256: u256 = lhs.into();
        let rhs_u256: u256 = rhs.into();
        (lhs_u256 & rhs_u256).try_into().unwrap()
    }
}
