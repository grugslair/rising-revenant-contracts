use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IRevenantActions<TContractState> {
    fn create(self: @TContractState, game_id: u32) -> (u128, u128);

    // Claim the initial game rewards.
    fn claim_initial_rewards(self: @TContractState, game_id: u32) -> bool;

    // Claim the endgame rewards.
    fn claim_endgame_rewards(self: @TContractState, game_id: u32) -> u256;

    fn claim_score_rewards(self: @TContractState, game_id: u32) -> u256;

    fn get_current_price(self: @TContractState, game_id: u32, count: u32) -> u128;

    fn purchase_reinforcement(self: @TContractState, game_id: u32, count: u32) -> bool;

    fn reinforce_outpost(self: @TContractState, game_id: u32,count: u32, outpost_id: u128);
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
        fn create(self: @ContractState, game_id: u32) -> (u128, u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_can_create_outpost(world);

            assert(game_data.revenant_count + 1 <=  game.max_amount_of_revenants, 'max revenants reached');  //Alex

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            // assert(player_info.revenant_count < REVENANT_MAX_COUNT, 'reach revenant limit');
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
                 game.prize += game.revenant_init_price;
             }

            let entity_id: u128 = game_data.revenant_count.into();

            let (first_name_idx, last_name_idx) = self._create_random_revenant_name();
            let revenant = Revenant {
                game_id,
                entity_id,
                first_name_idx,
                last_name_idx,
                owner: player,
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

            set!(world, (revenant, game, game_data, player_info, outpost, position));


            (entity_id, outpost_id)
        }

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

            // let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };

            let prize = game.prize * 75 / 100;
            // let result = erc20.transfer(recipient: player, amount: prize);

            // assert(result, 'failed to transfer');

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

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
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
            // game.assert_is_playing(world);   // Alex

            let mut outpost = get!(world, (game_id, outpost_id), (Outpost));  // get reinforcement obj
            outpost.assert_can_reinforcement();

            assert(outpost.lifes != 0, 'outpost is dead');  //added line, Alex
            assert(player == outpost.owner, 'not owner');

            let mut player_info = get!(world, (game_id, player), PlayerInfo);  // get player data
            assert(player_info.reinforcement_count >= count, 'no reinforcement');  //Alex

            assert((count + outpost.reinforcement_count <= 20), 'cant add more' ); //Alex

            // Fortifying Outposts: Outposts, can be bolstered up to 20 times in their lifetime. 
            // The extent of reinforcements directly influences the Outpost’s defense, manifested in the number of shields it wields:
            // 1-2 reinforcements: Unshielded
            // 3-5 reinforcements: 1 Shield
            // 6-9 reinforcements: 2 Shields
            // 9-13 reinforcements: 3 Shields
            // 14-19 reinforcements: 4 Shields
            // 20 reinforcements: 5 Shields

            outpost.reinforcement_count += count;
            outpost.lifes += count;

            let shield_amount = outpost.get_shields_amount();  // Alex
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
                    x = (MAP_WIDTH / 2) - random.next_u32(0, 400);
                    y = (MAP_HEIGHT / 2) - random.next_u32(0, 400);
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
                shield: 0,
                reinforcement_count: 0,
                status: OutpostStatus::created,
                last_affect_event_id: 0
            };

            let position = OutpostPosition { game_id, x, y, entity_id: new_outpost_id };

            (outpost, position)
        }

        fn _create_random_revenant_name(self: @ContractState) -> (u32, u32) {
            let seed = starknet::get_tx_info().unbox().transaction_hash;
            let mut random = RandomImpl::new(seed);
            let first_name = random.next_u32(0, 100);
            let last_name = random.next_u32(0, 100);
            (first_name, last_name)
        }
    }
}

