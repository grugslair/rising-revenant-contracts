mod world;
mod core;
mod utils;

mod finance;
mod fixed;
mod vrgda;
mod contribution;
mod map;
mod address_selectors;
mod hash;
mod market;

mod addresses {
    mod systems;
    mod contract;

    use systems::{AddressBook, AddressSelectorTrait, GetDispatcher};
}

mod permissions {
    mod models;
    mod contract;
    mod systems;
    use models::{Permissions};
    use systems::{HasPermissions, AssertPermissions};
}

mod care_packages {
    mod token;
    mod systems;
    mod models;
    mod contract;
    use rr_tokens::care_packages::{Rarity, N_RARITIES};
    use token::{ICarePackageTokenDispatcher, ICarePackageTokenDispatcherTrait};
}
mod game {
    mod models;
    mod systems;
    mod contract;

    use models::{GamePhase, GamePhases, GamePhasesTrait, WinnerTrait, Winner};
    use systems::{GameTrait};
}
mod fortifications {
    mod models;

    use models::{Fortification, Fortifications, FortificationAttributes, FortificationsTrait};
}
mod world_events {
    mod contract;
    mod models;
    mod systems;

    use models::{WorldEventType};
    use systems::{WorldEventTrait};
}
mod outposts {
    mod models;
    mod systems;
    mod token;
    mod contract;

    use models::{Outpost, OutpostModels};
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

mod vrf;

use permissions::Permissions;
use addresses::AddressBook;


#[cfg(test)]
mod tests;

