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
    mod systems;
    use models::{PermissionStorage, Permission};
    use systems::{GamePermissions};
}

mod care_packages {
    // mod token;
    mod systems;
    mod models;
    mod contract;
    use models::{
        CarePackage, Rarity, N_RARITIES, CarePackageStorage, CARE_PACKAGE_CLASS_HASH_SELECTOR,
        CarePackageMarketTrait,
    };
    // use token::{ICarePackageDispatcher, ICarePackageDispatcherTrait};
    use systems::{CarePackageTrait, get_rarity};
}
mod game {
    mod models;
    mod systems;
    mod contract;
    use models::{
        GamePhase, GamePhases, GamePhasesTrait, Winner, GameName, GameStorage, ClassHashVariant,
        GameWallet,
    };
    use systems::{GameTrait};
}
mod fortifications {
    mod models;
    mod systems;
    use models::{
        Fortification, Fortifications, FortificationTrait, FortificationsTrait, FortificationTokens,
        FORTIFICATION_CLASS_HASH_SELECTOR, FortificationStorage,
    };
    use systems::FortificationTokenTrait;
}
mod world_events {
    mod contract;
    mod models;
    mod systems;

    use models::{
        CurrentEvent, WorldEventType, WorldEvent, WorldEventSetup, WorldEventStorage,
        NUM_WORLD_EVENTS, LastEventOfType, WorldEventSetupTrait, WorldEventEffectTrait,
    };
    use systems::{WorldEventTrait};
}
mod outposts {
    mod models;
    mod systems;
    mod contract;

    use models::{Outpost, OutpostStorage};
    use systems::{OutpostTrait};
}
mod jackpot {
    mod models;
    mod systems;
    // mod contract;

    use systems::{JackpotTrait};
    use models::{JackpotStorage};
    // use contract::{IJackpot, IJackpotDispatcher, IJackpotDispatcherTrait};
}
mod debris {}

mod tokens {
    use super::erc20_mintable_burnable::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait,
        deploy_erc20_mintable_burnable, erc20_mint, erc20_burn_from, erc20_transfer,
        erc20_transfer_from, erc20_balance_of,
    };
    use super::erc721_mintable::{
        IERC721MintableDispatcher, IERC721MintableDispatcherTrait, deploy_erc721_mintable,
        erc721_mint, erc721_owner_of,
    };

    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
}

mod vrf;
mod erc20_mintable_burnable;
mod erc721_mintable;
mod game_pot;

#[cfg(test)]
mod tests;

