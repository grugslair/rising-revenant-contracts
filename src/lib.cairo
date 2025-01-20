mod world;
mod core;
mod utils;
mod hash;

mod finance;
mod fixed;
mod vrgda;
mod contribution;
mod map;
mod address_selectors;

// mod market;

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
    use models::{Rarity, N_RARITIES, CarePackageStorage, CARE_PACKAGE_CLASS_HASH_SELECTOR};
    use token::{ICarePackageDispatcher, ICarePackageDispatcherTrait};
    use systems::{CarePackageTrait};
}
mod game {
    mod models;
    mod systems;
    mod contract;
    use models::{
        GamePhase, GamePhases, GamePhasesTrait, WinnerTrait, Winner, GameName, GameStorage
    };
    use systems::{GameTrait};
}
mod fortifications {
    mod models;
    mod storage;
    mod systems;
    use models::{Fortification, Fortifications, FortificationTrait, FortificationsTrait};
    use storage::{FortificationStorageTrait};
    use systems::FortificationMintTrait;
}
mod world_events {
    mod contract;
    mod models;
    mod systems;

    use models::{WorldEventType, WorldEvent};
    use systems::{WorldEventTrait};
}
mod outposts {
    mod models;
    mod systems;
    mod token;
    mod contract;

    use models::{Outpost};
    use systems::{OutpostTrait};
    use token::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait};
}
mod jackpot {
    mod models;
    mod systems;
    mod contract;

    use systems::{JackpotTrait};
    use models::{Claimant, JackpotStorage};
    use contract::{IJackpot, IJackpotDispatcher, IJackpotDispatcherTrait};
}
mod debris {}

mod vrf;

use permissions::Permissions;
use addresses::AddressBook;


#[cfg(test)]
mod tests;

