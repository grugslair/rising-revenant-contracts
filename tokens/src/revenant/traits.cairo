#[derive(Drop, Serde, Copy, PartialEq)]
enum Element {
    Fire,
    Water,
    Earth,
    Air,
}


#[derive(Drop, Serde, Copy, PartialEq)]
enum Honor{
    Lawful,
    Neutral,
    Chaotic,
}

#[derive(Drop, Serde, Copy, PartialEq)]
enum Morality{
    Good,
    Neutral,
    Evil
}

#[derive(Drop, Serde, Copy, PartialEq)]
enum Order{
    Power,
    Giants,
    Titans,
    Skill,
    Perfection,
    Brilliance,
    Enlightenment,
    Protection,
    Anger,
    Rage,
    Fury,
    Vitriol,
    Fox,
    Detection,
    Reflection,
    Twins,
}


#[derive(Drop, Serde, Copy, PartialEq)]
enum HomeCave {
    Grugs,
    DevilsArse,
    Eisriesenwelt,
    Waitomo,
    Skocjan,
    OfTheCrystals,
    ReedFlute,
    GrottaGigante,
    Mammoth,
    Fingals,
    SonDoong
}

impl U8IntoElement of Into<u8, Element> {
    fn into(self: u8) -> Element {
        match self {
            0 => Element::Fire,
            1 => Element::Water,
            2 => Element::Earth,
            3 => Element::Air,
            _ => panic!("Out of range"),
        }
    }
}

impl U8IntoHonor of Into<u8, Honor> {
    fn into(self: u8) -> Honor {
        match self {
            0 => Honor::Lawful,
            1 => Honor::Neutral,
            2 => Honor::Chaotic,
            _ => panic!("Out of range"),
        }
    }
}

impl U8IntoMorality of Into<u8, Morality> {
    fn into(self: u8) -> Morality {
        match self {
            0 => Morality::Good,
            1 => Morality::Neutral,
            2 => Morality::Evil,
            _ => panic!("Out of range"),
        }
    }
}


impl U8IntoOrder of Into<u8, Order> {
    fn into(self: u8) -> Order {
        match self {
            0 => Order::Power,
            1 => Order::Giants,
            2 => Order::Titans,
            3 => Order::Skill,
            4 => Order::Perfection,
            5 => Order::Brilliance,
            6 => Order::Enlightenment,
            7 => Order::Protection,
            8 => Order::Anger,
            9 => Order::Rage,
            10 => Order::Fury,
            11 => Order::Vitriol,
            12 => Order::Fox,
            13 => Order::Detection,
            14 => Order::Reflection,
            15 => Order::Twins,
            _ => panic!("Out of range"),
        }
    }
}



impl U8IntoHomeCave of Into<u8, HomeCave> {
    fn into(self: u8) -> HomeCave {
        match self {
            0 => HomeCave::DevilsArse,
            1 => HomeCave::Eisriesenwelt,
            2 => HomeCave::Waitomo,
            3 => HomeCave::Skocjan,
            4 => HomeCave::OfTheCrystals,
            5 => HomeCave::ReedFlute,
            6 => HomeCave::GrottaGigante,
            7 => HomeCave::Mammoth,
            8 => HomeCave::Fingals,
            9 => HomeCave::SonDoong,
            _ => panic!("Out of range"),
        }
    }
}


