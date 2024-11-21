use core::{cmp::min, poseidon::HashState, num::traits::Bounded};
use dojo::{world::WorldStorage, model::ModelStorage};
use cubit::f128::{Fixed, FixedTrait};
use rising_revenant::{
    addresses::{AddressSelectorTrait}, world_events::models::WorldEventType, core::BoundedT,
    hash::UpdateHashToU128
};

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

    /// Applies destruction to fortifications based on mortality rates
    /// # Arguments
    /// * `mortalities` - The mortality rates for each fortification type
    /// * `hash_state` - Random state for destruction calculations
    fn apply_destruction(
        ref self: Fortifications, mortalities: Fortifications, hash_state: HashState
    ) {
        self
            .palisades -=
                min(
                    self.palisades,
                    fortifications_destroyed(
                        mortalities.palisades, hash_state, Fortification::Palisade
                    )
                );
        self
            .trenches -=
                min(
                    self.trenches,
                    fortifications_destroyed(
                        mortalities.trenches, hash_state, Fortification::Trench
                    )
                );
        self
            .walls -=
                min(
                    self.walls,
                    fortifications_destroyed(mortalities.walls, hash_state, Fortification::Wall)
                );
        self
            .basements -=
                min(
                    self.basements,
                    fortifications_destroyed(
                        mortalities.basements, hash_state, Fortification::Basement
                    )
                );
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

impl FortificationHashImpl = core::hash::into_felt252_based::HashImpl<Fortification, HashState>;
/// Calculates how many fortifications are destroyed
/// # Arguments
/// * `probability` - Chance of destruction (0-100%)
/// * `hash_state` - Random state for calculations
/// * `fortification` - Type of fortification
/// # Returns
/// * Number of fortifications destroyed
fn fortifications_destroyed(
    probability: u64, hash_state: HashState, fortification: Fortification
) -> u64 {
    if probability == 0 {
        return 0;
    };
    if probability == Bounded::MAX {
        return Bounded::MAX;
    };
    let randomness = FixedTrait::new(
        hash_state.update_to_u128(fortification) & BoundedT::<u64, u128>::max() + 1, false
    );
    let probability = FixedTrait::new(probability.into(), false);
    (randomness.ln() / probability.ln()).try_into().unwrap()
}
