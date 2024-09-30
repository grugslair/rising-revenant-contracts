use starknet::ContractAddress;

#[starknet::interface]
trait IVrfProvider<TContractState> {
    fn request_random(
        ref self: TContractState, consumer: ContractAddress, key: felt252, as_caller: bool,
    ) -> felt252;

    fn consume_random(ref self: TContractState, caller: ContractAddress, key: felt252) -> felt252;

    fn get_random(self: @TContractState, seed: felt252) -> felt252;

    fn get_seed_for_call(self: @TContractState, caller: ContractAddress, key: felt252,) -> felt252;

    fn get_status(self: @TContractState, caller: ContractAddress, key: felt252) -> RequestStatus;

    fn is_submitted(self: @TContractState, seed: felt252) -> bool;

    fn is_consumed(self: @TContractState, seed: felt252) -> bool;
}
