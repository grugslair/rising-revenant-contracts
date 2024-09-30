mod core;
mod utils;
mod addresses;
mod models;
mod accounts;
mod care_packages {
    use rr_tokens::care_packages::{
        interface::ICarePackageDispatcher, ICarePackageDispatcherTrait, Rarity, N_RARITIES
    };
    mod systems;
    mod contract;
}
mod market;
mod game {
    mod models;
    mod systems;
}
mod fortifications {
    mod models;
    mod systems;
}
mod world_events {
    // mod contract;
    mod models;
    mod systems;
}
mod outposts {
    mod models;
    mod systems;
}


mod debris {}
