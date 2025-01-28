use starknet::{
    ContractAddress,
    storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map,}
};

#[starknet::interface]
trait IJackpot<TContractState> {
    /// Returns total amount of the jackpot
    fn get_jackpot_total(self: @TContractState) -> u256;
    /// Allows the winner to claim their winnings from the jackpot
    fn claim_win(ref self: TContractState);
    /// Allows contributors to claim their contribution rewards
    fn claim_contribution(ref self: TContractState);
    /// Claims any remaining funds in the jackpot after all other claims
    fn claim_remainder(ref self: TContractState);
    /// Checks if the winner has claimed their prize
    fn win_claimed(self: @TContractState) -> bool;
    /// Checks if a specific contributor has claimed their reward
    fn contribution_claimed(self: @TContractState, user: ContractAddress) -> bool;
}


#[starknet::contract]
mod jackpot_actions {
    use starknet::{ContractAddress, get_caller_address};
    use rising_revenant::jackpot::{JackpotTrait, JackpotStorage};
    use rising_revenant::game::GameTrait;
    use super::IJackpot;

    #[generate_trait]
    impl IWorldDispatcherInternalImpl of IWorldDispatcherInternalTrait {
        fn world(self: @ContractState) -> dojo::world::storage::WorldStorage {
            dojo::world::WorldStorageTrait::new(
                self.world_dispatcher.read(), @self.namespace.read()
            )
        }
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        namespace: ByteArray,
        world_address: ContractAddress,
        game_id: felt252,
    ) {
        self.namespace.write(namespace);
        self
            .world_dispatcher
            .write(dojo::world::IWorldDispatcher { contract_address: world_address });
        self.game_id.write(game_id);
    }

    #[storage]
    struct Storage {
        world_dispatcher: dojo::world::IWorldDispatcher,
        dev_per_mille: u16,
        creator_per_mille: u16,
        namespace: ByteArray,
        game_id: felt252,
        owner: ContractAddress,
    }

    #[abi(embed_v0)]
    impl IJackpotImpl of IJackpot<ContractState> {
        fn get_jackpot_total(self: @ContractState) -> u256 {
            self.world().get_jackpot_total(self.game_id.read())
        }

        fn claim_win(ref self: ContractState) {
            let mut world = self.world();
            world.claim_winning_payout(self.game_id.read());
        }

        fn claim_contribution(ref self: ContractState) {
            let mut world = self.world();
            world.claim_contributor_payout(self.game_id.read(), get_caller_address())
        }

        fn claim_remainder(ref self: ContractState) {
            let world = self.world();
            assert(get_caller_address() == self.owner.read(), 'Not owner');
            let game_id = self.game_id.read();
            world.assert_game_claim_ended(game_id);
            let amount = world.get_self_current_amount(game_id);
        }

        fn win_claimed(self: @ContractState) -> bool {
            self.world().get_jackpot_winner_claimed(self.game_id.read())
        }

        fn contribution_claimed(self: @ContractState, user: ContractAddress) -> bool {
            self.world().get_jackpot_contributor_claimed(self.game_id.read(), user)
        }
    }
}
