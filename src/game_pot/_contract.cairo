use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::{game_pot::Claimant};


/// Interface for managing game_pot claims and retrieving game_pot information
#[starknet::interface]
trait IGamePot<TContractState> {
    fn increase_game_pot_amount(ref self: TContractState, amount: u256);
    /// Returns the total amount in the game_pot for a given game
    fn get_total_amount(self: @TContractState, game_id: felt252) -> u256;
    /// Returns the total amount that has been claimed from the game_pot
    fn get_claimed_amount(self: @TContractState, game_id: felt252) -> u256;
    /// Returns the remaining unclaimed amount in the game_pot
    fn get_unclaimed_amount(self: @TContractState, game_id: felt252) -> u256;

    /// Allows the winner to claim their winnings from the game_pot
    fn claim_win(ref self: TContractState, game_id: felt252);
    /// Allows contributors to claim their contribution rewards
    fn claim_contribution(ref self: TContractState, game_id: felt252);
    /// Allows dev team to claim their allocated portion
    fn claim_dev(ref self: TContractState, game_id: felt252, receiver: ContractAddress);
    /// Claims any remaining funds in the game_pot after all other claims
    fn claim_remainder(ref self: TContractState, game_id: felt252);

    /// Checks if the winner has claimed their prize
    fn win_claimed(self: @TContractState, game_id: felt252) -> bool;
    /// Checks if a specific contributor has claimed their reward
    fn contribution_claimed(self: @TContractState, game_id: felt252, user: ContractAddress) -> bool;
    /// Checks if the dev portion has been claimed
    fn dev_claimed(self: @TContractState, game_id: felt252) -> bool;
    /// Checks if the remainder has been claimed for a specific claimant type
    fn remainder_claimed(self: @TContractState, game_id: felt252, claimant: Claimant) -> bool;

    /// Returns the amount available to be claimed by the winner
    fn get_win_amount(self: @TContractState, game_id: felt252) -> u256;
    /// Returns the amount available to be claimed by a specific contributor
    fn get_contribution_amount(
        self: @TContractState, game_id: felt252, user: ContractAddress,
    ) -> u256;
    /// Returns the amount allocated for the dev team
    fn get_dev_amount(self: @TContractState, game_id: felt252) -> u256;
}

#[dojo::contract]
mod game_pot_actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::WorldStorage;
    use rising_revenant::{
        game::{GameTrait, GameStorage}, game_pot::{GamePotTrait, GamePotStorage, Claimant},
        finance::Finance, contribution::Contribution, addresses::GetDispatcher,
        world::default_namespace,
    };
    use super::{IGamePot};

    // #[storage]
    // struct Storage {
    //     world_dispatcher: dojo::world::IWorldDispatcher,
    //     claim_end: u64,
    //     token_address: ContractAddress,
    //     owner: ContractAddress,
    // }

    // #[constructor]
    // fn constructor(ref self: ContractState, world_address: ContractAddress,) {
    //     self
    //         .world_dispatcher
    //         .write(dojo::world::IWorldDispatcher { contract_address: world_address });
    // }

    // #[generate_trait]
    // impl IWorldDispatcherInternalImpl of IWorldDispatcherInternalTrait {
    //     fn world(
    //         self: @ContractState, namespace: @ByteArray
    //     ) -> dojo::world::storage::WorldStorage {
    //         dojo::world::WorldStorageTrait::new(self.world_dispatcher.read(), namespace)
    //     }
    // }

    #[abi(embed_v0)]
    impl IGamePotImpl of IGamePot<ContractState> {
        fn increase_game_pot_amount(ref self: ContractState, amount: u256) {
            let mut world = self.world(default_namespace());
            let game_id = world.get_caller_game();
            assert(game_id.is_non_zero(), 'Caller is not in a game');
            world.increase_game_pot_total(game_id, amount);
        }

        fn get_total_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_game_pot_total_amount(game_id)
        }
        fn get_claimed_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_game_pot_claimed(game_id).amount
        }
        fn get_unclaimed_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_game_pot_left(game_id)
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
            self: @ContractState, game_id: felt252, user: ContractAddress,
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
            world.get_game_pot_left(game_id) == 0
        }

        fn get_win_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_win_amount(game_id)
        }

        fn get_contribution_amount(
            self: @ContractState, game_id: felt252, user: ContractAddress,
        ) -> u256 {
            let world = self.world(default_namespace());
            world.get_contribution_amount(game_id, user)
        }

        fn get_dev_amount(self: @ContractState, game_id: felt252) -> u256 {
            let world = self.world(default_namespace());
            world.get_dev_amount(game_id)
        }
    }

    /// Private implementation for handling game_pot payments and claims
    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        /// Sends the specified amount to a receiver address using the finance account
        /// # Arguments
        /// * `receiver` - The address that will receive the funds
        /// * `amount` - The amount of tokens to send
        fn send_amount(ref self: WorldStorage, receiver: ContractAddress, amount: u256) {
            let mut finance = self.get_finance_account();
            finance.send(receiver, amount);
        }

        /// Claims an amount for a specific claimant and sends it to the receiver
        /// # Arguments
        /// * `game_id` - The ID of the game to claim from
        /// * `claimant` - The type of claimant (Winner, Contributor, or Dev)
        /// * `receiver` - The address that will receive the claimed amount
        fn claim(
            ref self: WorldStorage, game_id: felt252, claimant: Claimant, receiver: ContractAddress,
        ) {
            self.send_amount(receiver, self.claim_amount(game_id, claimant))
        }
    }
}
