use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


use risingrevenant::{
    components::{
        outpost::{
            Outpost, OutpostTrait, OutpostStatus, OutpostMarket, OutpostSetup, OutpostEventStatus
        },
        world_event::CurrentWorldEventTrait,
        game::{GamePhases, GameState, Position, GameMap, GameStatus,}, player::PlayerInfo,
        world_event::{WorldEvent, CurrentWorldEvent, OutpostVerified, WorldEventVerifications},
        reinforcement::{ReinforcementType},
    },
    systems::{
        player::PlayerActionsTrait, reinforcement::ReinforcementActionTrait,
        game::{GameAction, GameActionTrait, GamePhaseTrait, GamePhase},
        payment::{PaymentSystemTrait}, world_event::{WorldEventTrait},
        position::{PositionGenerator, PositionGeneratorTrait}, get_set::GetTrait,
    },
    utils::random::{RandomTrait},
};


#[generate_trait]
impl OutpostActionsImpl of OutpostActionsTrait {
    fn purchase_outpost(self: GameAction) -> Outpost {
        self.assert_preparing();

        let outpost_market: OutpostMarket = self.get_game();
        let game_state: GameState = self.get_game();
        assert(
            game_state.outpost_created_count <= outpost_market.max_sellable,
            'No more outposts available'
        );

        let player_info = self.get_caller_info();
        assert(player_info.outpost_count < outpost_market.max_per_player, 'Max outposts reached');

        let payment_system = PaymentSystemTrait::new(self);
        let cost = outpost_market.price;

        payment_system.pay_into_pot(player_info.player_id, cost);
        let mut random_generator = self.world.new_generator_from_chain();
        let mut position_generator = PositionGeneratorTrait::new(
            ref random_generator, self.get_game::<GameMap>().dimensions
        );
        let position = self.get_random_outpost_position(ref position_generator);
        let outpost = self.new_outpost(game_state, player_info, position);
        outpost
    }
    fn get_random_outpost_position(
        self: GameAction, ref position_generator: PositionGenerator
    ) -> Position {
        let mut position = position_generator.next();
        loop {
            let outpost = self.get_outpost(position);
            if outpost.status == OutpostStatus::not_created {
                break;
            }
            position = position_generator.next();
        };
        position
    }
    fn new_outpost(
        self: GameAction, mut game_state: GameState, mut player_info: PlayerInfo, position: Position
    ) -> Outpost {
        let setup: OutpostSetup = self.get_game();
        let mut outpost = Outpost {
            game_id: self.game_id,
            position,
            owner: player_info.player_id,
            life: setup.life,
            reinforces_remaining: setup.max_reinforcements,
            reinforcement_type: ReinforcementType::None,
            status: OutpostStatus::active,
        };
        player_info.outpost_count += 1;

        game_state.outpost_created_count += 1;
        game_state.outpost_remaining_count += 1;
        game_state.remain_life_count += outpost.life;
        self.set(outpost);
        self.set(game_state);
        self.set(player_info);
        outpost
    }

    fn get_outpost_price(self: GameAction) -> u256 {
        self.get_game::<OutpostMarket>().price
    }
    fn reinforce_outpost(self: GameAction, outpost_id: Position, count: u32) {
        assert(count > 0, 'Count must be more than 0');
        let player_id = get_caller_address();
        let mut outpost = self.get_active_outpost(outpost_id);
        assert(outpost.owner == player_id, 'Not players outpost');
        assert(outpost.life > 0, 'Outpost is destroyed');
        let game_phase = self.get_phase();
        if game_phase == GamePhase::Playing {
            assert(self.check_outpost_verified(outpost_id), 'Not verified from last event');
        } else {
            assert(game_phase == GamePhase::Preparing, 'Game not running');
        }

        self.update_reinforcements::<i64>(player_id, -(count.into()));
        assert(count <= outpost.reinforces_remaining, 'Over reinforcement limit');
        outpost.reinforces_remaining -= count;
        outpost.life += count;

        self.set(outpost);
    }
    fn get_outpost(self: GameAction, outpost_id: Position) -> Outpost {
        self.get(outpost_id)
    }
    fn get_active_outpost(self: GameAction, outpost_id: Position) -> Outpost {
        // self.assert_playing();
        // not 100% sure why we should only get the outpost if the game is playing
        // if this is enabled it would mean we are not allowed to rienforce when in prep phase
        let outpost = self.get_outpost(outpost_id);
        outpost.assert_active();
        outpost
    }
    fn change_outpost_owner(self: GameAction, outpost_id: Position, new_owner_id: ContractAddress) {
        self.assert_playing();
        let mut outpost = self.get_active_outpost(outpost_id);

        let mut new_owner = self.get_player(new_owner_id);
        let mut old_owner = self.get_player(outpost.owner);

        new_owner.outpost_count += 1;
        old_owner.outpost_count -= 1;
        outpost.owner = new_owner_id;

        self.set(new_owner);
        self.set(old_owner);
        self.set(outpost);
    }
    fn check_outpost_verified(self: GameAction, outpost_id: Position) -> bool {
        let current_event: CurrentWorldEvent = self.get_game();
        if !current_event.is_impacted(outpost_id) {
            return true;
        }
        let verified: OutpostVerified = self.get((current_event.event_id, outpost_id));
        verified.verified
    }
    fn verify_outpost(self: GameAction, outpost_id: Position) {
        let mut phases: GamePhases = self.get_game();
        phases.assert_playing();
        let current_event: CurrentWorldEvent = self.get_game();
        let mut game_state: GameState = self.get_game();
        let mut verified: OutpostVerified = self.get((current_event.event_id, outpost_id));

        assert(!verified.verified, 'Already verified');
        assert(current_event.is_impacted(outpost_id), 'Outpost not impacted');
        let mut outpost = self.get_active_outpost(outpost_id);
        let mut random_generator = self.world.new_generator_from_chain();
        let damage = outpost.apply_world_event_damage(current_event, ref random_generator);
        verified.verified = true;
        game_state.remain_life_count -= damage;

        let mut caller_contribution = self.get_caller_contribution();
        caller_contribution.score += 1;
        game_state.contribution_score_total += 1;

        if outpost.life <= 0 {
            outpost.status = OutpostStatus::destroyed;
            let mut owner = self.get_player(outpost.owner);

            owner.outpost_count -= 1;
            game_state.outpost_remaining_count -= 1;

            if game_state.outpost_remaining_count <= 1 {
                let mut phases: GamePhases = self.get_game();
                phases.status = GameStatus::ended;
                self.set(phases);
            }

            self.set(owner);
        }

        let mut outposts_verified: WorldEventVerifications = self.get_game();
        outposts_verified.verifications += 1;

        self.set(caller_contribution);
        self.set(outpost);
        self.set(verified);
        self.set(game_state);
        self.set(outposts_verified)
    }
    fn set_outpost_reinforcement_type(
        self: GameAction, outpost_id: Position, reinforcement_type: ReinforcementType
    ) {
        let player_id = get_caller_address();
        let mut outpost = self.get_active_outpost(outpost_id);
        assert(outpost.owner == player_id, 'Not players outpost');
        assert(outpost.life > 0, 'Outpost is destroyed');
        let game_phase = self.get_phase();
        if game_phase == GamePhase::Playing {
            assert(self.check_outpost_verified(outpost_id), 'Not verified from last event');
        } else {
            assert(game_phase == GamePhase::Preparing, 'Game not running');
        }
        outpost.reinforcement_type = reinforcement_type;
        self.set(outpost);
    }
    fn get_outpost_event_status(self: GameAction, outpost_id: Position) -> OutpostEventStatus {
        let current_event: CurrentWorldEvent = self.get_game();
        if !current_event.is_impacted(outpost_id) {
            return OutpostEventStatus::NotImpacted;
        }
        let verified: OutpostVerified = self.get((current_event.event_id, outpost_id));
        if verified.verified {
            return OutpostEventStatus::Verified;
        } else {
            return OutpostEventStatus::UnVerified;
        }
    }
}

