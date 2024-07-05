use core::hash::HashStateTrait;
use debug::PrintTrait;
use traits::{Into, TryInto};
use dojo::database::introspect::Introspect;
use starknet::{ContractAddress, get_block_info, get_caller_address};
use core::poseidon::PoseidonTrait;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::components::upgradeable::{IUpgradeableDispatcher, IUpgradeableDispatcherTrait};


use risingrevenant::{
    components::{
        currency::CurrencyTrait,
        game::{
            GamePot, DevWallet, GamePotConsts, GameMap, Dimensions, GameState, GamePhase,
            GamePhases, GameStatus, GameTradeTax
        },
        player::{PlayerInfo}, reinforcement::{ReinforcementMarketConsts},
        outpost::{OutpostMarket, OutpostSetup}, world_event::{WorldEventSetup},
    },
    systems::get_set::{GetTrait, SetTrait, GetGameTrait},
    defaults::{
        ADMIN_ADDRESS, MAP_WIDTH, MAP_HEIGHT, DEV_PERCENT, CONFIRMATION_PERCENT, LTR_PERCENT,
        GAME_TRADE_TAX_PERCENT, EVENT_RADIUS_START, EVENT_RADIUS_INCREASE, OUTPOST_PRICE,
        MAX_OUTPOSTS, OUTPOST_INIT_LIFE, OUTPOST_MAX_REINFORCEMENT, REINFORCEMENT_TARGET_PRICE,
        REINFORCEMENT_MAX_SELLABLE_PERCENTAGE, REINFORCEMENT_DECAY_CONSTANT_MAG,
        REINFORCEMENT_TIME_SCALE_FACTOR_MAG, MAX_OUTPOSTS_PER_PLAYER, PAYMENT_ACTIONS_ADDRESS
        ,PAYMENT_TOKEN_ADDRESS
    }
};


#[derive(Copy, Drop)]
struct GameAction {
    world: IWorldDispatcher,
    game_id: u128,
}


fn get_block_number() -> u64 {
    get_block_info().unbox().block_number
}

#[inline(always)]
#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn set_defaults(self: IWorldDispatcher) {
        let game_id: u128 = 0;

        let game_map = GameMap { game_id, dimensions: Dimensions { x: MAP_WIDTH, y: MAP_HEIGHT }, };
        let game_pot_consts = GamePotConsts {
            game_id,
            pot_address: PAYMENT_ACTIONS_ADDRESS.try_into().unwrap(),
            dev_percent: DEV_PERCENT,
            confirmation_percent: CONFIRMATION_PERCENT,
            ltr_percent: LTR_PERCENT,
        };

        let game_trade_tax = GameTradeTax { game_id, trade_tax_percent: GAME_TRADE_TAX_PERCENT, };

        let outpost_market = OutpostMarket {
            game_id,
            price: OUTPOST_PRICE,
            max_sellable: MAX_OUTPOSTS,
            max_per_player: MAX_OUTPOSTS_PER_PLAYER
        };
        let outpost_setup = OutpostSetup {
            game_id, life: OUTPOST_INIT_LIFE, max_reinforcements: OUTPOST_MAX_REINFORCEMENT,
        };

        let world_event_setup = WorldEventSetup {
            game_id, radius_start: EVENT_RADIUS_START, radius_increase: EVENT_RADIUS_INCREASE,
        };

        let reinforcement_market = ReinforcementMarketConsts {
            game_id,
            target_price: REINFORCEMENT_TARGET_PRICE.convert(),
            decay_constant_mag: REINFORCEMENT_DECAY_CONSTANT_MAG,
            max_sellable_percentage: REINFORCEMENT_MAX_SELLABLE_PERCENTAGE,
            time_scale_mag_factor: REINFORCEMENT_TIME_SCALE_FACTOR_MAG,
        };
        set!(
            self,
            (
                game_map,
                game_pot_consts,
                world_event_setup,
                outpost_market,
                game_trade_tax,
                outpost_setup,
                reinforcement_market
            )
        );
    }
    fn get_uuid(self: IWorldDispatcher) -> u128 {
        let hash_felt = PoseidonTrait::new()
            .update(get_caller_address().into())
            .update(self.uuid().into())
            .finalize();
        (hash_felt.into() & 0xffffffffffffffffffffffffffffffff_u256).try_into().unwrap()
    }
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
        self.world.get_uuid()
    }
    fn get_phase(self: GameAction) -> GamePhase {
        let phases: GamePhases = self.get_game();
        phases.get_phase()
    }
    fn assert_is_admin(self: IWorldDispatcher, player: ContractAddress) {
        assert(self.is_owner(player, 0), 'Not admin');
    }
    fn assert_not_started(self: GameAction) {
        assert(self.get_phase() == GamePhase::Created, 'Game Has started');
    }
    fn assert_preparing(self: GameAction) {
        assert(self.get_phase() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GameAction) {
        assert(self.get_phase() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: GameAction) {
        assert(self.get_phase() == GamePhase::Ended, 'Game not ended');
    }
    fn get_block_number(self: GameAction) -> u64 {
        get_block_info().unbox().block_number
    }
}

#[generate_trait]
impl GamePhaseImpl of GamePhaseTrait {
    fn get_phase(self: GamePhases) -> GamePhase {
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
        assert(self.get_phase() == GamePhase::Preparing, 'Game not in preparing phase');
    }
    fn assert_playing(self: GamePhases) {
        assert(self.get_phase() == GamePhase::Playing, 'Game not in play phase');
    }
    fn assert_ended(self: GamePhases) {
        assert(self.get_phase() == GamePhase::Ended, 'Game not ended');
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


