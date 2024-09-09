
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::utils::felt252_to_u128;

use super::models::CarePackage;




trait CarePackageTrait {
    fn receive_random_words(
        ref world: IWorldDispatcher,
        requestor_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>,
        calldata: Array<felt252>
    );
}

impl CarePackageImpl of CarePackageTrait {
    fn receive_random_words(
        ref world: IWorldDispatcher,
        requestor_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>,
        mut calldata: Array<felt252>
    ) {
        let randomness = *random_words.at(0);
        loop {
            let care_package = match calldata.pop_front() {
                Option::Some(token_id_felt252) => {
                    let rarity = (Into::<felt252, u256>::into(randomness).low %4).into();
                    let token_id = token_id_felt252.try_into().unwrap();
                    CarePackage{token_id, rarity};
                },
                Option::None => {
                    break;
                }
            };
        };
    }
}