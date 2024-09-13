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
