mod world;
mod core;
mod utils;

mod finance;
mod fixed;
mod vrgda;
mod contribution;
mod map;
mod address_selectors;
mod addresses {
    mod systems;
    // mod contract;

    use systems::{AddressBook, AddressSelectorTrait, GetDispatcher};
}

mod permissions {
    mod models;
    // mod contract;
}

mod care_packages {
    mod token;
    mod systems;
    mod models;
    // mod contract;

    use models::{Rarity, N_RARITIES};
    use token::{ICarePackageTokenDispatcher, ICarePackageTokenDispatcherTrait};
}
mod market;
mod game {
    mod models;
    mod systems;

    use models::{GamePhase, GamePhases, GamePhasesTrait, WinnerTrait};
    use systems::{GameTrait};
}
mod fortifications {
    mod models;
    mod systems;

    use models::{Fortification, Fortifications, FortificationAttributes, FortificationsTrait};
}
mod world_events {
    // mod contract;
    mod models;
    mod systems;
}
mod outposts {
    mod models;
    mod systems;
    mod token;

    use models::{Outpost};
    use systems::{OutpostTrait};
    use token::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait};
}
mod jackpot {
    mod models;
    mod systems;
    mod contract;

    use systems::{JackpotTrait};
    use models::{Claimant};
}
mod debris {}

use permissions::models::Permissions;

#[cfg(test)]
mod tests;

