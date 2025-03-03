use rising_revenant::care_packages::models::Rarity;
use starknet::ContractAddress;

#[derive(Drop, Serde)]
struct CarePackageSold {
    game_id: felt252,
    token_id: felt252,
    rarity: Rarity,
    timestamp: u64,
    price: u256,
    buyer: ContractAddress,
}

#[starknet::interface]
trait ITest<TContractState> {
    fn name(self: @TContractState) -> ByteArray;
}

#[starknet::contract]
mod a_contract {
    use super::CarePackageSold;
    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState, model: CarePackageSold) -> felt252 {
        0
    }
}
