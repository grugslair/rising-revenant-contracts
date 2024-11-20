use core::num::traits::Bounded;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{addresses::{AddressSelectorTrait}, world_events::models::WorldEventType};

/// Represents different types of fortifications.
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Fortification {
    /// A palisade fortification.
    Palisade,
    /// A trench fortification.
    Trench,
    /// A wall fortification.
    Wall,
    /// A basement fortification.
    Basement,
}

/// Holds the count of each type of fortification.
#[derive(Copy, Drop, Serde, IntrospectPacked, Default)]
struct Fortifications {
    palisades: u64,
    trenches: u64,
    walls: u64,
    basements: u64,
}

impl FortificationsIntoArray of Into<Fortifications, Array<u64>> {
    /// Converts a `Fortifications` instance into an array of `u64`.
    fn into(self: Fortifications) -> Array<u64> {
        array![self.palisades, self.trenches, self.walls, self.basements]
    }
}


impl FortificationIntoFelt252 of Into<Fortification, felt252> {
    /// Converts a `Fortification` enum variant into a `felt252` identifier.
    fn into(self: Fortification) -> felt252 {
        match self {
            Fortification::Palisade => 'palisade',
            Fortification::Trench => 'trench',
            Fortification::Wall => 'wall',
            Fortification::Basement => 'basement',
        }
    }
}

impl AddEqFortifications of core::ops::AddAssign<Fortifications, Fortifications> {
    /// Adds the values of another `Fortifications` instance to this one.
    fn add_assign(ref self: Fortifications, rhs: Fortifications) {
        self.palisades += rhs.palisades;
        self.trenches += rhs.trenches;
        self.walls += rhs.walls;
        self.basements += rhs.basements;
    }
}

impl MulFortifications of Mul<Fortifications> {
    /// Multiplies the values of two `Fortifications` instances.
    #[inline(always)]
    fn mul(lhs: Fortifications, rhs: Fortifications) -> Fortifications {
        Fortifications {
            palisades: lhs.palisades * rhs.palisades,
            trenches: lhs.trenches * rhs.trenches,
            walls: lhs.walls * rhs.walls,
            basements: lhs.basements * rhs.basements,
        }
    }
}

impl U64IntoFortifications of Into<u64, Fortifications> {
    /// Converts a `u64` value into a `Fortifications` instance with all fields set to the given
    /// value.
    fn into(self: u64) -> Fortifications {
        Fortifications { palisades: self, trenches: self, walls: self, basements: self, }
    }
}

#[generate_trait]
impl FortificationsImpl of FortificationsTrait {
    /// Adds a specified amount to a specific type of fortification.
    fn add(ref self: Fortifications, fortification_type: Fortification, amount: u64) {
        match fortification_type {
            Fortification::Palisade => { self.palisades += amount },
            Fortification::Trench => { self.trenches += amount },
            Fortification::Wall => { self.walls += amount },
            Fortification::Basement => { self.basements += amount },
        };
    }

    /// Sums up all the fortifications.
    fn sum(self: @Fortifications) -> u64 {
        *self.palisades + *self.trenches + *self.walls + *self.basements
    }

    /// Returns an array of all fortification types.
    fn array() -> Array<Fortification> {
        array![
            Fortification::Palisade,
            Fortification::Trench,
            Fortification::Wall,
            Fortification::Basement,
        ]
    }
}

impl FortificationAddressSelector of AddressSelectorTrait<Fortification> {
    /// Converts the fortification enum to the address selector to get the contract address of the
    /// ERC.
    fn get_address_selector(self: @Fortification) -> felt252 {
        match *self {
            Fortification::Palisade => 'erc20-palisade',
            Fortification::Trench => 'erc20-trench',
            Fortification::Wall => 'erc20-wall',
            Fortification::Basement => 'erc20-basement',
        }
    }
}

