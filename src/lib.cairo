mod contribution;
mod core;

mod fixed;
mod hash;
mod map;
mod seed;
mod utils;
mod vrgda;
mod world;

// mod market;
mod permissions {
    mod models;
    mod systems;
    use models::{Permission, PermissionStorage};
    use systems::{GamePermissions};
}

mod care_packages {
    mod contract;
    mod models;
    mod systems;
    use models::{
        CARE_PACKAGE_CLASS_HASH_SELECTOR, CarePackage, CarePackageMarketTrait, CarePackageStorage,
        N_RARITIES, Rarity,
    };
    use systems::{CarePackageTrait, get_rarity};
}
mod game {
    mod contract;
    mod models;
    mod systems;
    use models::{ClassHashVariant, GameName, GamePhase, GamePhases, GameStorage, Winner};
    use systems::{GameTrait};
}
mod fortifications {
    mod models;
    mod systems;
    use models::{
        Fortification, FortificationStorage, FortificationTokens, FortificationTrait,
        Fortifications, FortificationsTrait,
    };
    use systems::FortificationTokenTrait;
}
mod world_events {
    mod contract;
    mod models;
    mod systems;

    use models::{
        CurrentEvent, LastEventOfType, NUM_WORLD_EVENTS, WorldEvent, WorldEventEffectTrait,
        WorldEventSetup, WorldEventSetupTrait, WorldEventStorage, WorldEventType,
    };
    use systems::{WorldEventTrait};
}
mod outposts {
    mod contract;
    mod models;
    mod systems;

    use models::{Outpost, OutpostStorage};
    use systems::{OutpostTrait};
}
mod game_pot {
    mod contract;
    mod models;
    mod systems;
    use models::{GamePotStorage};

    use systems::{GamePotTrait};
    // use contract::{IGamePot, IGamePotDispatcher, IGamePotDispatcherTrait};
}
mod debris {
    mod models;
    mod systems;

    use models::{Debris, DebrisStorage};
    use systems::{DebrisTrait};
}

mod tokens {
    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
    use super::erc20_mintable_burnable::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait,
        deploy_erc20_mintable_burnable, erc20_balance_of, erc20_burn_from, erc20_mint,
        erc20_transfer, erc20_transfer_from,
    };
    use super::erc721_mintable::{
        IERC721MintableDispatcher, IERC721MintableDispatcherTrait, deploy_erc721_mintable,
        erc721_mint, erc721_owner_of,
    };
}
mod a_contract;
mod erc20_mintable_burnable;
mod erc20_rr_lords;
mod erc721_mintable;

#[cfg(test)]
mod tests;

mod vrf;

