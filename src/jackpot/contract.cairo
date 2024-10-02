use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;

#[dojo::interface]
trait IJackpot<TContractState> {
    fn get_jackpot_total(world: @IWorldDispatcher, game_id: felt252) -> u256;
    fn claim_win(ref world: IWorldDispatcher, game_id: felt252);
    fn claim_contribution(ref world: IWorldDispatcher, game_id: felt252);
    fn claim_dev(ref world: IWorldDispatcher, game_id: felt252, receiver: ContractAddress);
    fn jackpot_claimed(world: @IWorldDispatcher, game_id: felt252) -> bool;
    fn contribution_claimed(
        world: @IWorldDispatcher, game_id: felt252, user: ContractAddress
    ) -> bool;
    fn dev_claimed(world: @IWorldDispatcher, game_id: felt252) -> bool;
    fn get_win_amount(world: @IWorldDispatcher, game_id: felt252) -> u256;
    fn get_contribution_amount(
        world: @IWorldDispatcher, game_id: felt252, user: ContractAddress
    ) -> u256;
    fn get_dev_amount(world: @IWorldDispatcher, game_id: felt252) -> u256;
}

#[dojo::contract]
mod jackpot_actions {
    use starknet::{ContractAddress, get_caller_address};
    use rising_revenant::{jackpot::JackpotTrait, finance::Finance, game::GameTrait};
    use super::{IJackpot};

    #[abi(embed_v0)]
    impl IJackpotActionsImpl of IJackpot<ContractState> {
        fn get_jackpot_total(world: @IWorldDispatcher, game_id: felt252) -> u256 {
            self.get_jackpot_total(game_id)
        }
        fn claim_win(ref world: IWorldDispatcher, game_id: felt252) {
            world.assert_claiming(game_id);
            let winner = get_caller_address();
            let amount = world.get_win_amount(game_id);

            world.send_amount(game_id, winner, amount);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn send_amount(
            self: IWorldDispatcher, game_id: felt252, receiver: ContractAddress, amount: u256
        ) {
            let finance = self.get_finance_account(game_id);
            finance.send(receiver, amount);
            self.claim_jackpot_amount(game_id, amount);
        }
    }
}
