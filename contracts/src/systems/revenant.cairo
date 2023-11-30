use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IRevenantActions<TContractState> {
    fn create(self: @TContractState, game_id: u32, name: felt252) -> (u128, u128);

    fn claim(self: @TContractState, game_id: u32) -> bool;

    fn get_current_price(self: @TContractState, game_id: u32, count: u32) -> u128;

    fn purchase_reinforcement(self: @TContractState, game_id: u32, count: u32) -> bool;

    fn reinforce_outpost(self: @TContractState, game_id: u32, outpost_id: u128);
}


#[dojo::contract]
mod revenant_actions {
    use openzeppelin::token::erc20::interface::{
        IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
    };

    use realmsrisingrevenant::components::game::{
        Game, GameStatus, GameTracker, GameEntityCounter, GameTrait, GameImpl,
    };
    use realmsrisingrevenant::components::outpost::{
        Outpost, OutpostPosition, OutpostStatus, OutpostImpl, OutpostTrait
    };
    use realmsrisingrevenant::components::reinforcement::{
        ReinforcementBalance, ReinforcementBalanceImpl, ReinforcementBalanceTrait
    };
    use realmsrisingrevenant::components::player::PlayerInfo;
    use realmsrisingrevenant::components::revenant::{
        Revenant, RevenantStatus, RevenantImpl, RevenantTrait,
    };
    use realmsrisingrevenant::constants::{
        MAP_HEIGHT, MAP_WIDTH, OUTPOST_INIT_LIFE, REVENANT_MAX_COUNT, REINFORCEMENT_INIT_COUNT,
    };
    use realmsrisingrevenant::utils::random::{Random, RandomImpl};
    use starknet::{
        ContractAddress, get_block_info, get_caller_address, get_contract_address,
        get_block_timestamp
    };
    use super::IRevenantActions;

    #[external(v0)]
    impl RevenantActionImpl of IRevenantActions<ContractState> {
        fn create(self: @ContractState, game_id: u32, name: felt252) -> (u128, u128) {
            assert(name != 0, 'name length must larger than 0');

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_can_create_outpost(world);

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            assert(player_info.revenant_count < REVENANT_MAX_COUNT, 'reach revenant limit');
            game_data.revenant_count += 1;

            if game.revenant_init_price > 0 {
                let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
                let result = erc20
                    .transfer_from(
                        sender: player,
                        recipient: get_contract_address(),
                        amount: game.revenant_init_price,
                    );
                assert(result, 'need approve for erc20');
            }

            let entity_id: u128 = game_data.revenant_count.into();

            let revenant = Revenant {
                game_id,
                entity_id,
                owner: player,
                name_revenant: name,
                outpost_count: 1,
                status: RevenantStatus::started
            };
            player_info.revenant_count += 1;
            player_info.outpost_count += 1;

            game_data.outpost_count += 1;
            game_data.outpost_exists_count += 1;
            game_data.remain_life_count += OUTPOST_INIT_LIFE;

            let outpost_id: u128 = game_data.outpost_count.into();

            // create outpost
            let (outpost, position) = self._create_outpost(world, game_id, player, outpost_id);

            set!(world, (revenant, game_data, player_info, outpost, position));
            (entity_id, outpost_id)
        }

        fn claim(self: @ContractState, game_id: u32) -> bool {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_existed();

            let mut player_info = get!(world, (game_id, player), PlayerInfo);

            if (!player_info.inited) {
                player_info.inited = true;
                player_info.reinforcement_count += REINFORCEMENT_INIT_COUNT;
                game_data.reinforcement_count += REINFORCEMENT_INIT_COUNT;
                set!(world, (game_data, player_info));
                return true;
            } else {
                return false;
            }
        }

        fn get_current_price(self: @ContractState, game_id: u32, count: u32) -> u128 {
            let world = self.world_dispatcher.read();
            let mut game = get!(world, game_id, Game);
            game.assert_can_create_outpost(world);

            let balance = get!(world, game_id, ReinforcementBalance);
            return balance.get_reinforcement_price(world, game_id, count);
        }

        fn purchase_reinforcement(self: @ContractState, game_id: u32, count: u32) -> bool {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_counter) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_can_create_outpost(world);

            let mut reinforcement_balance = get!(world, game_id, ReinforcementBalance);
            let current_price = reinforcement_balance
                .get_reinforcement_price(world, game_id, count);

            let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
            let result = erc20
                .transfer_from(
                    sender: player, recipient: get_contract_address(), amount: current_price.into()
                );
            assert(result, 'need approve for erc20');

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            player_info.reinforcement_count += count;
            reinforcement_balance.count += count;
            game_counter.reinforcement_count += count;

            set!(world, (player_info, reinforcement_balance, game_counter));

            true
        }

        fn reinforce_outpost(self: @ContractState, game_id: u32, outpost_id: u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_counter) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_is_playing(world);

            let mut outpost = get!(world, (game_id, outpost_id), (Outpost));
            outpost.assert_can_reinforcement();

            assert(player == outpost.owner, 'not owner');

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            assert(player_info.reinforcement_count > 0, 'no reinforcement');

            // Fortifying Outposts: Outposts, can be bolstered up to 20 times in their lifetime. 
            // The extent of reinforcements directly influences the Outpost’s defense, manifested in the number of shields it wields:
            // 1-2 reinforcements: Unshielded
            // 3-5 reinforcements: 1 Shield
            // 6-9 reinforcements: 2 Shields
            // 9-13 reinforcements: 3 Shields
            // 14-19 reinforcements: 4 Shields
            // 20 reinforcements: 5 Shields

            outpost.reinforcement_count += 1;
            if (outpost.reinforcement_count == 3
                || outpost.reinforcement_count == 6
                || outpost.reinforcement_count == 9
                || outpost.reinforcement_count == 14
                || outpost.reinforcement_count == 20) {
                outpost.lifes += 1;
                game_counter.remain_life_count += 1;
            }

            player_info.reinforcement_count -= 1;
            game_counter.reinforcement_count -= 1;

            set!(world, (outpost, player_info, game_counter));

            return ();
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _create_outpost(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u32,
            player: ContractAddress,
            new_outpost_id: u128,
        ) -> (Outpost, OutpostPosition) {
            let seed = starknet::get_tx_info().unbox().transaction_hash;
            let mut random = RandomImpl::new(seed);
            let mut x = (MAP_WIDTH / 2) - random.next_u32(0, 400);
            let mut y = (MAP_HEIGHT / 2) - random.next_u32(0, 400);

            let mut prev_outpost = get!(world, (game_id, x, y), OutpostPosition);

            // avoid multiple outpost appearing in the same position
            if prev_outpost.entity_id > 0 {
                loop {
                    x = (MAP_WIDTH / 2) - random.next_u32(0, 2000);
                    y = (MAP_HEIGHT / 2) - random.next_u32(0, 2000);
                    prev_outpost = get!(world, (game_id, x, y), OutpostPosition);
                    if prev_outpost.entity_id == 0 {
                        break;
                    };
                }
            };

            let outpost = Outpost {
                game_id,
                x,
                y,
                entity_id: new_outpost_id,
                owner: player,
                name_outpost: 'Outpost',
                lifes: OUTPOST_INIT_LIFE,
                reinforcement_count: 0,
                status: OutpostStatus::created,
                last_affect_event_id: 0
            };

            let position = OutpostPosition { game_id, x, y, entity_id: new_outpost_id };

            (outpost, position)
        }
    }
}

