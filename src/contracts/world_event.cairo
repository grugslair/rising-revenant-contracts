use starknet::ContractAddress;

#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn create(self: @TContractState, game_id: u128);
    fn receive_random_words(
        self: @TContractState,
        requestor_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>,
        calldata: Array<felt252>
    );
}

#[dojo::contract]
mod world_event_actions {
    use core::option::OptionTrait;
    use super::IWorldEventActions;
    use starknet::{get_caller_address, ContractAddress};

    use risingrevenant::{
        components::world_event::{WorldEvent, EventType},
        systems::{game::{GameAction, GameActionTrait}, world_event::{WorldEventTrait}},
        utils::{random::{RandomGenerator, RandomTrait, RandomImpl}, felt252traits::TruncateTrait}
    };


    #[abi(embed_v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn create(self: @ContractState, game_id: u128) {
            let game_action = GameAction { game_id, world: self.world_dispatcher.read() };
            let caller = get_caller_address();
            game_action.assert_is_admin(caller);
        }
        fn receive_random_words(
            self: @ContractState,
            requestor_address: ContractAddress,
            request_id: u64,
            random_words: Span<felt252>,
            calldata: Array<felt252>
        ) {
            let random_word = *random_words.at(0);
            let game_id: u128 = calldata.at(0).try_into().unwrap();
            let game_action = GameAction { game_id, world: self.world_dispatcher.read() };
            game_action.new_random_world_event(random_word);
        }
    }
}
