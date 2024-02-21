use starknet::{ContractAddress, get_block_number, get_block_timestamp};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::game::{
    GamePot, DevWallet, GamePotConsts, GameMap, Dimensions, GameState, GamePhase, GamePhases,
    GameStatus
};
use risingrevenant::components::player::{PlayerInfo};


#[derive(Copy, Drop, Print)]
struct GameAction {
    world: IWorldDispatcher,
    game_id: u128,
}

fn uuid(world: IWorldDispatcher) -> u128 {
    IWorldDispatcherTrait::uuid(world).into()
}

#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn get<K, T>(self: @GameAction, key: K) -> T {
        get!(*self.world, key, (T))
    }
    fn set<T>(self: @GameAction, obj: T) {
        set!(*self.world, (T));
    }
    fn get_game<T>(self: @GameAction) -> T {
        self.get(*self.game_id)
    }
    fn uuid(self: @GameAction) -> u128 {
        uuid(*self.world)
    }
    fn get_status(self: @GameAction) -> GamePhase {
        let phases: GamePhases = self.get_game();
        phases.get_status()
    }

    fn assert_preparing(self: @GameAction) {
        assert(self.get_status() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: @GameAction) {
        assert(self.get_status() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: @GameAction) {
        assert(self.get_status() == GamePhase::Ended, 'Game not ended');
    }
}

#[generate_trait]
impl GamePhaseImpl of GamePhaseTrait {
    fn get_status(self: GamePhases) -> GamePhase {
        if self.status == GameStatus::not_created {
            return GamePhase::NotCreated;
        }
        if self.status == GameStatus::ended {
            return GamePhase::Ended;
        }

        let current_block = get_block_number();
        if current_block < self.preparation_block_number {
            return GamePhase::Created;
        }
        if current_block < self.play_block_number {
            return GamePhase::Preparing;
        }
        return GamePhase::Playing;
    }

    fn assert_preparing(self: @GameAction) {
        assert(self.get_status() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: @GameAction) {
        assert(self.get_status() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: @GameAction) {
        assert(self.get_status() == GamePhase::Ended, 'Game not ended');
    }
}

