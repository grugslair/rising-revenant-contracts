use core::num::traits::Bounded;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{addresses::{AddressSelectorTrait}, world_events::models::WorldEventType};

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Fortification {
    Palisade,
    Trench,
    Wall,
    Basement,
}

#[derive(Copy, Drop, Serde, IntrospectPacked, Default)]
struct Fortifications {
    palisades: u64,
    trenches: u64,
    walls: u64,
    basements: u64,
}

// #[derive(Copy, Drop, Serde, Introspect, Default)]
// struct UXFortifications<
//     T, +Copy<T>, +Drop<T>, +Bounded<T>, +Default<T>, +Serde<T>, +Introspect<T>
// > {
//     palisades: T,
//     trenches: T,
//     walls: T,
//     basements: T,
// }

impl FortificationsIntoArray of Into<Fortifications, Array<u64>> {
    fn into(self: Fortifications) -> Array<u64> {
        array![self.palisades, self.trenches, self.walls, self.basements]
    }
}

#[generate_trait]
impl FortificationAttributesImpl of FortificationAttributesTrait {
    fn get_fortification_attributes(
        self: @WorldStorage, game_id: felt252, event_type: WorldEventType
    ) -> FortificationAttributes {
        self.read_model((game_id, event_type))
    }
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct FortificationAttributes {
    #[key]
    game_id: felt252,
    #[key]
    event_type: WorldEventType,
    efficacy: Fortifications,
    mortalities: Fortifications,
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


impl AddEqFortifications of core::ops::AddAssign<Fortifications, Fortifications> {
    fn add_assign(ref self: Fortifications, rhs: Fortifications) {
        self.palisades += rhs.palisades;
        self.trenches += rhs.trenches;
        self.walls += rhs.walls;
        self.basements += rhs.basements;
    }
}

impl MulFortifications of Mul<Fortifications> {
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
    fn into(self: u64) -> Fortifications {
        Fortifications { palisades: self, trenches: self, walls: self, basements: self, }
    }
}


#[generate_trait]
impl FortificationsImpl of FortificationsTrait {
    fn add(ref self: Fortifications, fortification_type: Fortification, amount: u64) {
        match fortification_type {
            Fortification::Palisade => { self.palisades += amount },
            Fortification::Trench => { self.trenches += amount },
            Fortification::Wall => { self.walls += amount },
            Fortification::Basement => { self.basements += amount },
        };
    }

    fn sum(self: @Fortifications) -> u64 {
        *self.palisades + *self.trenches + *self.walls + *self.basements
    }

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
    fn get_address_selector(self: @Fortification) -> felt252 {
        match *self {
            Fortification::Palisade => 'erc20-palisade',
            Fortification::Trench => 'erc20-trench',
            Fortification::Wall => 'erc20-wall',
            Fortification::Basement => 'erc20-basement',
        }
    }
}

