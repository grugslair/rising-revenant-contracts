use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn create(self: @TContractState, world: IWorldDispatcher, game_id: u128);
    fn receive_random_words(
        self: @TContractState,
        world: IWorldDispatcher,
        requestor_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>,
        calldata: Array<felt252>
    );
    fn set_eth_address(ref self: TContractState, eth_address: ContractAddress);
    fn set_vrf_address(ref self: TContractState, vrf_address: ContractAddress);
}

// #[dojo::contract]
#[starknet::contract]
mod world_event_actions {
    use super::IWorldEventActions;
    use starknet::{get_caller_address, ContractAddress};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use risingrevenant::{
        components::world_event::{WorldEvent, EventType},
        systems::{game::{GameAction, GameActionTrait}, world_event::{WorldEventTrait}},
        utils::{random::{RandomGenerator, RandomTrait, RandomImpl}, felt252traits::TruncateTrait}
    };

    #[storage]
    struct Storage {
        admin_address: ContractAddress,
        eth_address: ContractAddress,
        vrf_address: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin_address: ContractAddress,
        eth_address: ContractAddress,
        vrf_address: ContractAddress,
    ) {
        self.admin_address.write(admin_address);
        self.eth_address.write(eth_address);
        self.vrf_address.write(vrf_address);
    }

    #[abi(embed_v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn create(self: @ContractState, world: IWorldDispatcher, game_id: u128) {
            let game_action = GameAction { game_id, world: world };
            let caller = get_caller_address();
            game_action.assert_is_admin(caller);
        }

        fn receive_random_words(
            self: @ContractState,
            world: IWorldDispatcher,
            requestor_address: ContractAddress,
            request_id: u64,
            random_words: Span<felt252>,
            calldata: Array<felt252>
        ) {
            let random_word = *random_words.at(0);
            let game_id: u128 = calldata.at(0).try_into().unwrap().truncate();
            let game_action = GameAction { game_id, world: world };
            game_action.new_random_world_event(random_word);
        }

        fn set_eth_address(ref self: ContractState, eth_address: ContractAddress) {
            self.assert_is_admin();
            self.eth_address.write(eth_address)
        }

        fn set_vrf_address(ref self: ContractState, vrf_address: ContractAddress) {
            self.assert_is_admin();
            self.vrf_address.write(vrf_address)
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn assert_is_admin(self: @ContractState) {
            let admin_address = self.admin_address.read();
            assert(admin_address == get_caller_address(), 'Not Admin');
        }
    }
}
