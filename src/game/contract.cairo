use starknet::{ContractAddress, ClassHash};
use rising_revenant::{world_events::WorldEventSetup, game::ClassHashVariant};

/// Interface for core game actions
///
/// Provides functions to create and manage game instances, including
/// game creation, termination, and winner determination.
#[starknet::interface]
trait IGameActions<TContractState> {
    /// Ends a game instance
    /// * `outpost_id` - ID of the winning outpost
    fn claim_game_win(ref self: TContractState, outpost_id: felt252);

    /// Retrieves the winner's address for a completed game
    /// * `game_id` - Unique identifier for the game
    /// Returns: ContractAddress of the winner
    fn get_winning_outpost(self: @TContractState, game_id: felt252) -> felt252;

    fn get_user_contribution(
        self: @TContractState, game_id: felt252, user: ContractAddress,
    ) -> u128;

    fn get_total_contribution(self: @TContractState, game_id: felt252) -> u128;
}

#[starknet::interface]
trait IGameAdmin<TContractState> {
    fn set_is_admin(ref self: TContractState, user: ContractAddress, has: bool);
    fn set_is_creator(ref self: TContractState, user: ContractAddress, has: bool);

    fn get_is_admin(self: @TContractState, user: ContractAddress) -> bool;
    fn get_is_creator(self: @TContractState, user: ContractAddress) -> bool;

    fn set_class_hash(ref self: TContractState, variant: ClassHashVariant, class_hash: ClassHash);
    fn get_class_hash(self: @TContractState, variant: ClassHashVariant) -> ClassHash;

    fn set_vrf_address(ref self: TContractState, contract_address: ContractAddress);
    fn get_vrf_address(self: @TContractState) -> ContractAddress;

    /// Initializes and creates a new game with the specified parameters.
    /// All time are in seconds and timestamps are in seconds since epoch.
    ///
    /// # Parameters
    /// - `name`: The name of the game (`ByteArray`).
    /// - `prep_start`: The timestamp when the preparation phase starts in seconds since epoch
    /// (`u64`).
    /// - `prep_stop`: The timestamp when the preparation phase ends (`u64`).
    /// - `events_start`: The timestamp when the game events start (`u64`).
    /// - `claim_period`: The duration of the claim period after the game ends (`u64`).
    /// - `game_erc20_token`: The address of the ERC20 token used in the game (`ContractAddress`).
    /// - `game_beneficiary`: The address of the game beneficiary (`ContractAddress`).
    /// - `map_size_x`: The size of the game map in the x-dimension (`u16`).
    /// - `map_size_y`: The size of the game map in the y-dimension (`u16`).
    /// - `outpost_price`: The price of an outpost (`u256`).
    /// - `outpost_hp`: The health points of an outpost (`u64`).
    /// - `outpost_uri`: The URI for the outpost (`ByteArray`).
    /// - `care_package_target_price_mag`: The target price magnitude for care packages (`u128`).
    /// - `care_package_decay_constant_mag`: The decay constant magnitude for care packages
    /// (`u128`).
    /// - `care_package_max_sellable`: The maximum number of sellable care packages (`u64`).
    /// - `care_package_time_scale_mag`: The time scale magnitude for care packages (`u128`).
    /// - `care_package_uri`: The URI for the care packages (`ByteArray`).
    /// - `event_min_interval`: The minimum interval between events (`u64`).
    /// - `dragon_vars`: The setup variables for dragon events (`WorldEventSetup`).
    /// - `goblin_vars`: The setup variables for goblin events (`WorldEventSetup`).
    /// - `earthquake_vars`: The setup variables for earthquake events (`WorldEventSetup`).
    /// - `winner_purchase_permille`: The permille for winner purchases (`u16`).
    /// - `contribution_purchase_permille`: The permille for contribution purchases (`u16`).
    /// - `event_created_contribution_points`: The contribution points for created new world events
    /// (`u128`).
    /// - `event_applied_contribution_points`: The contribution points for appling events to
    /// outposts (`u128`).
    /// - `outpost_destroyed_contribution_points`: The contribution points for destroying outposts
    ///
    ///
    /// # Returns
    /// - `felt252`: The unique identifier for the created game.
    fn create_game(
        ref self: TContractState,
        name: ByteArray,
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
        game_erc20_token: ContractAddress,
        game_beneficiary: ContractAddress,
        map_size_x: u16,
        map_size_y: u16,
        outpost_price: u256,
        max_outposts: u32,
        outpost_hp: u64,
        outpost_uri: ByteArray,
        care_package_target_price_mag: u128,
        care_package_decay_constant_mag: u128,
        care_package_max_sellable: u64,
        care_package_time_scale_mag: u128,
        care_package_uri: ByteArray,
        event_min_interval: u64,
        dragon_vars: WorldEventSetup,
        goblin_vars: WorldEventSetup,
        earthquake_vars: WorldEventSetup,
        winner_purchase_permille: u16,
        contribution_purchase_permille: u16,
        event_created_contribution_points: u128,
        event_applied_contribution_points: u128,
        outpost_destroyed_contribution_points: u128,
    ) -> felt252;
}

#[dojo::contract]
mod game_actions {
    use core::num::traits::Zero;
    use starknet::{
        get_block_timestamp, ContractAddress, get_caller_address, ClassHash, get_tx_info,
    };
    use dojo::{model::{ModelStorage}, world::WorldStorage};
    use super::{IGameActions, IGameAdmin};
    use rising_revenant::{
        map::MapTrait, permissions::GamePermissions, fortifications::FortificationTokenTrait,
        game::{GamePhases, GamePhase, Winner, GameStorage, GameTrait, ClassHashVariant},
        contribution::Contribution, outposts::{OutpostTrait, OutpostStorage},
        care_packages::CarePackageTrait, game_pot::GamePotTrait,
        world_events::{WorldEventSetup, WorldEventStorage, WorldEventType},
        world::default_namespace, utils::uuid, vrf::VRF_ADDRESS_SELECTOR,
    };

    fn dojo_init(ref self: ContractState) {
        let mut world = self.world(default_namespace());

        let admin = get_tx_info().unbox().account_contract_address;
        world.set_admin_permission(admin, true);
    }

    #[abi(embed_v0)]
    impl GameActionsImp of IGameActions<ContractState> {
        fn claim_game_win(ref self: ContractState, outpost_id: felt252) {
            let mut world = self.world(default_namespace());
            let outpost = world.get_outpost(outpost_id);
            let game_id = outpost.game_id;

            world.assert_is_winner(outpost);
            world.assert_game_playing(game_id);

            world.set_game_ended(game_id);
            world.set_winning_outpost(game_id, outpost_id);
        }

        fn get_winning_outpost(self: @ContractState, game_id: felt252) -> felt252 {
            self.world(default_namespace()).get_winning_outpost(game_id)
        }

        fn get_user_contribution(
            self: @ContractState, game_id: felt252, user: ContractAddress,
        ) -> u128 {
            self.world(default_namespace()).get_contribution_amount(game_id, user)
        }

        fn get_total_contribution(self: @ContractState, game_id: felt252) -> u128 {
            self.world(default_namespace()).get_contribution_amount(game_id, Zero::zero())
        }
    }

    #[abi(embed_v0)]
    impl IGameAdminImpl of IGameAdmin<ContractState> {
        fn create_game(
            ref self: ContractState,
            name: ByteArray,
            prep_start: u64,
            prep_stop: u64,
            events_start: u64,
            claim_period: u64,
            game_erc20_token: ContractAddress,
            game_beneficiary: ContractAddress,
            map_size_x: u16,
            map_size_y: u16,
            outpost_price: u256,
            max_outposts: u32,
            outpost_hp: u64,
            outpost_uri: ByteArray,
            care_package_target_price_mag: u128,
            care_package_decay_constant_mag: u128,
            care_package_max_sellable: u64,
            care_package_time_scale_mag: u128,
            care_package_uri: ByteArray,
            event_min_interval: u64,
            dragon_vars: WorldEventSetup,
            goblin_vars: WorldEventSetup,
            earthquake_vars: WorldEventSetup,
            winner_purchase_permille: u16,
            contribution_purchase_permille: u16,
            event_created_contribution_points: u128,
            event_applied_contribution_points: u128,
            outpost_destroyed_contribution_points: u128,
        ) -> felt252 {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();
            world.assert_creator_permission(caller);
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
                    game_id, @name, outpost_uri, caller, outpost_price, max_outposts, outpost_hp,
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
            world.deploy_fortification_tokens(game_id, @name, caller);
            world
                .setup_game_pot(
                    game_id,
                    game_beneficiary,
                    winner_purchase_permille,
                    contribution_purchase_permille,
                    game_erc20_token,
                );
            world
                .set_contribution_values(
                    game_id,
                    event_created_contribution_points,
                    event_applied_contribution_points,
                    outpost_destroyed_contribution_points,
                );
            world.set_game_name(game_id, name);

            game_id
        }

        fn set_class_hash(
            ref self: ContractState, variant: ClassHashVariant, class_hash: ClassHash,
        ) {
            let mut world = self.world(default_namespace());
            world.assert_admin_permission(get_caller_address());
            world.set_class_hash(variant, class_hash);
        }

        fn get_class_hash(self: @ContractState, variant: ClassHashVariant) -> ClassHash {
            let world = self.world(default_namespace());
            world.get_class_hash(variant)
        }

        fn set_is_admin(ref self: ContractState, user: ContractAddress, has: bool) {
            let mut world = self.world(default_namespace());
            world.assert_admin_permission(get_caller_address());
            world.set_admin_permission(user, has);
        }
        fn set_is_creator(ref self: ContractState, user: ContractAddress, has: bool) {
            let mut world = self.world(default_namespace());
            world.assert_admin_permission(get_caller_address());
            world.set_creator_permission(user, has);
        }

        fn get_is_admin(self: @ContractState, user: ContractAddress) -> bool {
            let world = self.world(default_namespace());
            world.has_admin_permission(user)
        }

        fn get_is_creator(self: @ContractState, user: ContractAddress) -> bool {
            let world = self.world(default_namespace());
            world.has_creator_permission(user)
        }

        fn set_vrf_address(ref self: ContractState, contract_address: ContractAddress) {
            let mut world = self.world(default_namespace());
            world.assert_admin_permission(get_caller_address());
            world.set_game_contract_address(VRF_ADDRESS_SELECTOR, contract_address);
        }
        fn get_vrf_address(self: @ContractState) -> ContractAddress {
            let world = self.world(default_namespace());
            world.get_game_contract_address(VRF_ADDRESS_SELECTOR)
        }
    }
}
