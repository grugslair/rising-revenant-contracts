#[starknet::interface]
trait IPaymentAction<TContractState> {
    fn claim_jackpot(self: @TContractState, game_id: u128);
    fn claim_confirmation_contribution(self: @TContractState, game_id: u128);
}

#[dojo::contract]
mod payment_actions {
    use risingrevenant::systems::game::GameActionTrait;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use risingrevenant::components::player::{PlayerInfo, PlayerContribution};
    use starknet::{get_caller_address};


    use risingrevenant::systems::game::{GameAction, GameActionImpl, GameState, GamePot};
    use risingrevenant::systems::player::{PlayerActionsTrait};

    use risingrevenant::systems::payment::{PaymentSystemTrait, PaymentSystem};
    use super::IPaymentAction;

    #[external(v0)]
    impl PaymentActionImpl of IPaymentAction<ContractState> {
        fn claim_jackpot(self: @ContractState, game_id: u128) {
            let (game_action, mut pot, payment_system) = self.get_claim_info(game_id);
            let caller = game_action.get_caller_info();
            assert(caller.outpost_count > 0, 'Not winner');
            assert(!pot.claimed, 'Pot already claimed');
            pot.claimed = true;
            game_action.set(pot);

            payment_system.pay_out_pot(caller.player_id, pot.winners_pot);
        }

        fn claim_confirmation_contribution(self: @ContractState, game_id: u128) {
            let (game_action, pot, payment_system) = self.get_claim_info(game_id);
            let mut caller_contribution = self.get_caller_contribution();

            assert(caller_contribution.score > 0, 'No reward available');
            assert(!caller_contribution.claimed, 'Already claimed');
            caller_contribution.claimed = true;
            let game_state: GameState = game_action.get_game();

            let reward = pot.confirmation_pot
                * caller_contribution.score
                / game_state.contribution_score_total;
            payment_system.pay_out_pot(caller_contribution.player_id, reward);
            game_action.set(caller_contribution);
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn get_claim_info(
            self: @ContractState, game_id: u128
        ) -> (GameAction, GamePot, PaymentSystem) {
            let game_action = GameAction { world: self.world_dispatcher.read(), game_id };
            game_action.assert_ended();
            (game_action, game_action.get_game::<GamePot>(), PaymentSystemTrait::new(@game_action))
        }
    }
}
