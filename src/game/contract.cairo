#[dojo::interface]
trait IGameActions<TContractState> {
    fn create(ref world: IWorldDispatcher);
    fn claim_win(ref world: IWorldDispatcher, game_id: felt252);
    fn set_care_package_market(
        ref world: IWorldDispatcher,
        game_id: felt252,
        target_price: u256,
        decay_constant_mag: u128,
        max_sellable_mag: u128,
        time_scale_mag: u128,
    );
    fn set_fortification_attributes(
        ref world: IWorldDispatcher,
        game_id: felt252,
        event_type: WorldEventType,
        efficacy: Fortifications,
        mortalities: Fortifications
    );
    fn set_world_event_setup(
        ref world: IWorldDispatcher,
        game_id: felt252,
        min_radius_sq: u32,
        max_radius_sq: u32,
        radius_sq_increase: u32,
        min_interval: u64,
        power: u64,
        decay: u64
    );
    fn set_contribution_value(
        ref world: IWorldDispatcher, game_id: felt252, event: ContributionEvent, value: u128,
    );
}

#[dojo::interface]
trait ISettings<TContractState> {}

#[dojo::contract]
mod game_actions {
    use starknet::get_block_timestamp;
    use rising_revenant::{
        addresses::{GetDispatcher}
        Permissions, models::Point, game::models::{GameSetup, GameSetupTrait, MapSize, WinnerTrait},
        care_packages::models::CarePackageMarket,
        fortifications::models::{Fortifications, Fortification, FortificationAttributes},
        world_events::models::WorldEventSetup, contribution::{ContributionValue, ContributionEvent},
        outposts::{
            models::OutpostsActiveTrait, IOutpostTokenDispatcher, IOutpostTokenDispatcherTrait
        },
    };

    #[abi(embed_v0)]
    impl SettingsImpl of ISettings<ContractState> {
        fn create_game(
            self: IWorldDispatcher,
            map_size: Point,
            prep_start: u64,
            prep_stop: u64,
            events_start: u64
        ) -> felt252 {
            let game_id = hash_value(('game', self.uuid()));
            GameSetup { game_id, map_size, prep_start, prep_stop, events_start, ended: false, }
                .set(self);
            game_id
        }

        fn set_map_size(ref world: IWorldDispatcher, game_id: felt252, x: u32, y: u32) {
            world.assert_can_setup(game_id);
            MapSize { game_id, size: Point { x, y } }.set(world);
        }

        fn set_care_package_market(
            ref world: IWorldDispatcher,
            game_id: felt252,
            target_price: u256,
            decay_constant_mag: u128,
            max_sellable_mag: u128,
            time_scale_mag: u128,
        ) {
            world.assert_can_setup(game_id);
            CarePackageMarket {
                game_id, target_price, decay_constant_mag, max_sellable_mag, time_scale_mag,
            }
                .set(world);
        }

        fn set_fortification_attributes(
            ref world: IWorldDispatcher,
            game_id: felt252,
            event_type: WorldEventType,
            efficacy: Fortifications,
            mortalities: Fortifications
        ) {
            world.assert_can_setup(game_id);
            FortificationAttributes { game_id, event_type, efficacy, mortalities, }.set(world);
        }

        fn set_world_event_setup(
            ref world: IWorldDispatcher,
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

        fn set_contribution_value(
            ref world: IWorldDispatcher, game_id: felt252, event: ContributionEvent, value: u128,
        ) {
            world.assert_can_setup(game_id);
            ContributionValue { game_id, event, value }.set(world);
        }

        fn end_game(ref world: IWorldDispatcher, outpost_id: felt252) {
            let outpost = world.get_outpost(outpost_id);
            let mut game_phases = self.get_game_phases(outpost.game_id);
            game_phases.assert_playing();
            game_phases.ended = get_block_timestamp();
            game_phases.set(world);
            Winner {game_id: outpost.game_id,outpost_id: outpost.id,}.set(world);
        }

        fn get_winner(self: IWorldDispatcher, game_id: felt252) -> felt252 {
            self.get_winner(game_id)
        }
    }

    impl PrivateImpl of PrivateTrait {
        fn assert_can_setup(self: IWorldDispatcher, game_id: felt252) {
            self.assert_admin();
            self.assert_game_created(game_id);
        }
        fn assert_admin(self: IWorldDispatcher) {
            assert(self.get_permissions('admin', get_caller_address()), 'Not an admin');
        }
        fn assert_game_created(self: IWorldDispatcher, game_id: felt252) {
            assert(
                get_block_timestamp() < GameSetupStore::prep_start(self, game_id),
                'Game not in creation phase'
            );
        }
    }
}
