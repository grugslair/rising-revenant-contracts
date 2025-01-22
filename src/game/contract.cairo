use starknet::ContractAddress;
use rising_revenant::world_events::WorldEventVars;

/// Interface for core game actions
///
/// Provides functions to create and manage game instances, including
/// game creation, termination, and winner determination.
#[starknet::interface]
trait IGameActions<TContractState> {
    /// Creates a new game instance with specified phase timings
    /// * `prep_start` - Start time of preparation phase
    /// * `prep_stop` - End time of preparation phase
    /// * `events_start` - Start time of events phase
    /// * `claim_period` - Duration of claim period
    /// Returns: game_id - Unique identifier for the created game
    fn create_game(
        ref self: TContractState,
        name: ByteArray,
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
        map_size_x: u16,
        map_size_y: u16,
        outpost_price: u256,
        outpost_hp: u64,
        outpost_uri: ByteArray,
        care_package_target_price_mag: u128, // value / 10^18 * 2^64
        care_package_decay_constant_mag: u128,
        care_package_max_sellable: u64,
        care_package_time_scale_mag: u128,
        care_package_uri: ByteArray,
        event_min_interval: u64,
        dragon_vars: WorldEventVars,
        goblin_vars: WorldEventVars,
        earthquake_vars: WorldEventVars,
    ) -> felt252;

    /// Ends a game instance
    /// * `outpost_id` - ID of the winning outpost
    fn end_game(ref self: TContractState, outpost_id: felt252);

    /// Retrieves the winner's address for a completed game
    /// * `game_id` - Unique identifier for the game
    /// Returns: ContractAddress of the winner
    fn get_winner(self: @TContractState, game_id: felt252) -> ContractAddress;
}

#[dojo::contract]
mod game_actions {
    use starknet::{get_block_timestamp, ContractAddress, get_caller_address};
    use dojo::{model::{ModelStorage}, world::WorldStorage};
    use super::IGameActions;
    use rising_revenant::{
        map::MapTrait, Permissions,
        game::{GamePhases, GamePhase, Winner, GameStorage, GamePhasesTrait, GameTrait},
        outposts::{OutpostTrait, OutpostStorage}, care_packages::CarePackageTrait,
        world_events::{WorldEventVars, WorldEventStorage, WorldEventType}, world::default_namespace,
        utils::uuid,
    };

    #[abi(embed_v0)]
    impl GameActionsImp of IGameActions<ContractState> {
        fn create_game(
            ref self: ContractState,
            name: ByteArray,
            prep_start: u64,
            prep_stop: u64,
            events_start: u64,
            claim_period: u64,
            map_size_x: u16,
            map_size_y: u16,
            outpost_price: u256,
            outpost_hp: u64,
            outpost_uri: ByteArray,
            care_package_target_price_mag: u128,
            care_package_decay_constant_mag: u128,
            care_package_max_sellable: u64,
            care_package_time_scale_mag: u128,
            care_package_uri: ByteArray,
            event_min_interval: u64,
            dragon_vars: WorldEventVars,
            goblin_vars: WorldEventVars,
            earthquake_vars: WorldEventVars,
        ) -> felt252 {
            let caller = get_caller_address();
            let mut world = self.world(default_namespace());
            let game_id = uuid();

            world.new_game_phases(game_id, prep_start, prep_stop, events_start, claim_period);
            world.set_map_size(game_id, map_size_x, map_size_y);

            world.set_event_min_interval(game_id, event_min_interval);
            world.set_event_vars(game_id, WorldEventType::Dragon, dragon_vars);
            world.set_event_vars(game_id, WorldEventType::Goblins, goblin_vars);
            world.set_event_vars(game_id, WorldEventType::Earthquake, earthquake_vars);
            // TODO: Create tokens
            world
                .setup_outpost_market(
                    game_id, @name, outpost_uri, caller, outpost_price, outpost_hp
                );
            world
                .setup_care_package_market(
                    game_id,
                    @name,
                    care_package_uri,
                    caller,
                    care_package_target_price_mag,
                    care_package_decay_constant_mag,
                    care_package_max_sellable,
                    care_package_time_scale_mag,
                );
            world.set_game_name(game_id, name);

            game_id
        }

        fn end_game(ref self: ContractState, outpost_id: felt252) {
            let mut world = self.world(default_namespace());
            let outpost = world.get_outpost(outpost_id);
            let mut game_phases = world.get_game_phases(outpost.game_id);
            game_phases.assert_playing();
            game_phases.ended = get_block_timestamp();
            world.write_model(@game_phases);
            world.write_model(@Winner { game_id: outpost.game_id, outpost_id: outpost.id, });
        }

        fn get_winner(self: @ContractState, game_id: felt252) -> ContractAddress {
            let world = self.world(default_namespace());
            world.get_winner(game_id)
        }
    }

    /// Private implementation trait containing helper functions for game management
    ///
    /// Provides utility functions for access control and game state validation
    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        /// Verifies that the caller has permission to setup game parameters
        /// * `game_id` - Unique identifier for the game
        /// # Panics
        /// * If caller is not an admin
        /// * If game is not in creation phase
        fn assert_can_setup(self: @WorldStorage, game_id: felt252) {
            self.assert_admin();
            self.assert_game_created(game_id);
        }

        /// Verifies that the caller has admin privileges
        /// # Panics
        /// * If caller does not have admin permissions
        fn assert_admin(self: @WorldStorage) {
            assert(self.get_permissions('admin', get_caller_address()), 'Not an admin');
        }

        /// Verifies that a game exists and is in the creation phase
        /// * `game_id` - Unique identifier for the game
        /// # Panics
        /// * If game has progressed beyond creation phase
        fn assert_game_created(self: @WorldStorage, game_id: felt252) {
            assert(
                get_block_timestamp() < self.get_prep_start(game_id), 'Game not in creation phase'
            );
        }
    }
}
