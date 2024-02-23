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

use risingrevenant::systems::get_set::{GetTrait, SetTrait, GetGameTrait};


#[derive(Copy, Drop)]
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
    fn get<T, K, +GetTrait<T, K>>(self: GameAction, key: K) -> T {
        GetTrait::<T, K>::get(self.world, self.game_id, key)
    }
    fn set<T, +Drop<T>, +SetTrait<T>>(self: GameAction, model: T) {
        model.set(self.world);
    }
    fn get_game<T, +GetGameTrait<T>>(self: GameAction) -> T {
        GetGameTrait::<T>::get(self.world, self.game_id)
    }
    fn uuid(self: GameAction) -> u128 {
        uuid(self.world)
    }
    fn get_status(self: GameAction) -> GamePhase {
        let phases: GamePhases = self.get_game();
        phases.get_status()
    }

    fn assert_preparing(self: GameAction) {
        assert(self.get_status() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GameAction) {
        assert(self.get_status() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: GameAction) {
        assert(self.get_status() == GamePhase::Ended, 'Game not ended');
    }
    fn get_block_number(self: GameAction) -> u64 {
        get_block_info().unbox().block_number
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
        GamePhase::Playing
    }

    fn assert_preparing(self: GamePhases) {
        assert(self.get_status() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GamePhases) {
        assert(self.get_status() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: GamePhases) {
        assert(self.get_status() == GamePhase::Ended, 'Game not ended');
    }
}
// #[cfg(test)]
// mod tests {
//     use super::{GamePhases, GamePhase, get_block_number};
//     use dojo::test_utils::spawn_test_world;
//     #[test]
//     #[available_gas(100000000)]
//     fn test_phase_is_preparing() {
//         let phase = GamePhase::Preparing;
//         let world = spawn_test_world();
//         println!("Block number {}", get_block_number());
//         assert(phase == GamePhase::Preparing, 'not Preparing');
//     }
// }


