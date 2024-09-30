use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState}, num::traits::Bounded};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::{
    game::systems::MapTrait, utils::{felt252_to_u128, clipped_felt252, ToHash}, core::SubBounded,
    fortifications::models::{
        Fortifications, FortificationsTrait, Fortification, FortificationAttributes,
        FortificationAttributesStore
    },
    outposts::models::{Outpost}, world_events::models::CurrentEvent,
};
use cubit::f128::{Fixed, FixedTrait, ONE_u128};

#[derive(Copy, Drop)]
struct DamageVars {
    efficacy: Fortifications,
    decay: u64,
    power: u64,
}


#[generate_trait]
impl DamageVarsImpl of DamageVarsTrait {
    #[inline(always)]
    fn get_damage_vars(self: @CurrentEvent, efficacy: Fortifications) -> DamageVars {
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
    fn make_outpost(self: IWorldDispatcher, game_id: felt252, seed: felt252) -> Outpost {
        let hash_state = PoseidonTrait::new().update(seed);
        let hp = 0;
        Outpost {
            id: seed,
            game_id,
            position: self.get_empty_point(game_id, hash_state),
            fortifications: Default::default(),
            hp,
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
        event: CurrentEvent,
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
