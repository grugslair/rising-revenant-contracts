use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::outpost::{
    Outpost, OutpostTrait, OutpostStatus, OutpostMarket, OutpostSetup
};
use risingrevenant::components::world_event::CurrentWorldEventTrait;
use risingrevenant::components::game::{
    GamePhases, GameState, Position, PositionTrait, GameMap, GameStatus,
};
use risingrevenant::components::player::PlayerInfo;
use risingrevenant::components::world_event::{WorldEvent, CurrentWorldEvent, OutpostVerified};

use risingrevenant::systems::player::PlayerActionsTrait;
use risingrevenant::systems::reinforcement::ReinforcementActionTrait;
use risingrevenant::systems::game::{GameAction, GameActionTrait, GamePhaseTrait, GamePhase};
use risingrevenant::systems::payment::{PaymentSystemTrait};
use risingrevenant::systems::world_event::{WorldEventTrait};
use risingrevenant::systems::position::{PositionGeneratorTrait};
use risingrevenant::systems::get_set::GetTrait;


#[generate_trait]
impl OutpostActionsImpl of OutpostActionsTrait {
    fn purchase_outpost(self: GameAction) -> Outpost {
        self.assert_preparing();

        let mut outpost_market: OutpostMarket = self.get_game();
        assert(outpost_market.available > 0, 'No more outposts available');

        let player_info = self.get_caller_info();
        let payment_system = PaymentSystemTrait::new(self);
        let cost = outpost_market.price;

        payment_system.pay_into_pot(player_info.player_id, cost);
        let outpost = self.new_outpost(player_info);

        outpost_market.available -= 1;
        self.set(outpost_market);
        outpost
    }

    fn new_outpost(self: GameAction, mut player_info: PlayerInfo) -> Outpost {
        let setup: OutpostSetup = self.get_game();
        let mut position_generator = PositionGeneratorTrait::new(self);
        let mut outpost = Outpost {
            game_id: self.game_id,
            position: position_generator.next(),
            owner: player_info.player_id,
            life: setup.life,
            reinforces_remaining: setup.max_reinforcements,
            status: OutpostStatus::active,
        };

        println!("New outpost position: {}", setup.life);

        loop {
            let _outpost: Outpost = self.get_outpost(outpost.position);
            if _outpost.status == OutpostStatus::not_created {
                break;
            }
            outpost.position = position_generator.next();
        };
        player_info.outpost_count += 1;

        let mut game_state: GameState = self.get_game();
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
        let player_id = get_caller_address();
        let mut outpost = self.get_active_outpost(outpost_id);
        assert(outpost.owner == player_id, 'Not players outpost');
        assert(outpost.life > 0 , 'Outpost is destroyed');

        // this needs to check the GamePhases
        // also needs to check if the current event one is hitting it
        let mut game_phase = self.get_status();

        // we first need to check the game is in either playing or preparing phase
        assert(game_phase != GamePhase::Ended, 'Game has ended');
        assert(game_phase != GamePhase::Created, 'Game has not began yet');

        //then we check if the phase is in game 
        if (game_phase == GamePhase::Playing) {
            let current_event: CurrentWorldEvent = self.get_game();

            let is_impacted = current_event.is_impacted(outpost_id);    
            //if the outpost is in the event
            if (is_impacted) {
                //has it been confirmed
                let verified: OutpostVerified = self.get((current_event.event_id, outpost_id));
                assert(verified.verified, 'Not verified from last event');
            }
        }

        self.update_reinforcements::<i64>(player_id, -count.into());
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
        if current_event.is_impacted(outpost_id) {
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

        outpost.life -= 1;
        verified.verified = true;
        game_state.remain_life_count -= 1;
        let mut caller_contribution = self.get_caller_contribution();
        caller_contribution.score += 1;

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

        self.set(caller_contribution);
        self.set(outpost);
        self.set(verified);
        self.set(game_state);
    }
}

