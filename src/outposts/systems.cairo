use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState}, num::traits::Bounded};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::{
    map::MapTrait, utils::{felt252_to_u128, clipped_felt252, ToHash, get_hash_state},
    core::SubBounded,
    fortifications::models::{
        Fortifications, FortificationsTrait, Fortification, FortificationAttributes,
        FortificationAttributesStore
    },
    outposts::models::{
        Outpost, OutpostsActive, OutpostEvent, OutpostStore, OutpostsActiveStore, OutpostEventStore,
        OutpostSetupStore
    },
    world_events::models::{CurrentEvent, WorldEventSetup},
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
        let mut model = OutpostsActiveStore::get(self, game_id);
        assert(model.active > 1, 'No active outposts');
        model.active -= 1;
        model.set(self);
        model.active
    }
    fn get_active_outposts(self: @IWorldDispatcher, game_id: felt252) -> u32 {
        OutpostsActiveStore::get_active(*self, game_id)
    }
}

#[generate_trait]
impl OutpostEventImpl of OutpostEventTrait {
    fn event_applied(self: @IWorldDispatcher, outpost_id: felt252, event_id: felt252) {
        OutpostEventStore::get_applied(*self, outpost_id, event_id);
    }

    fn set_event_applied(self: IWorldDispatcher, outpost_id: felt252, event_id: felt252) {
        OutpostEvent { outpost_id, event_id, applied: true, }.set(self);
    }
}


#[generate_trait]
impl DamageVarsImpl of DamageVarsTrait {
    #[inline(always)]
    fn get_damage_vars(self: @WorldEventSetup, efficacy: Fortifications) -> DamageVars {
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
    fn get_outpost(self: @IWorldDispatcher, id: felt252) -> Outpost {
        OutpostStore::get(*self, id)
    }
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
        let damage = event.get_damage(self.fortifications);
        self.hp.subeq_bounded(damage);
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
    fn get_starting_hp(self: @IWorldDispatcher, game_id: felt252) -> u64 {
        OutpostSetupStore::get_hp(*self, game_id)
    }
}

#[generate_trait]
impl OutpostFortificationsImpl of OutpostFortificationsTrait {
    fn apply_destruction(
        ref self: Fortifications, mortalities: Fortifications, hash_state: HashState
    ) {
        self
            .palisades
            .subeq_bounded(
                fortifications_destroyed(mortalities.palisades, hash_state, Fortification::Palisade)
            );
        self
            .trenches
            .subeq_bounded(
                fortifications_destroyed(mortalities.trenches, hash_state, Fortification::Trench)
            );
        self
            .walls
            .subeq_bounded(
                fortifications_destroyed(mortalities.walls, hash_state, Fortification::Wall)
            );
        self
            .basements
            .subeq_bounded(
                fortifications_destroyed(mortalities.basements, hash_state, Fortification::Basement)
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
