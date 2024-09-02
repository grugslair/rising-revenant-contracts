// mod components {
//     mod game;
//     mod outpost;
//     mod player;
//     mod reinforcement;
//     mod trade;
//     mod world_event;
//     mod currency;
// }
// mod constants;
// mod contracts {
//     mod game;
//     mod outpost;
//     mod payment;
//     mod reinforcement;
//     mod trade_reinforcement;
//     mod trade_outpost;
//     mod world_event;
//     mod debris;
// }
// mod defaults;
// mod systems {
//     mod get_set;
//     mod game;
//     mod outpost;
//     mod player;
//     mod trade;
//     mod reinforcement;
//     mod world_event;
//     mod payment;
//     mod position;
// }

// #[cfg(test)]
// mod tests {
//     mod test_contracts;
//     mod reinforcement_test;
//     mod utils;
//     mod erc20;
// }

// mod debris {
//     mod template;
//     mod utils;
//     mod wood;
//     mod stone;
//     mod dirt;
//     mod obsidian;
// }
mod tokens {
    mod erc20 {
        mod core {
            mod contract;
            mod interface;
            mod models;
        }
        use super::erc20::core::{
            interface::{IERC20Core, IERC20CoreDispatcher, IERC20CoreDispatcherTrait},
            models::{ERC20Read}
        };
        // mod internals;
        mod basic;
        mod template;
    }
}
mod permissions {
    mod models;
    mod contract;
}
// mod utils;


