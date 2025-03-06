use starknet::{ContractAddress};

#[starknet::interface]
trait IGamePot<TContractState> {
    // All the write methods here only effect the internal storage of this contract and not the
    // world storage

    /// Increases the winners' reward pot by the specified amount
    ///
    /// # Arguments
    /// * `amount` - Amount to increase the winners' pot by
    fn increase_winner_pot(ref self: TContractState, amount: u256);

    /// Increases the contributors' reward pot by the specified amount
    ///
    /// # Arguments
    /// * `amount` - Amount to increase the contributors' pot by
    fn increase_contributor_pot(ref self: TContractState, amount: u256);

    /// Claims winnings from the winners' pot
    fn claim_win(ref self: TContractState);

    /// Claims contribution rewards from the contributors' pot
    fn claim_contribution(ref self: TContractState);

    /// Claims any remaining unclaimed rewards
    fn claim_remainder(ref self: TContractState);

    /// Returns whether winning rewards have been claimed
    ///
    /// # Returns
    /// * `bool` - True if winnings have been claimed, false otherwise
    fn win_claimed(self: @TContractState) -> bool;

    /// Checks if a specific user has claimed their contribution rewards
    ///
    /// # Arguments
    /// * `user` - Address of the user to check
    ///
    /// # Returns
    /// * `bool` - True if user has claimed their contribution, false otherwise
    fn contribution_claimed(self: @TContractState, user: ContractAddress) -> bool;

    /// Gets the address of the token used for rewards
    ///
    /// # Returns
    /// * `ContractAddress` - Address of the token contract
    fn get_token_address(self: @TContractState) -> ContractAddress;

    /// Gets the current amount in the winners' bonus pot
    ///
    /// # Returns
    /// * `u256` - Current amount in winners' pot
    fn get_winners_bonus_pot(self: @TContractState) -> u256;

    /// Gets the current amount in the contributors' bonus pot
    ///
    /// # Returns
    /// * `u256` - Current amount in contributors' pot
    fn get_contributors_bonus_pot(self: @TContractState) -> u256;
}

#[starknet::contract]
mod game_pot {
    use starknet::{
        ContractAddress, get_caller_address, get_contract_address,
        storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map},
    };
    use dojo::world::WorldStorage;
    use rising_revenant::game_pot::GamePotStorage;
    use rising_revenant::game::GameTrait;
    use rising_revenant::tokens::{erc20_balance_of, erc20_transfer, erc20_transfer_from};
    use rising_revenant::contribution::Contribution;
    use super::IGamePot;

    impl WorldStorageStore of starknet::StorePacking<WorldStorage, (ContractAddress, felt252)> {
        fn pack(value: WorldStorage) -> (ContractAddress, felt252) {
            (value.dispatcher.contract_address, value.namespace_hash)
        }

        fn unpack(value: (ContractAddress, felt252)) -> WorldStorage {
            let (contract_address, namespace_hash) = value;
            WorldStorage {
                dispatcher: dojo::world::IWorldDispatcher { contract_address }, namespace_hash,
            }
        }
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        world_address: ContractAddress,
        namespace_hash: felt252,
        game_id: felt252,
        owner: ContractAddress,
        token_address: ContractAddress,
    ) {
        self
            .world_storage
            .write(
                {
                    WorldStorage {
                        dispatcher: dojo::world::IWorldDispatcher {
                            contract_address: world_address,
                        },
                        namespace_hash,
                    }
                },
            );
        self.game_id.write(game_id);
        self.owner.write(owner);
        self.token_address.write(token_address);
    }

    #[storage]
    struct Storage {
        world_storage: WorldStorage,
        game_id: felt252,
        owner: ContractAddress,
        token_address: ContractAddress,
        winners: u256,
        contributors: u256,
        winners_claimed: bool,
        contributors_claimed: Map<ContractAddress, bool>,
    }

    #[abi(embed_v0)]
    impl IGamePotImpl of IGamePot<ContractState> {
        fn increase_contributor_pot(ref self: ContractState, amount: u256) {
            self.world_storage.read().assert_game_not_ended(self.game_id.read());
            erc20_transfer_from(
                self.token_address.read(), get_caller_address(), get_contract_address(), amount,
            );
            self.contributors.write(self.contributors.read() + amount);
        }

        fn increase_winner_pot(ref self: ContractState, amount: u256) {
            self.world_storage.read().assert_game_not_ended(self.game_id.read());
            erc20_transfer_from(
                self.token_address.read(), get_caller_address(), get_contract_address(), amount,
            );
            self.winners.write(self.winners.read() + amount);
        }

        fn claim_win(ref self: ContractState) {
            let mut world = self.world_storage.read();
            let game_id = self.game_id.read();
            world.assert_game_claiming(game_id);
            assert(!self.winners_claimed.read(), 'Already claimed');
            self.winners_claimed.write(true);

            let caller = get_caller_address();
            assert(caller == world.get_owner_of_winning_outpost(game_id), 'Not winner');
            let amount = self.winners.read() + world.get_winners_purchases_amount(game_id);
            erc20_transfer(self.token_address.read(), caller, amount);
        }

        fn claim_contribution(ref self: ContractState) {
            let mut world = self.world_storage.read();
            let game_id = self.game_id.read();
            world.assert_game_claiming(game_id);
            let caller = get_caller_address();
            let contributor = self.contributors_claimed.entry(caller);
            assert(!contributor.read(), 'Already claimed');
            contributor.write(true);

            let total = self.contributors.read() + world.get_contributors_purchases_amount(game_id);
            let amount = world.get_contribution_portion(game_id, caller, total);
            erc20_transfer(self.token_address.read(), caller, amount);
        }

        fn claim_remainder(ref self: ContractState) {
            let caller = get_caller_address();
            assert(get_caller_address() == self.owner.read(), 'Not owner');
            self.world_storage.read().assert_game_claim_ended(self.game_id.read());

            let token_address = self.token_address.read();
            let balance = erc20_balance_of(token_address, get_contract_address());
            erc20_transfer(token_address, caller, balance);
        }

        fn win_claimed(self: @ContractState) -> bool {
            self.winners_claimed.read()
        }

        fn contribution_claimed(self: @ContractState, user: ContractAddress) -> bool {
            self.contributors_claimed.entry(user).read()
        }

        fn get_token_address(self: @ContractState) -> ContractAddress {
            self.token_address.read()
        }

        fn get_winners_bonus_pot(self: @ContractState) -> u256 {
            self.winners.read()
        }

        fn get_contributors_bonus_pot(self: @ContractState) -> u256 {
            self.contributors.read()
        }
    }
}
