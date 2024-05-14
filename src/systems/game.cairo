use starknet::{ContractAddress, get_block_info, get_caller_address, get_block_number};
use core::{integer::BoundedInt, poseidon::{PoseidonTrait, HashStateTrait}, traits::BitAnd};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


use risingrevenant::{
    components::{
        currency::CurrencyTrait,
        game::{
            GamePot, DevWallet, GamePotConsts, GameMap, Dimensions, GameState, GamePhase,
            GamePhases, GameStatus, GameTradeTax, CurrentGame
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
        REINFORCEMENT_TIME_SCALE_FACTOR_MAG, MAX_OUTPOSTS_PER_PLAYER
    },
    utils::{get_transaction_hash, random::{RandomTrait,}, felt252traits::BitAndFelt252Impl},
};
#[derive(Copy, Drop)]
struct GameAction {
    world: IWorldDispatcher,
    game_id: u128,
}

fn make_uuid(world: IWorldDispatcher) -> u128 {
    (PoseidonTrait::new().update(get_transaction_hash()).update(world.uuid().into()).finalize()
        & BoundedInt::<u128>::max().into())
        .try_into()
        .unwrap()
}

#[inline(always)]
#[generate_trait]
impl GameActionImpl of GameActionTrait {
    fn set_defaults(self: IWorldDispatcher) {
        let game_id: u128 = 0;

        let game_map = GameMap { game_id, dimensions: Dimensions { x: MAP_WIDTH, y: MAP_HEIGHT }, };
        let game_pot_consts = GamePotConsts {
            game_id,
            pot_address: get_caller_address(),
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

    fn new_game(self: IWorldDispatcher, start_block: u64, preparation_blocks: u64) -> u128 {
        let caller_id = get_caller_address();
        let game_id: u128 = make_uuid(self);
        println!("Creating game with id: {}", game_id);
        let game_action = GameAction { world: self, game_id };
        game_action.assert_is_admin(caller_id);
        let mut current_game: CurrentGame = game_action.get(caller_id);
        let _last_game_id = current_game.game_id;
        current_game.game_id = game_id;

        let current_block = get_block_info().unbox().block_number;
        let mut game_map: GameMap = get!(self, 0, GameMap);
        let mut game_pot_consts: GamePotConsts = get!(self, 0, GamePotConsts);
        let mut game_trade_tax: GameTradeTax = get!(self, 0, GameTradeTax);
        let mut outpost_market: OutpostMarket = get!(self, 0, OutpostMarket);
        let mut outpost_setup: OutpostSetup = get!(self, 0, OutpostSetup);
        let mut world_event_setup: WorldEventSetup = get!(self, 0, WorldEventSetup);
        let mut reinforcement_market: ReinforcementMarketConsts = get!(
            self, 0, ReinforcementMarketConsts
        );
        game_map.game_id = game_id;
        game_pot_consts.game_id = game_id;
        game_trade_tax.game_id = game_id;
        outpost_market.game_id = game_id;
        outpost_setup.game_id = game_id;
        world_event_setup.game_id = game_id;
        reinforcement_market.game_id = game_id;

        game_pot_consts.pot_address = caller_id;

        let game_phases = GamePhases {
            game_id,
            status: GameStatus::created,
            preparation_block_number: current_block,
            play_block_number: current_block + preparation_blocks,
        };

        game_action.set(current_game);
        game_action.set(game_map);
        game_action.set(game_pot_consts);
        game_action.set(world_event_setup);
        game_action.set(outpost_market);
        game_action.set(game_trade_tax);
        game_action.set(game_phases);
        game_action.set(outpost_setup);
        game_action.set(reinforcement_market);
        game_id
    }
    fn uuid(self: GameAction) -> u128 {
        make_uuid(self.world)
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
    fn get_phase(self: GameAction) -> GamePhase {
        let phases: GamePhases = self.get_game();
        phases.get_phase()
    }
    fn assert_is_admin(self: GameAction, player: ContractAddress) {
        assert(player.into() == ADMIN_ADDRESS, 'Not admin');
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

