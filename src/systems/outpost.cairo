use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::outpost::{Outpost, OutpostTrait, Position, PositionTrait};
use risingrevenant::components::game::{GameSetup, GameOutpostsTracker};
use risingrevenant::components::player::PlayerInfo;

use risingrevenant::systems::player::PlayerActionsTrait;
use risingrevenant::systems::reinforcement::ReinforcementActionTrait;
use risingrevenant::systems::game::{GameAction, GameActionTrait};

use risingrevenant::utils::random::{Random, RandomImpl};


#[generate_trait]
impl OutpostActionsImpl of OutpostActionsTrait {
    fn new_outpost(self: @GameAction, ref player_info: PlayerInfo) -> Outpost {
        let game_setup: GameSetup = self.get(self.game_id);
        let mut random = RandomImpl::new(starknet::get_tx_info().unbox().transaction_hash);
        let mut outpost = OutpostTrait::new_random(
            *self.game_id, player_info.player_id, ref random
        );
        loop {
            let _outpost: Outpost = self.get((self.game_id, outpost.position));
            if _outpost.status == 0 {
                break;
            }
            outpost.position = PositionTrait::new_random(ref random);
        };
        player_info.outpost_count += 1;

        let mut game_outpost_tracker: GameOutpostsTracker = self.get(self.game_id);
        game_outpost_tracker.outpost_created_count += 1;
        game_outpost_tracker.outpost_exists_count += 1;
        game_outpost_tracker.remain_life_count += outpost.lifes;
        self.set((player_info, outpost, game_outpost_tracker));
        outpost
    }
    fn reinforce_outpost(self: @GameAction, outpost_id: Position, count: u32) {
        let player_id = get_caller_address();
        let mut outpost = self.get_active_outpost(outpost_id);
        assert(outpost.owner == player_id, 'Not players outpost');
        self.update_renforcements::<i64>(player_id, -count.into());

        let max_reinforcement = outpost.get_max_reinforcement();
        assert(count <= max_reinforcement, 'Over reinforcment limit');
        outpost.reinforcements += count;
        self.set(outpost);
    }
    fn get_outpost(self: @GameAction, outpost_id: Position) -> Outpost {
        self.get((self.game_id, outpost_id))
    }
    fn get_active_outpost(self: @GameAction, outpost_id: Position) -> Outpost {
        let outpost = self.get_outpost(outpost_id);
        outpost.assert_existed();
        outpost
    }
    fn change_outpost_owner(
        self: @GameAction, outpost_id: Position, new_owner_id: ContractAddress
    ) {
        let mut outpost = self.get_active_outpost(outpost_id);

        let mut new_owner = self.get_player(new_owner_id);
        let mut old_owner = self.get_player(outpost.owner);

        new_owner.outpost_count += 1;
        old_owner.outpost_count -= 1;
        outpost.owner = new_owner_id;

        self.set((new_owner, old_owner, outpost));
    }
}


#[starknet::interface]
trait IOutpostActions<TContractState> {
    fn purchase(self: @TContractState, game_id: u32) -> Position;
    fn reinforce(self: @TContractState, game_id: u32, outpost_id: Position, count: u32);
}


#[dojo::contract]
mod outpost_actions {
    use super::IOutpostActions;
    use super::OutpostActionsTrait;

    use risingrevenant::components::outpost::{OutpostTrait, Position};
    use risingrevenant::components::game::{GameSetup};
    use risingrevenant::components::player::{PlayerInfo};

    use risingrevenant::systems::game::{GameAction, GameActionTrait};
    use risingrevenant::systems::player::{PlayerActionsTrait};

    #[external(v0)]
    impl OutpostActionsImpl of IOutpostActions<ContractState> {
        fn purchase(self: @TContractState, game_id: u32) -> Position {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            let game_setup: GameSetup = outpost_action.get(game_id);
            let mut player_info = self.get_caller_info();
            let cost = game_setup.revenant_init_price;
            self.transfer(player_info.player_id, game_setup.pot_pool_addr, cost);
            let outpost = outpost_action.new_outpost(ref player_info);
            self.increase_pot(cost);
            outpost.position
        }

        fn reinforce(self: @TContractState, game_id: u32, outpost_id: Position, count: u32) {
            let outpost_action = GameAction { world: self.world_dispatcher.read(), game_id };
            outpost_action.reinforce_outpost(outpost_id, count);
        }
    }
}
