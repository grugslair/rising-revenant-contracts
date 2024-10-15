use core::{
    hash::HashStateTrait, poseidon::{PoseidonTrait, HashState}, num::traits::Bounded,
    cmp::{min, max}
};
use starknet::ContractAddress;
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
use rising_revenant::{
    map::MapTrait, utils::{felt252_to_u128, clipped_felt252, ToHash, get_hash_state},
    fortifications::models::{
        Fortifications, FortificationsTrait, Fortification, FortificationAttributes,
    },
    outposts::{
        models::{
            Outpost, OutpostsActive, OutpostEvent, OutpostModels, OutpostsActiveStore,
            OutpostEventStore
        }
    },
    world_events::models::WorldEvent,
};
use cubit::f128::{Fixed, FixedTrait, ONE_u128};

#[derive(Copy, Drop)]
struct DamageVars {
    efficacy: Fortifications,
    decay: u64,
    power: u64,
}

#[generate_trait]
impl OutpostsActiveImpl of OutpostsActiveTrait {
    fn reduce_active_outposts(self: IWorldDispatcher, game_id: felt252) -> u32 {
        let mut model = self.get_outposts_active(game_id);
        assert(model.active > 1, 'No active outposts');
        model.active -= 1;
        model.set(self);
        model.active
    }
}


#[generate_trait]
impl OutpostEventImpl of OutpostEventTrait {
    fn set_event_applied(self: IWorldDispatcher, outpost_id: felt252, event_id: felt252) {
        let mut model = self.get_outpost_event(outpost_id, event_id);
        assert(!model.applied, 'Event already applied');
        model.applied = true;
        model.set(self);
    }
}


#[generate_trait]
impl DamageVarsImpl of DamageVarsTrait {
    #[inline(always)]
    fn get_damage_vars(self: @WorldEvent, efficacy: Fortifications) -> DamageVars {
        DamageVars { efficacy, decay: *self.decay, power: *self.power }
    }
    #[inline(always)]
    fn get_damage(self: @DamageVars, fortifications: Fortifications) -> u64 {
        let total: u128 = (fortifications * *self.efficacy).sum().into();
        (total * (*self.power).into() / (total + (*self.decay).into())).try_into().unwrap()
    }
}


#[generate_trait]
impl OutpostImpl of OutpostTrait {
    fn make_outpost(
        self: IWorldDispatcher, id: felt252, game_id: felt252, owner: ContractAddress, seed: felt252
    ) -> Outpost {
        Outpost {
            id,
            game_id,
            position: self.get_empty_point(game_id, get_hash_state(seed)),
            fortifications: Default::default(),
            hp: self.get_starting_hp(game_id),
        }
    }
    fn apply_damage(ref self: Outpost, event: DamageVars) {
        self.hp -= min(self.hp, event.get_damage(self.fortifications));
    }
    fn apply_destruction(ref self: Outpost, mortalities: Fortifications, hash_state: HashState) {
        self.fortifications.apply_destruction(mortalities, hash_state);
    }
    fn apply_event(
        ref self: Outpost,
        event: WorldEvent,
        attributes: FortificationAttributes,
        hash_state: HashState
    ) {
        self.apply_damage(event.get_damage_vars(attributes.efficacy));
        if self.is_active() {
            self.apply_destruction(attributes.mortalities, hash_state);
        };
    }
    #[inline(always)]
    fn is_active(self: @Outpost) -> bool {
        (*self.hp).is_non_zero()
    }
    fn assert_is_winner(self: @IWorldDispatcher, outpost: Outpost) {
        assert(outpost.game_id.is_non_zero(), 'Outpost not in game');
        assert(self.get_active_outposts(outpost.game_id) == 1, 'Game not ended');
        assert(outpost.is_active(), 'Outpost not active');
    }
}

#[generate_trait]
impl OutpostFortificationsImpl of OutpostFortificationsTrait {
    fn apply_destruction(
        ref self: Fortifications, mortalities: Fortifications, hash_state: HashState
    ) {
        self
            .palisades -=
                min(
                    self.palisades,
                    fortifications_destroyed(
                        mortalities.palisades, hash_state, Fortification::Palisade
                    )
                );
        self
            .trenches -=
                min(
                    self.trenches,
                    fortifications_destroyed(
                        mortalities.trenches, hash_state, Fortification::Trench
                    )
                );
        self
            .walls -=
                min(
                    self.walls,
                    fortifications_destroyed(mortalities.walls, hash_state, Fortification::Wall)
                );
        self
            .basements -=
                min(
                    self.basements,
                    fortifications_destroyed(
                        mortalities.basements, hash_state, Fortification::Basement
                    )
                );
    }
}

fn get_protection(fortifications: Fortifications, efficacy: Fortifications, decay: u64) -> u64 {
    let total = (fortifications * efficacy).sum();
    total / (total + decay)
}


fn fortifications_destroyed(
    probability: u64, hash_state: HashState, fortification: Fortification
) -> u64 {
    if probability == 0 {
        return 0;
    };
    if probability == Bounded::MAX {
        return Bounded::MAX;
    };
    let randomness = FixedTrait::new(
        clipped_felt252::<u64>(hash_state.to_hash(fortification)).into() + 1, false
    );
    let probability = FixedTrait::new(probability.into(), false);
    (randomness.ln() / probability.ln()).try_into().unwrap()
}
