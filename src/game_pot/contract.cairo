use starknet::{
    ContractAddress,
    storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map},
};

#[starknet::interface]
trait IGamePot<TContractState> {
    fn increase_winner_pot(ref self: TContractState, amount: u256);
    fn increase_contributor_pot(ref self: TContractState, amount: u256);
    /// Allows the winner to claim their winnings from the game_pot
    fn claim_win(ref self: TContractState);
    /// Allows contributors to claim their contribution rewards
    fn claim_contribution(ref self: TContractState);
    /// Claims any remaining funds in the game_pot after all other claims
    fn claim_remainder(ref self: TContractState);
    /// Checks if the winner has claimed their prize
    fn win_claimed(self: @TContractState) -> bool;
    /// Checks if a specific contributor has claimed their reward
    fn contribution_claimed(self: @TContractState, user: ContractAddress) -> bool;
}

#[starknet::contract]
mod game_pot {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use dojo::world::WorldStorage;
    use rising_revenant::game_pot::{GamePotTrait, GamePotStorage};
    use rising_revenant::game::GameTrait;
    use rising_revenant::tokens::{erc20_balance_of, erc20_transfer};
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
    }

    #[storage]
    struct Storage {
        world_storage: WorldStorage,
        game_id: felt252,
        owner: ContractAddress,
    }

    #[abi(embed_v0)]
    impl IGamePotImpl of IGamePot<ContractState> {
        fn increase_contributor_pot(ref self: ContractState, amount: u256) {
            let mut world = self.world_storage.read();
            world.pay_into_contributors_pot(self.game_id.read(), get_caller_address(), amount);
        }

        fn increase_winner_pot(ref self: ContractState, amount: u256) {
            let mut world = self.world_storage.read();
            world.pay_into_winners_pot(self.game_id.read(), get_caller_address(), amount);
        }


        fn claim_win(ref self: ContractState) {
            let mut world = self.world_storage.read();
            let game_id = self.game_id.read();
            world.assert_game_claiming(game_id);
            let caller = get_caller_address();
            assert(caller == world.get_owner_of_winning_outpost(game_id), 'Not winner');
            world.payout_winners_pot(game_id, get_caller_address());
        }

        fn claim_contribution(ref self: ContractState) {
            let mut world = self.world_storage.read();
            let game_id = self.game_id.read();
            world.assert_game_claiming(game_id);
            world.payout_contributors_pot(self.game_id.read(), get_caller_address())
        }

        fn claim_remainder(ref self: ContractState) {
            let world = self.world_storage.read();
            assert(get_caller_address() == self.owner.read(), 'Not owner');
            let game_id = self.game_id.read();
            world.assert_game_claim_ended(game_id);
            let token_address = world.get_game_token_address(game_id);
            let balance = erc20_balance_of(token_address, get_contract_address());
            erc20_transfer(token_address, get_caller_address(), balance);
        }

        fn win_claimed(self: @ContractState) -> bool {
            self.world_storage.read().get_game_pot_winner_claimed(self.game_id.read())
        }

        fn contribution_claimed(self: @ContractState, user: ContractAddress) -> bool {
            self.world_storage.read().get_game_pot_contributor_claimed(self.game_id.read(), user)
        }
    }
}
