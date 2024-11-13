use starknet::ContractAddress;
use rising_revenant::{
    fortifications::Fortifications, contribution::ContributionEvent, world_events::WorldEventType
};

#[dojo::interface]
trait ISettings<TContractState> {
    fn set_map_size(ref self: ContractState, game_id: felt252, x: u16, y: u16);
    fn set_care_package_market(
        ref self: ContractState,
        game_id: felt252,
        target_price: u256,
        decay_constant_mag: u128,
        max_sellable_mag: u128,
        time_scale_mag: u128,
    );
    fn set_fortification_attributes(
        ref self: ContractState,
        game_id: felt252,
        event_type: WorldEventType,
        efficacy: Fortifications,
        mortalities: Fortifications
    );
    fn set_world_event_setup(
        ref self: ContractState,
        game_id: felt252,
        min_radius_sq: u32,
        max_radius_sq: u32,
        radius_sq_increase: u32,
        min_interval: u64,
        power: u64,
        decay: u64
    );
}

#[dojo::interface]
trait IGameActions<TContractState> {
    fn create_game(
        ref self: ContractState,
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
    ) -> felt252;
    fn end_game(ref self: ContractState, outpost_id: felt252);
    fn get_winner(self: @ContractState, game_id: felt252) -> ContractAddress;
}

#[dojo::contract]
mod game_actions {
    use starknet::{get_block_timestamp, ContractAddress, get_caller_address};
    use dojo::model::Model;
    use super::{ISettings, IGameActions};
    use rising_revenant::{
        addresses::{GetDispatcher}, Permissions, map::{Point, MapSize, MapSizeStore},
        game::{
            models::{GamePhases, GamePhase, GamePhasesStore, Winner, WinnerStore}, GamePhasesTrait,
            GameTrait,
        },
        care_packages::models::{CarePackageMarket, CarePackageMarketStore}, outposts::OutpostModels,
        fortifications::models::{
            Fortifications, Fortification, FortificationAttributes, FortificationAttributesStore
        },
        world_events::{models::{WorldEventSetup, WorldEventSetupStore}, WorldEventType},
        contribution::{ContributionValue, ContributionEvent}, utils::hash_value,
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
            let game_id = hash_value(('game', world.uuid()));
            GamePhases { game_id, prep_start, prep_stop, events_start, claim_period, ended: 0, }
                .set(world);
            game_id
        }
        fn end_game(ref self: ContractState, outpost_id: felt252) {
            let outpost = world.get_outpost(outpost_id);
            let mut game_phases = world.get_game_phases(outpost.game_id);
            game_phases.assert_playing();
            game_phases.ended = get_block_timestamp();
            game_phases.set(world);
            Winner { game_id: outpost.game_id, outpost_id: outpost.id, }.set(world);
        }

        fn get_winner(self: @ContractState, game_id: felt252) -> ContractAddress {
            world.get_winner(game_id)
        }
    }

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn set_map_size(ref self: ContractState, game_id: felt252, x: u16, y: u16) {
            world.assert_can_setup(game_id);
            MapSize { game_id, size: Point { x, y } }.set(world);
        }

        fn set_care_package_market(
            ref self: ContractState,
            game_id: felt252,
            target_price: u256,
            decay_constant_mag: u128,
            max_sellable_mag: u128,
            time_scale_mag: u128,
        ) {
            world.assert_can_setup(game_id);
            let start_time = world.get_prep_start(game_id);
            CarePackageMarket {
                game_id,
                target_price,
                decay_constant_mag,
                max_sellable_mag,
                time_scale_mag,
                start_time,
                sold: 0,
            }
                .set(world);
        }

        fn set_fortification_attributes(
            ref self: ContractState,
            game_id: felt252,
            event_type: WorldEventType,
            efficacy: Fortifications,
            mortalities: Fortifications
        ) {
            world.assert_can_setup(game_id);
            FortificationAttributes { game_id, event_type, efficacy, mortalities, }.set(world);
        }

        fn set_world_event_setup(
            ref self: ContractState,
            game_id: felt252,
            min_radius_sq: u32,
            max_radius_sq: u32,
            radius_sq_increase: u32,
            min_interval: u64,
            power: u64,
            decay: u64
        ) {
            world.assert_can_setup(game_id);
            WorldEventSetup {
                game_id,
                min_radius_sq,
                max_radius_sq,
                radius_sq_increase,
                min_interval,
                power,
                decay,
            }
                .set(world);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn assert_can_setup(self: @WorldStorage, game_id: felt252) {
            self.assert_admin();
            self.assert_game_created(game_id);
        }
        fn assert_admin(self: @WorldStorage
            assert(self.get_permissions('admin', get_caller_address()), 'Not an admin');
        }
        fn assert_game_created(self: @WorldStorage, game_id: felt252) {
            assert(
                get_block_timestamp() < self.get_prep_start(game_id), 'Game not in creation phase'
            );
        }
    }
}
