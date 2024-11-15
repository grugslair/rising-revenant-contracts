use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{jackpot::Claimant};


#[starknet::interface]
trait IJackpot<TContractState> {
    fn get_total_amount(self: @TContractState, game_id: felt252) -> u256;
    fn get_claimed_amount(self: @TContractState, game_id: felt252) -> u256;
    fn get_unclaimed_amount(self: @TContractState, game_id: felt252) -> u256;

    fn claim_win(ref self: TContractState, game_id: felt252);
    fn claim_contribution(ref self: TContractState, game_id: felt252);
    fn claim_dev(ref self: TContractState, game_id: felt252, receiver: ContractAddress);
    fn claim_remainder(ref self: TContractState, game_id: felt252);

    fn win_claimed(self: @TContractState, game_id: felt252) -> bool;
    fn contribution_claimed(self: @TContractState, game_id: felt252, user: ContractAddress) -> bool;
    fn dev_claimed(self: @TContractState, game_id: felt252) -> bool;
    fn remainder_claimed(self: @TContractState, game_id: felt252, claimant: Claimant) -> bool;

    fn get_win_amount(self: @TContractState, game_id: felt252) -> u256;
    fn get_contribution_amount(
        self: @TContractState, game_id: felt252, user: ContractAddress
    ) -> u256;
    fn get_dev_amount(self: @TContractState, game_id: felt252) -> u256;
}

#[dojo::contract]
mod jackpot_actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::WorldStorage;
    use rising_revenant::{
        game::GameTrait, jackpot::{JackpotTrait, Claimant}, finance::Finance,
        contribution::ContributionTrait, addresses::GetDispatcher,
        outposts::{IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait}, world::default_namespace,
    };
    use super::{IJackpot};

    #[abi(embed_v0)]
    impl IJackpotImpl of IJackpot<ContractState> {
        fn get_total_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_jackpot_total_amount(game_id)
        }
        fn get_claimed_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_jackpot_claimed(game_id).amount
        }
        fn get_unclaimed_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_jackpot_left(game_id)
        }
        fn claim_win(ref self: ContractState, game_id: felt252) {
            let mut world = self.world(default_namespace());
            world.assert_claiming(game_id);

            let winner = get_caller_address();
            assert(winner == world.get_winner(game_id), 'Not winner');

            world.claim(game_id, Claimant::Winner, winner);
        }
        fn claim_contribution(ref self: ContractState, game_id: felt252) {
            let mut world = self.world(default_namespace());
            world.assert_claiming(game_id);
            let user = get_caller_address();

            world.claim(game_id, Claimant::Contributor(user), user);
        }
        fn claim_dev(ref self: ContractState, game_id: felt252, receiver: ContractAddress) {
            let mut world = self.world(default_namespace());
            //TODO: permissions
            world.assert_prep_ended(game_id);

            world.claim(game_id, Claimant::Dev, receiver);
        }

        fn claim_remainder(ref self: ContractState, game_id: felt252) {
            //TODO: permissions
            let mut world = self.world(default_namespace());
            world.assert_ended(game_id);

            let caller = get_caller_address();
            let remainder = world.claim_remainder(game_id);

            world.send_amount(caller, remainder);
        }

        fn win_claimed(self: @ContractState, game_id: felt252) -> bool {
            let world = self.world(default_namespace());
            world.get_claimed(game_id, Claimant::Winner)
        }

        fn contribution_claimed(
            self: @ContractState, game_id: felt252, user: ContractAddress
        ) -> bool {
            let world = self.world(default_namespace());
            world.get_claimed(game_id, Claimant::Contributor(user))
        }

        fn dev_claimed(self: @ContractState, game_id: felt252) -> bool {
            let world = self.world(default_namespace());
            world.get_claimed(game_id, Claimant::Dev)
        }

        fn remainder_claimed(self: @ContractState, game_id: felt252, claimant: Claimant) -> bool {
            let world = self.world(default_namespace());
            world.get_jackpot_left(game_id) == 0
        }

        fn get_win_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_win_amount(game_id)
        }

        fn get_contribution_amount(
            self: @ContractState, game_id: felt252, user: ContractAddress
        ) -> u256 {
            let world = self.world(default_namespace());
            world.get_contribution_amount(game_id, user)
        }

        fn get_dev_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_dev_amount(game_id)
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn send_amount(ref self: WorldStorage, receiver: ContractAddress, amount: u256) {
            let mut finance = self.get_finance_account();
            finance.send(receiver, amount);
        }

        fn claim(
            ref self: WorldStorage, game_id: felt252, claimant: Claimant, receiver: ContractAddress
        ) {
            self.send_amount(receiver, self.claim_amount(game_id, claimant))
        }
    }
}
