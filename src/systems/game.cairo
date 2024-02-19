use starknet::ContractAddress;
use risingrevenant::components::game::{GameSetup, GamePot, DevWallet};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use openzeppelin::token::erc20::interface::{
    IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
};

// DEV
use risingrevenant::constants::PLAYER_STARTING_AMOUNT;

struct GameAction {
    world: IWorldDispatcher,
    game_id: u32,
}

#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn get<K, T>(self: @GameAction, key: K) -> T {
        get!(self.world, key, (T))
    }
    fn set<T>(self: @GameAction, obj: T) {
        set!(self.world, (T));
    }
    fn get_setup(self: @GameAction) -> GameSetup {
        let setup: GameSetup = self.get(*self.game_id);
        setup
    }
    fn check_game_playing(self: @GameAction) {}
    fn transfer<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(
        self: @GameAction, sender: ContractAddress, recipient: ContractAddress, amount: T
    ) {
        // // PRODUCTION
        // let game = self.get_setup();
        // let erc20 = IERC20Dispatcher { contract_address: game.coin_erc_address };
        // let result = erc20.transfer_from(sender, recipient, amount: amount.into());
        // assert(result, 'need approve for erc20');

        // DEV ONLY
        let mut sender_wallet: DevWallet = self.get((*self.game_id, sender));
        let mut recipiant_wallet: DevWallet = self.get((*self.game_id, recipient));
        if (!sender_wallet.init) {
            sender_wallet.init = true;
            sender_wallet.balance = PLAYER_STARTING_AMOUNT;
        }
        if (!recipiant_wallet.init) {
            recipiant_wallet.init = true;
            recipiant_wallet.balance = PLAYER_STARTING_AMOUNT;
        }
        assert(sender_wallet.balance >= amount.into(), 'not enough cash');
        sender_wallet.balance -= amount.into();
        recipiant_wallet.balance += amount.into();
        self.set((sender_wallet, recipiant_wallet));
    }
    fn increase_pot<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(self: @GameAction, amount: T) {
        let game: GameSetup = self.get(self.game_id);
        let mut game_pot: GamePot = self.get((self.game_id));
        game_pot.total_pot += amount.into();
        game_pot.confirmation_pot = game_pot.total_pot
            * game.confirmation_percent.into()
            / 100_u256;
        game_pot.ltr_pot = game_pot.total_pot * game.ltr_percent.into() / 100_u256;
        game_pot.dev_pot = game_pot.total_pot * game.dev_percent.into() / 100_u256;
        game_pot.winners_pot = game_pot.total_pot
            - game_pot.confirmation_pot
            - game_pot.ltr_pot
            - game_pot.dev_pot;
        self.set(game_pot);
    }
}

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
    fn refresh_status(self: @TContractState, game_id: u32);
}

#[dojo::contract]
mod game_actions {
    use risingrevenant::components::game::{
        Game, GameStatus, GameCountTracker, GameEntityCounter, GameTrait, GameImpl
    };
    use risingrevenant::components::reinforcement::{ReinforcementBalance, target_price};
    use risingrevenant::constants::GAME_CONFIG;
    use starknet::{ContractAddress, get_block_info, get_block_timestamp, get_caller_address};
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
                outpost_exists_count: 0,
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

        fn refresh_status(self: @ContractState, game_id: u32) {
            let world = self.world_dispatcher.read();
            let mut game: Game = get!(world, game_id, Game);
            game.assert_existed();
            game.refresh_status(world);
        }

        fn get_current_block(self: @ContractState) -> u64 {
            let start_block_number = get_block_info().unbox().block_number; // blocknumber
            return start_block_number;
        }
    }
}

