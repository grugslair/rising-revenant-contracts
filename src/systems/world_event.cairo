use starknet::{get_block_number, ContractAddress, get_contract_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use array::{ArrayTrait, SpanTrait};
use pragma_lib::abi::{IRandomnessDispatcher, IRandomnessDispatcherTrait};
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use risingrevenant::{
    components::{
        game::{GameMap},
        world_event::{
            WorldEventSetup, CurrentWorldEvent, CurrentWorldEventTrait, EventType,
            WorldEventVerifications
        }
    },
    systems::{game::{GameAction, GameActionTrait}, position::{Position, PositionGeneratorTrait}},
    utils::{felt252traits::{TruncateTrait}, random::{RandomTrait}}
};

const CALLBACK_FEE_LIMIT: u128 = 1000000000000000; // 0.001 ETH
#[generate_trait]
impl WorldEventImpl of WorldEventTrait {
    fn request_random_world_event(
        self: GameAction,
        randomness_contract_address: ContractAddress,
        callback_address: ContractAddress
    ) {
        let randomness_dispatcher = IRandomnessDispatcher {
            contract_address: randomness_contract_address
        };
        let callback_address = get_contract_address();
        let seed: u64 = self.world.random_from_chain().truncate();
        randomness_dispatcher.request_random(seed, callback_address, CALLBACK_FEE_LIMIT, 0, 1);
    }
    fn new_random_world_event(self: GameAction, seed: felt252) {
        let mut generator = RandomTrait::new_generator(seed);
        let event_type: EventType = (generator.next_capped(3) + 1_u8).into();
        let game_map: GameMap = self.get_game();
        let mut position_generator = PositionGeneratorTrait::new(
            ref generator, game_map.dimensions
        );
        self.new_world_event(seed.truncate(), event_type, position_generator.next());
    }
    fn new_world_event(
        self: GameAction, event_id: u128, event_type: EventType, position: Position
    ) -> CurrentWorldEvent {
        self.assert_playing();
        let event_setup: WorldEventSetup = self.get_game();
        let last_event: CurrentWorldEvent = self.get_game();
        let mut radius: u32 = last_event.radius;

        if radius.is_zero() {
            radius = event_setup.radius_start;
        } else {
            let mut verifications: WorldEventVerifications = self.get_game();
            let n_verifications = verifications.verifications;
            if n_verifications == 0 {
                radius += event_setup.radius_increase;
            } else {
                verifications.verifications = 0;
                self.set(verifications);
            }
            let last_world_event = last_event.to_event(event_id, n_verifications);
            self.set(last_world_event);
        }

        let event = CurrentWorldEvent {
            game_id: self.game_id,
            event_id: event_id,
            position: position,
            event_type,
            radius,
            number: last_event.number + 1,
            block_number: get_block_number(),
            previous_event: last_event.event_id,
        };

        self.set(event);

        event
    }
}
