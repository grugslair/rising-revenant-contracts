use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameSetup {
    #[key]
    game_id: u32, // increment
    start_block_number: u64,
    preparation_phase_interval: u64,
    event_interval: u64,
    pot_pool_addr: ContractAddress, // The contract that houses the prize pool can, by default, use the contract where the revenant_action is located.
    coin_erc_address: ContractAddress, // The ERC20 token address for increasing reinforcement
    trade_pot_percent: u32, // 10
    dev_percent: u8, // 10
    confirmation_percent: u8, // 10
    ltr_percent: u8, // 5
    revenant_init_price: u128, // The initial purchase price of Reinforcement.
    max_amount_of_revenants: u32,
}


// This will track the number of games played
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameCountTracker {
    #[key]
    entity_id: u128,
    game_count: u32,
}

// Components to check ---------------------------------------------------------------------
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameOutpostsTracker {
    #[key]
    game_id: u32,
    outpost_created_count: u32,
    outpost_exists_count: u32,
    remain_life_count: u32,
    reinforcement_count: u32,
}

// Game pot
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GamePot {
    #[key]
    game_id: u32,
    total_pot: u256,
    winners_pot: u256,
    confirmation_pot: u256,
    ltr_pot: u256,
    dev_pot: u256,
    contribution_score_count: u256,
}

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct DevWallet {
    #[key]
    game_id: u32,
    #[key]
    owner: ContractAddress,
    balance: u256,
    init: bool,
}


mod GameStatus {
    const not_created: u8 = 0;
    const preparing: u8 = 1;
    const playing: u8 = 2;
    const ended: u8 = 3;
}

#[generate_trait]
impl GamePotImpl of GamePotTrait {
    fn increse(ref self: GamePot, world: @IWorldDispatcher, amount: u128) {
        let game: GameSetup = get!(*world, self.game_id, (GameSetup));
        self.total_pot += amount;
        self.confirmation_pot = self.total_pot * game.confirmation_percent.into() / 100_u128;
        self.ltr_pot = self.total_pot * game.ltr_percent.into() / 100_u128;
        self.dev_pot = self.total_pot * game.dev_percent.into() / 100_u128;
        self.winners_pot = self.total_pot - self.confirmation_pot - self.ltr_pot - self.dev_pot;
        set!(*world, (self));
    }
}


#[generate_trait]
impl GameImpl of GameTrait {
    fn refresh_status(ref self: Game, world: IWorldDispatcher) {
        let block_number = starknet::get_block_info().unbox().block_number;
        if self.status == GameStatus::preparing
            && (block_number - self.start_block_number) > self.preparation_phase_interval {
            self.status = GameStatus::playing;
            set!(world, (self));
        }
    }

    fn assert_can_create_outpost(ref self: Game, world: IWorldDispatcher) {
        self.assert_existed();
        assert(self.status != GameStatus::ended, 'Game has ended');

        self.refresh_status(world);
        assert(self.status != GameStatus::playing, 'Prepare phase ended');
    }

    fn assert_is_playing(ref self: Game, world: IWorldDispatcher) {
        self.assert_existed();
        assert(self.status != GameStatus::ended, 'Game has ended');
        self.refresh_status(world);
        assert(self.status == GameStatus::playing, 'Game has not started');
    }

    fn assert_existed(self: Game) {
        assert(self.status != GameStatus::not_created, 'Game not exist');
    }
}
