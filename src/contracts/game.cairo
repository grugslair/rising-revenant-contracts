#[starknet::interface]
trait IGameActions<TContractState> {
    fn create(
        self: @TContractState,
        preparation_phase_interval: u64,
        event_interval: u64,
        coin_erc_address: ContractAddress,
        jackpot_pool_addr: ContractAddress,
        revenant_init_price: u128,
        max_amount_of_revenants: u32,
        // The percentage of the transaction fee charged during a trade. 5 means 95% trades goes to the player and 5% to the jackpot
        transaction_fee_percent: u32,
        // The percentage of the prize pool allocated to the champion. 85 means 85% to jackpot and 15% to contribution
        winner_prize_percent: u32,
    ) -> u32;
    fn get_current_block(self: @TContractState) -> u64;
    fn refresh_status(self: @TContractState, game_id: u128);
}

#[dojo::contract]
mod game_actions {
    use risingrevenant::components::game::{
        Game, GameStatus, GameCountTracker, GameEntityCounter, GameTrait, GameImpl
    };
    use risingrevenant::components::reinforcement::{ReinforcementBalance, target_price};
    use risingrevenant::constants::GAME_CONFIG;
    use starknet::{
        ContractAddress, get_block_info, get_block_number, get_block_timestamp, get_caller_address
    };
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use super::IGameActions;

    #[external(v0)]
    impl GameActionImpl of IGameActions<ContractState> {
        fn create(
            self: @ContractState,
            preparation_phase_interval: u64,
            event_interval: u64,
            coin_erc_address: ContractAddress,
            jackpot_pool_addr: ContractAddress,
            revenant_init_price: u128,
            max_amount_of_revenants: u32,
            transaction_fee_percent: u32,
            winner_prize_percent: u32,
        ) -> u32 {
            let world = self.world_dispatcher.read();
            let mut game_tracker = get!(world, GAME_CONFIG, (GameCountTracker));
            let game_id = game_tracker.game_count + 1; // game id increment
            world.uuid()

            assert(transaction_fee_percent < 100, 'invalid transaction fee');
            assert(winner_prize_percent < 100, 'invalid champion prize');

            let start_block_number = get_block_info().unbox().block_number; // blocknumber
            let jackpot = 0; // total prize
            let status = GameStatus::preparing; // game status

            let game = Game {
                game_id,
                start_block_number,
                jackpot,
                preparation_phase_interval,
                event_interval,
                coin_erc_address,
                jackpot_pool_addr,
                revenant_init_price,
                status,
                transaction_fee_percent,
                winner_prize_percent,
                jackpot_claim_status: 0,
                max_amount_of_revenants: max_amount_of_revenants,
            };

            let game_counter = GameEntityCounter {
                game_id,
                revenant_count: 0,
                outpost_count: 0,
                event_count: 0,
                outpost_remaining_count: 0,
                remain_life_count: 0,
                reinforcement_count: 0,
                trade_count: 0,
                contribution_score_count: 0,
            };
            let game_tracker = GameCountTracker { entity_id: GAME_CONFIG, game_count: game_id };
            let reinforcement_balance = ReinforcementBalance {
                game_id,
                target_price: target_price,
                start_timestamp: get_block_timestamp(),
                count: 0,
            };

            set!(world, (game, game_counter, game_tracker, reinforcement_balance));

            return (game_id);
        }

        fn refresh_status(self: @ContractState, game_id: u128) {
            let world = self.world_dispatcher.read();
            let mut game: Game = get!(world, game_id, Game);
            game.assert_existed();
            game.refresh_status(world);
        }

        fn get_block_number(self: @ContractState) -> u64 {
            get_block_number()
        }
    }
}
