use starknet::ContractAddress;
use rising_revenant::{
    fortifications::Fortifications, contribution::ContributionEvent, world_events::WorldEventType
};

#[starknet::interface]
trait ISettings<TContractState> {
    fn set_map_size(ref self: TContractState, game_id: felt252, x: u16, y: u16);
    fn set_care_package_market(
        ref self: TContractState,
        game_id: felt252,
        target_price: u256,
        decay_constant_mag: u128,
        max_sellable_mag: u128,
        time_scale_mag: u128,
    );
    fn set_fortification_attributes(
        ref self: TContractState,
        game_id: felt252,
        event_type: WorldEventType,
        efficacy: Fortifications,
        mortalities: Fortifications
    );
    fn set_world_event_setup(
        ref self: TContractState,
        game_id: felt252,
        min_radius_sq: u32,
        max_radius_sq: u32,
        radius_sq_increase: u32,
        min_interval: u64,
        power: u64,
        decay: u64
    );
}

#[starknet::interface]
trait IGameActions<TContractState> {
    fn create_game(
        ref self: TContractState,
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
    ) -> felt252;
    fn end_game(ref self: TContractState, outpost_id: felt252);
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
        fortifications::models::{Fortifications, Fortification, FortificationAttributes},
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

        fn set_fortification_attributes(
            ref self: ContractState,
            game_id: felt252,
            event_type: WorldEventType,
            efficacy: Fortifications,
            mortalities: Fortifications
        ) {
            let mut world = self.world(default_namespace());
            world.assert_can_setup(game_id);
            world
                .write_model(
                    @FortificationAttributes { game_id, event_type, efficacy, mortalities }
                );
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
            let mut world = self.world(default_namespace());
            world.assert_can_setup(game_id);
            world
                .write_model(
                    @WorldEventSetup {
                        game_id,
                        min_radius_sq,
                        max_radius_sq,
                        radius_sq_increase,
                        min_interval,
                        power,
                        decay,
                    }
                );
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn assert_can_setup(self: @WorldStorage, game_id: felt252) {
            self.assert_admin();
            self.assert_game_created(game_id);
        }
        fn assert_admin(self: @WorldStorage) {
            assert(self.get_permissions('admin', get_caller_address()), 'Not an admin');
        }
        fn assert_game_created(self: @WorldStorage, game_id: felt252) {
            assert(
                get_block_timestamp() < self.get_prep_start(game_id), 'Game not in creation phase'
            );
        }
    }
}
