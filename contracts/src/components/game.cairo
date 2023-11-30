use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_caller_address};

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct Game {
    #[key]
    game_id: u32, // increment
    start_block_number: u64,
    prize: u256,
    preparation_phase_interval: u64,
    event_interval: u64,
    // The ERC20 token address for increasing reinforcement
    erc_addr: ContractAddress,
    // The initial purchase price of Reinforcement.
    revenant_init_price: u256,
    // if the rewards has been claimed.
    rewards_claim_status: u32,
    status: u32
}

// Config Components ---------------------------------------------------------------------

// This will track the number of games played
#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameTracker {
    #[key]
    entity_id: u128,
    count: u32
}

// Components to check ---------------------------------------------------------------------

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct GameEntityCounter {
    #[key]
    game_id: u32,
    revenant_count: u32,
    outpost_count: u32,
    event_count: u32,
    outpost_exists_count: u32,
    remain_life_count: u32,
    reinforcement_count: u32,
    trade_count: u32,
}

mod GameStatus {
    const not_created: u32 = 0;
    const preparing: u32 = 1;
    const playing: u32 = 2;
    const ended: u32 = 3;
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

