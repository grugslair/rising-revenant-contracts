use debug::PrintTrait;
use traits::{Into, TryInto};
use dojo::database::introspect::Introspect;
use starknet::{ContractAddress, get_block_info};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::components::upgradeable::{IUpgradeableDispatcher, IUpgradeableDispatcherTrait};
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

fn get_block_number() -> u64 {
    get_block_info().unbox().block_number
}
#[inline(always)]
#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn get<K, T, +Introspect<T>, +Serde<T>, +Drop<T>, +Copy<T>, +Drop<K>, +Copy<K>, +Serde<K>>(
        self: GameAction, key: K
    ) -> T {
        get!(self.world, key, T)
    }
    // fn set<T, +Serde<T>, +Drop<T>, +Copy<T>, +IndexView<T>, +Index<T>>(self: GameAction, obj: T) {
    //     set!(self.world, T);
    // }
    fn get_game<T, +Introspect<T>, +Serde<T>, +Drop<T>, +Copy<T>>(self: GameAction) -> T {
        self.get(self.game_id)
    }
    fn uuid(self: GameAction) -> u128 {
        uuid(self.world)
    }
    fn get_status(self: GameAction) -> u8 {
        let phases: GamePhases = self.get_game();
        phases.get_status()
    }

    fn assert_preparing(self: GameAction) {
        assert(self.get_status() == GamePhase::preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GameAction) {
        assert(self.get_status() == GamePhase::playing, 'Game not in play phase');
    }
    fn assert_ended(self: GameAction) {
        assert(self.get_status() == GamePhase::ended, 'Game not ended');
    }
    fn get_block_number(self: GameAction) -> u64 {
        get_block_info().unbox().block_number
    }
}

#[generate_trait]
impl GamePhaseImpl of GamePhaseTrait {
    fn get_status(self: GamePhases) -> u8 {
        if self.status == GameStatus::not_created {
            return GamePhase::not_created;
        }
        if self.status == GameStatus::ended {
            return GamePhase::ended;
        }

        let current_block = get_block_number();
        if current_block < self.preparation_block_number {
            return GamePhase::created;
        }
        if current_block < self.play_block_number {
            return GamePhase::preparing;
        }
        GamePhase::playing
    }

    fn assert_preparing(self: GamePhases) {
        assert(self.get_status() == GamePhase::preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GamePhases) {
        assert(self.get_status() == GamePhase::playing, 'Game not in play phase');
    }
    fn assert_ended(self: GamePhases) {
        assert(self.get_status() == GamePhase::ended, 'Game not ended');
    }
}

