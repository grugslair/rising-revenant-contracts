use starknet::ContractAddress;
use rising_revenant::{
    fortifications::Fortifications, contribution::ContributionEvent, world_events::WorldEventType
};

/// Interface for managing game settings and configuration
///
/// This interface provides functions to configure various aspects of the game,
/// including map size, care package market parameters, fortification attributes,
/// and world event settings.
#[starknet::interface]
trait ISettings<TContractState> {
    /// Sets the map dimensions for a specific game
    /// * `game_id` - Unique identifier for the game
    /// * `x` - Width of the map
    /// * `y` - Height of the map
    fn set_map_size(ref self: TContractState, game_id: felt252, x: u16, y: u16);

    /// Configures the care package market parameters
    /// * `game_id` - Unique identifier for the game
    /// * `target_price` - Base price for care packages
    /// * `decay_constant_mag` - Rate at which price decays
    /// * `max_sellable_mag` - Maximum number of care packages that can be sold
    /// * `time_scale_mag` - Time scaling factor for price calculations
    fn set_care_package_market(
        ref self: TContractState,
        game_id: felt252,
        target_price: u256,
        decay_constant_mag: u128,
        max_sellable_mag: u128,
        time_scale_mag: u128,
    );

    /// Sets the effectiveness and mortality rates for different fortification types
    /// * `game_id` - Unique identifier for the game
    /// * `event_type` - Type of world event
    /// * `efficacy` - Effectiveness values for each fortification type
    /// * `mortalities` - Mortality rates for each fortification type
    /// * `min_radius_sq` - Minimum squared radius for events
    /// * `max_radius_sq` - Maximum squared radius for events
    /// * `radius_sq_increase` - Rate of radius increase
    /// * `min_interval` - Minimum time between events
    /// * `power` - Event power level
    /// * `f_value` - Event f_value
    fn set_world_event_setup(
        ref self: TContractState,
        game_id: felt252,
        event_type: WorldEventType,
        efficacy: Fortifications,
        mortalities: Fortifications,
        min_radius_sq: u32,
        max_radius_sq: u32,
        radius_sq_increase: u32,
        min_interval: u64,
        power: u64,
        f_value: u64
    );
}

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
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
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
    use super::{ISettings, IGameActions};
    use rising_revenant::{
        addresses::{GetDispatcher}, Permissions, map::{Point, MapSize},
        game::{models::{GamePhases, GamePhase, Winner}, GamePhasesTrait, GameTrait,},
        care_packages::models::{CarePackageMarket}, outposts::OutpostModels,
        fortifications::models::{Fortifications, Fortification},
        world_events::{models::{WorldEventSetup}, WorldEventType},
        contribution::{ContributionValue, ContributionEvent}, utils::hash_value,
        world::{default_namespace, WorldTrait}
    };

    #[abi(embed_v0)]
    impl GameActionsImp of IGameActions<ContractState> {
        fn create_game(
            ref self: ContractState,
            prep_start: u64,
            prep_stop: u64,
            events_start: u64,
            claim_period: u64,
        ) -> felt252 {
            let mut world = self.world(default_namespace());
            let game_id = hash_value(('game', world.uuid()));
            world
                .write_model(
                    @GamePhases {
                        game_id, prep_start, prep_stop, events_start, claim_period, ended: 0,
                    }
                );

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

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn set_map_size(ref self: ContractState, game_id: felt252, x: u16, y: u16) {
            let mut world = self.world(default_namespace());
            world.assert_can_setup(game_id);
            world.write_model(@MapSize { game_id, size: Point { x, y } });
        }

        fn set_care_package_market(
            ref self: ContractState,
            game_id: felt252,
            target_price: u256,
            decay_constant_mag: u128,
            max_sellable_mag: u128,
            time_scale_mag: u128,
        ) {
            let mut world = self.world(default_namespace());
            world.assert_can_setup(game_id);
            let start_time = world.get_prep_start(game_id);
            world
                .write_model(
                    @CarePackageMarket {
                        game_id,
                        target_price,
                        decay_constant_mag,
                        max_sellable_mag,
                        time_scale_mag,
                        start_time,
                        sold: 0,
                    }
                );
        }

        fn set_world_event_setup(
            ref self: ContractState,
            game_id: felt252,
            event_type: WorldEventType,
            efficacy: Fortifications,
            mortalities: Fortifications,
            min_radius_sq: u32,
            max_radius_sq: u32,
            radius_sq_increase: u32,
            min_interval: u64,
            power: u64,
            f_value: u64
        ) {
            let mut world = self.world(default_namespace());
            world.assert_can_setup(game_id);
            world
                .write_model(
                    @WorldEventSetup {
                        game_id,
                        event_type,
                        efficacy,
                        mortalities,
                        min_radius_sq,
                        max_radius_sq,
                        radius_sq_increase,
                        min_interval,
                        power,
                        f_value,
                    }
                );
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
