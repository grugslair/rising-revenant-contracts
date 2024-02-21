use starknet::{ContractAddress, get_block_number, get_block_timestamp};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::game::{
    GamePot, DevWallet, GamePotConsts, GameMap, Dimensions, GameState, GameStatus, GamePhases
};
use risingrevenant::components::player::{PlayerInfo};


#[derive(Copy, Drop, Print)]
struct GameAction {
    world: IWorldDispatcher,
    game_id: u128,
}

#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn get<K, T>(self: @GameAction, key: K) -> T {
        get!(self.world, key, (T))
    }
    fn set<T>(self: @GameAction, obj: T) {
        set!(self.world, (T));
    }
    fn get_game<T>(self: @GameAction) -> T {
        self.get(*self.game_id)
    }
    fn uuid(self: @GameAction) -> u128 {
        IWorldDispatcherTrait::uuid(*self.world).into()
    }
    fn get_status(self: @GameAction) -> GameStatus {
        let phases: GamePhases = self.get_game();
        assert(phases.game_created, 'Game Not Created');
        if phases.game_ended {
            return GameStatus::Ended;
        }
        let current_block = get_block_number();
        if current_block < phases.preparation_block_number {
            return GameStatus::Created;
        }
        if current_block < phases.play_block_number {
            return GameStatus::Preparing;
        }
        return GameStatus::Playing;
    }

    fn assert_preparing(self: @GameAction) {
        assert(self.get_status() == GameStatus::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: @GameAction) {
        assert(self.get_status() == GameStatus::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: @GameAction) {
        assert(self.get_status() == GameStatus::Ended, 'Game not ended');
    }
}

