use rising_revenant::addresses::{AddressSelectorTrait};

#[derive(Copy, Drop, Serde, PartialEq)]
enum Fortification {
    Palisade,
    Trench,
    Wall,
    Basement,
}

#[derive(Copy, Drop, Serde)]
struct Fortifications {
    palisades: u128,
    trenches: u128,
    walls: u128,
    basements: u128,
}

impl FortificationIntoFelt252 of Into<Fortification, felt252> {
    fn into(self: Fortification) -> felt252 {
        match self {
            Fortification::Palisade => 'palisade',
            Fortification::Trench => 'trench',
            Fortification::Wall => 'wall',
            Fortification::Basement => 'basement',
        }
    }
}


impl FortificationAddressSelector of AddressSelectorTrait<Fortification> {
    fn get_address_selector(self: @Fortification) -> felt252 {
        match *self {
            Fortification::Palisade => 'erc20-palisade',
            Fortification::Trench => 'erc20-trench',
            Fortification::Wall => 'erc20-wall',
            Fortification::Basement => 'erc20-basement',
        }
    }
}

