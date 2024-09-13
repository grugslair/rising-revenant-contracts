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
// mod care_packages {
//     mod contract;
//     mod models;
//     mod systems;
// }
mod debris {
}
// mod fortifications {
//     mod models;
// }
// mod tokens {
//     // mod erc20 {
//     //     mod core {
//     //         mod contract;
//     //         mod interface;
//     //         mod models;
//     //     }
//     //     use super::erc20::core::{
//     //         interface::{IERC20Core, IERC20CoreDispatcher, IERC20CoreDispatcherTrait},
//     //         models::{ERC20Read}
//     //     };
//     //     mod basic;
//     //     mod template;
//     // }
//     mod erc721 {
//         mod core {
//             mod contract;
//             mod interface;
//             mod models;
//         }
//         mod components {
//             mod basic;
//         }
//         use super::erc721::{
//             core::{
//                 interface::{
//                     IERC721Core, IERC721CoreDispatcher, IERC721CoreDispatcherTrait,
//                     IERC721CoreBasicDispatcher, IERC721CoreBasicDispatcherTrait,
//                     IERC721CoreEnumerableDispatcher, IERC721CoreEnumerableDispatcherTrait
//                 },
//                 models::{ERC721Read}
//             },
//             internals::{
//                 ERC721Event, GetERC721CoreDispatcherTrait, ERC721CoreInternalTrait,
//                 ERC721BasicInternalTrait, ERC721EnumerableInternalTrait
//             },
//         };
//         mod internals;
//         // use super::erc721::internals::GetERC721CoreDispatcherTrait;
//     // mod template;
//     }
// }
// mod dns;
// mod permissions {
//     mod models;
//     mod contract;
// }
mod utils;
mod care_packages{
    use rr_tokens::care_packages::{interface::ICarePackageDispatcher, ICarePackageDispatcherTrait, Rarity};
    mod systems;
    mod contract;
}
mod fortifications{
    mod models;
}

mod addresses;
