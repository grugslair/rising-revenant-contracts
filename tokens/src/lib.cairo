mod care_packages {
    mod interface;
    mod models;
    use super::care_packages::{
        interface::{ICarePackageDispatcher, ICarePackageDispatcherTrait},
        models::{Rarity, N_RARITIES}
    };
}
mod erc721_enumerable {
    mod interface;
}
