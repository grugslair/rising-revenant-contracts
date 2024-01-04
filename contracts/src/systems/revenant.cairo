use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IRevenantActions<TContractState> {
    // Create revenants, it is possible to create multiple at once. Return the IDs of the revenant and the outpost. 
    // If multiple are created at once, then the ID of the first one will be returned.
    fn create(self: @TContractState, game_id: u32, count: u32) -> (u128, u128);

    // Claim the initial game rewards.
    fn claim_initial_rewards(self: @TContractState, game_id: u32) -> bool;

    // Claim the endgame rewards.
    fn claim_endgame_rewards(self: @TContractState, game_id: u32) -> u256;

    fn claim_score_rewards(self: @TContractState, game_id: u32) -> u256;

    fn get_current_price(self: @TContractState, game_id: u32, count: u32) -> u128;

    fn purchase_reinforcement(self: @TContractState, game_id: u32, count: u32) -> bool;

    fn reinforce_outpost(self: @TContractState, game_id: u32, count: u32, outpost_id: u128);
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
    use realmsrisingrevenant::components::player::{PlayerInfo, PlayerInfoImpl, PlayerInfoTrait};
    use realmsrisingrevenant::components::revenant::{
        Revenant, RevenantStatus, RevenantImpl, RevenantTrait,
    };

    use realmsrisingrevenant::utils;

    use realmsrisingrevenant::components::world_event::{WorldEvent, WorldEventTracker};

    use realmsrisingrevenant::constants::{
        MAP_HEIGHT, MAP_WIDTH, OUTPOST_INIT_LIFE, REVENANT_MAX_COUNT, REINFORCEMENT_INIT_COUNT, SPAWN_RANGE_X,SPAWN_RANGE_Y
    };
    use realmsrisingrevenant::utils::random::{Random, RandomImpl};
    use starknet::{
        ContractAddress, get_block_info, get_caller_address, get_contract_address,
        get_block_timestamp
    };
    use super::IRevenantActions;

    #[external(v0)]
    impl RevenantActionImpl of IRevenantActions<ContractState> {
        fn create(self: @ContractState, game_id: u32, count: u32) -> (u128, u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_can_create_outpost(world);

            assert(
                game_data.revenant_count + count <= game.max_amount_of_revenants,
                'max revenants reached'
            );

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            // assert(player_info.revenant_count + count <= REVENANT_MAX_COUNT, 'reach revenant limit');

            if game.revenant_init_price > 0 {
                let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
                let result = erc20
                    .transfer_from(
                        sender: player,
                        recipient: get_contract_address(),
                        amount: game.revenant_init_price,
                    );
                assert(result, 'need approve for erc20');
                game.prize += game.revenant_init_price;
            }


            let seed = starknet::get_tx_info().unbox().transaction_hash;
            let mut random = RandomImpl::new(seed);
            let first_revenant_id: u128 = (game_data.revenant_count + 1).into();
            let first_outpost_id: u128 = (game_data.outpost_count + 1).into();


            let mut i = 0_u128;
            loop {
                if i >= count.into() {
                    break;
                }

                let (revenant, outpost, position) = self
                    ._create_revenant_and_outpost(
                        world,
                        game_id,
                        player,
                        ref random,
                        first_revenant_id + i,
                        first_outpost_id + i,
                    );

                set!(world, (revenant, outpost, position));


                i += 1;
            };

            game_data.revenant_count += count;
            game_data.outpost_count += count;
            game_data.outpost_exists_count += count;

            player_info.revenant_count += count;
            player_info.outpost_count += count;
            player_info.inited == true;

            game_data.remain_life_count += OUTPOST_INIT_LIFE * count;

            set!(world, (game, game_data, player_info));

            (first_revenant_id, first_outpost_id)
        }
        

        // this function if not necessary needs to be deleted
        fn claim_initial_rewards(self: @ContractState, game_id: u32) -> bool {
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

        fn claim_endgame_rewards(self: @ContractState, game_id: u32) -> u256 {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut game = get!(world, game_id, (Game));
            assert(game.status == GameStatus::ended, 'game not ended');
            assert(game.rewards_claim_status == 0, 'rewards has been claimed');

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            assert(player_info.outpost_count > 0, 'not winner');

            let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };

            let prize = game.prize * 75 / 100;
            let result = erc20.transfer(recipient: player, amount: prize);

            assert(result, 'failed to transfer');

            game.rewards_claim_status = 1;

            set!(world, (game));

            prize
        }

        fn claim_score_rewards(self: @ContractState, game_id: u32) -> u256 {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let (mut game, game_info) = get!(world, game_id, (Game, GameEntityCounter));
            assert(game.status == GameStatus::ended, 'game not ended');
            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            assert(player_info.score_claim_status == false, 'rewards has been claimed');
            assert(player_info.score > 0, 'you have no score');

            let prize = game.prize
                * 10
                / 100
                * player_info.score.into()
                / game_info.score_count.into();
            let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
            let result = erc20.transfer(recipient: player, amount: prize);
            assert(result, 'failed to transfer');

            player_info.score_claim_status = true;
            player_info.earned_prize = prize;

            prize
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

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            player_info.check_player_exists(world);   //player should not be able to buy reinforcements if he has never bought a revenant

            let mut reinforcement_balance = get!(world, game_id, ReinforcementBalance);
            let current_price = reinforcement_balance
                .get_reinforcement_price(world, game_id, count);

            let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
            let result = erc20
                .transfer_from(
                    sender: player, recipient: get_contract_address(), amount: current_price.into()
                );
            assert(result, 'need approve for erc20');
            game.prize += current_price.into();

            player_info.reinforcement_count += count;
            reinforcement_balance.count += count;
            game_counter.reinforcement_count += count;

            set!(world, (game, player_info, reinforcement_balance, game_counter));

            true
        }


        fn reinforce_outpost(self: @ContractState, game_id: u32, count: u32, outpost_id: u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_counter) = get!(world, game_id, (Game, GameEntityCounter));

            let mut latest_event = get!(world, (game_id, game_counter.event_count), (WorldEvent));  // get last game event obj

            let mut outpost = get!(
                world, (game_id, outpost_id), (Outpost)
            ); // get reinforcement obj
            outpost.assert_can_reinforcement();


            // if the event id is not equal then we need to check if its being attacked right now
            if (outpost.last_affect_event_id != latest_event.entity_id && latest_event.entity_id != 0)
            {
                let distance = utils::calculate_distance(
                    latest_event.x, latest_event.y, outpost.x, outpost.y, 100
                );

                assert(distance > latest_event.radius, 'outpost under attack');
            }
           

            assert(outpost.lifes != 0, 'outpost is dead');  //added line, Alex

            assert(player == outpost.owner, 'not owner');

            let mut player_info = get!(world, (game_id, player), PlayerInfo); // get player data
            assert(player_info.reinforcement_count >= count, 'no reinforcement'); //Alex

            assert((count + outpost.reinforcement_count <= 20), 'cant add more'); //Alex

            outpost.reinforcement_count += count;
            outpost.lifes += count;

            let shield_amount = outpost.get_shields_amount(); // Alex
            outpost.shield = shield_amount;

            game_counter.remain_life_count += count;

            player_info.reinforcement_count -= count;
            game_counter.reinforcement_count -= count;

            set!(world, (outpost, player_info, game_counter));

            return ();
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _create_revenant_and_outpost(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u32,
            player: ContractAddress,
            ref random: Random,
            revenant_id: u128,
            outpost_id: u128,
        ) -> (Revenant, Outpost, OutpostPosition) {
            // Revenant
            let first_name_idx = random.next_u32(0, 100);
            let last_name_idx = random.next_u32(0, 100);

            let revenant = Revenant {
                game_id,
                entity_id: revenant_id,
                first_name_idx,
                last_name_idx,
                outpost_id,
                owner: player,
                outpost_count: 1,
                status: RevenantStatus::started
            };

            let mut x = (MAP_WIDTH / 2) - random.next_u32(0, SPAWN_RANGE_X);
            let mut y = (MAP_HEIGHT / 2) - random.next_u32(0, SPAWN_RANGE_Y);

            let mut prev_outpost = get!(world, (game_id, x, y), OutpostPosition);
            // avoid multiple outpost appearing in the same position
            if prev_outpost.entity_id > 0 {
                loop {
                    x = (MAP_WIDTH / 2) - random.next_u32(0, SPAWN_RANGE_X);    // HERE add constants
                    y = (MAP_HEIGHT / 2) - random.next_u32(0, SPAWN_RANGE_Y);
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
                revenant_id,
                entity_id: outpost_id,
                owner: player,
                name_outpost: 'Outpost',
                lifes: OUTPOST_INIT_LIFE,
                shield: 0,
                reinforcement_count: 0,
                status: OutpostStatus::created,
                last_affect_event_id: 0
            };

            let position = OutpostPosition { game_id, x, y, entity_id: outpost_id };

            (revenant, outpost, position)
        }
    }
}
