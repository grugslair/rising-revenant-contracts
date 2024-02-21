#[starknet::interface]
trait IWorldEventActions<TContractState> {
    fn create(self: @TContractState, game_id: u128) -> WorldEvent;

    fn destroy_outpost(
        self: @TContractState, game_id: u128, event_id: u128, outpost_id: u128
    ) -> bool;
}

#[dojo::contract]
mod world_event_actions {
    use risingrevenant::components::game::{
        Game, GameEntityCounter, GameStatus, GameTrait, GameImpl
    };
    use risingrevenant::components::outpost::{
        Outpost, OutpostPosition, OutpostStatus, OutpostImpl, OutpostTrait
    };
    use risingrevenant::components::player::{PlayerInfo, PlayerInfoImpl, PlayerInfoTrait};
    use risingrevenant::components::world_event::{WorldEvent, WorldEventTracker};
    use risingrevenant::constants::{
        EVENT_INIT_RADIUS, MAP_HEIGHT, MAP_WIDTH, EVENT_INCREASE_RADIUS, DESTORY_OUTPOST_SCORE,
        SPAWN_RANGE_Y_MAX, SPAWN_RANGE_Y_MIN, SPAWN_RANGE_X_MAX, SPAWN_RANGE_X_MIN
    };
    use risingrevenant::utils::MAX_U32;
    use risingrevenant::utils::random::{Random, RandomImpl};
    use risingrevenant::utils;
    use starknet::{ContractAddress, get_block_info, get_caller_address};
    use super::IWorldEventActions;

    #[external(v0)]
    impl WorldEventActionImpl of IWorldEventActions<ContractState> {
        fn create(self: @ContractState, game_id: u128) -> WorldEvent {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            // check game is active
            let mut game = get!(world, game_id, Game);
            game.assert_is_playing(world);

            let mut game_data = get!(world, game_id, GameEntityCounter);
            game_data.event_count += 1;

            let entity_id: u128 = game_data.event_count.into();
            if entity_id > 1 {
                // check prev event block number
                let prev_world_event = get!(world, (game_id, entity_id - 1), WorldEvent);
                let block_number = starknet::get_block_info().unbox().block_number;
                assert(
                    (block_number - prev_world_event.block_number) > game.event_interval,
                    'event occur interval too small'
                );
            }

            let mut caller_info = get!(world, (game_id, player), (PlayerInfo));
            let world_event = self._new_world_event(world, game_id, player, entity_id);
            // caller_info.score += EVENT_CREATE_SCORE;    
            // game_data.contribution_score_count += EVENT_CREATE_SCORE;
            set!(world, (world_event, game_data, caller_info));
            world_event
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _new_world_event(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u128,
            player: ContractAddress,
            entity_id: u128,
        ) -> WorldEvent {
            let mut radius: u32 = EVENT_INIT_RADIUS;
            if entity_id > 1 {
                let prev_world_event = get!(world, (game_id, entity_id - 1), WorldEvent);
                if prev_world_event.destroy_count == 0 && prev_world_event.radius < MAX_U32 {
                    radius = prev_world_event.radius + EVENT_INCREASE_RADIUS;
                } else {
                    radius = prev_world_event.radius;
                }
            }

            let block_number = starknet::get_block_info().unbox().block_number;

            let seed = starknet::get_tx_info().unbox().transaction_hash;
            let mut random = RandomImpl::new(seed);
            let x = random.next_u32(0, SPAWN_RANGE_X_MAX);
            let y = random.next_u32(0, SPAWN_RANGE_Y_MAX);

            WorldEvent { game_id, entity_id, x, y, radius, destroy_count: 0, block_number }
        }
    }
}
