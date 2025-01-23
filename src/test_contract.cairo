#[starknet::contract]
mod test_contract {
    #[storage]
    struct Storage {}

    #[generate_trait]
    #[abi(per_item)]
    impl ExternalImpl of ExternalTrait {
        #[external(v0)]
        fn test(self: @ContractState) -> felt252 {
            1
        }
    }
}
