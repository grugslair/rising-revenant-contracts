//! Outpost system implementations for managing outposts and their interactions in the game.
//! 
//! This module provides core functionality for:
//! * Creating and managing outposts
//! * Calculating and applying damage
//! * Managing fortification destruction
//! * Tracking active outposts and events

/// Variables used in damage calculations
/// * `efficacy` - The effectiveness of fortifications (0-100%)
/// * `decay` - Decay factor that reduces damage effectiveness
/// * `power` - Base power of the damage being applied
#[derive(Copy, Drop)]
struct DamageVars {
    efficacy: Fortifications,
    decay: u64,
    power: u64,
}

#[generate_trait]
impl OutpostsActiveImpl of OutpostsActiveTrait {
    /// Reduces the count of active outposts for a given game
    /// # Arguments
    /// * `game_id` - The ID of the game
    /// # Returns
    /// * The new count of active outposts
    /// # Panics
    /// * If there are no active outposts to reduce
    fn reduce_active_outposts(ref self: WorldStorage, game_id: felt252) -> u32 {
        let mut model = self.get_outposts_active(game_id);
        assert(model.active > 1, 'No active outposts');
        model.active -= 1;
        self.write_model(@model);
        model.active
    }
}


#[generate_trait]
impl OutpostEventImpl of OutpostEventTrait {
    /// Marks an event as applied to a specific outpost
    /// # Arguments
    /// * `outpost_id` - The ID of the outpost
    /// * `event_id` - The ID of the event
    /// # Panics
    /// * If the event was already applied
    fn set_event_applied(ref self: WorldStorage, outpost_id: felt252, event_id: felt252) {
        let mut model = self.get_outpost_event(outpost_id, event_id);
        assert(!model.applied, 'Event already applied');
        model.applied = true;
        self.write_model(@model);
    }
}


#[generate_trait]
impl DamageVarsImpl of DamageVarsTrait {
    /// Creates a new DamageVars instance from a WorldEvent and efficacy values
    #[inline(always)]
    fn get_damage_vars(self: @WorldEvent, efficacy: Fortifications) -> DamageVars {
        DamageVars { efficacy, decay: *self.decay, power: *self.power }
    }
    /// Calculates the actual damage based on fortification levels
    /// # Returns
    /// * Amount of damage to be applied
    #[inline(always)]
    fn get_damage(self: @DamageVars, fortifications: Fortifications) -> u64 {
        let total: u128 = (fortifications * *self.efficacy).sum().into();
        (total * (*self.power).into() / (total + (*self.decay).into())).try_into().unwrap()
    }
}


#[generate_trait]
impl OutpostImpl of OutpostTrait {
    /// Creates a new outpost in the game world
    /// # Arguments
    /// * `game_id` - The ID of the game
    /// * `owner` - The address of the outpost owner
    /// * `seed` - Random seed for position generation
    /// # Returns
    /// * The ID of the newly created outpost
    fn make_outpost(
        ref self: WorldStorage, game_id: felt252, owner: ContractAddress, seed: felt252
    ) -> felt252 {
        let mut outposts_active = self.get_outposts_active(game_id);
        let outpost = Outpost {
            id: hash_value(('outpost', game_id, outposts_active.active)),
            game_id,
            position: self.get_empty_point(game_id, get_hash_state(seed)),
            fortifications: Default::default(),
            hp: self.get_starting_hp(game_id),
        };
        self.write_model(@outpost);

        outposts_active.active += 1;
        self.write_model(@outposts_active);
        outpost.id
    }
    /// Applies damage to an outpost
    /// # Arguments
    /// * `event` - The damage calculation variables
    fn apply_damage(ref self: Outpost, event: DamageVars) {
        self.hp -= min(self.hp, event.get_damage(self.fortifications));
    }
    /// Applies destruction to outpost fortifications
    /// # Arguments
    /// * `mortalities` - The mortality rates for different fortification types
    /// * `hash_state` - Random state for destruction calculations
    fn apply_destruction(ref self: Outpost, mortalities: Fortifications, hash_state: HashState) {
        self.fortifications.apply_destruction(mortalities, hash_state);
    }
    /// Applies a world event to an outpost, including damage and destruction
    /// # Arguments
    /// * `event` - The world event to apply
    /// * `attributes` - Fortification attributes affecting the event
    /// * `hash_state` - Random state for calculations
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
    /// Checks if an outpost is still active (has HP)
    #[inline(always)]
    fn is_active(self: @Outpost) -> bool {
        (*self.hp).is_non_zero()
    }
    /// Verifies if an outpost is the winner of a game
    /// # Panics
    /// * If outpost is not in a game
    /// * If game hasn't ended
    /// * If outpost is not active
    fn assert_is_winner(self: @WorldStorage, outpost: Outpost) {
        assert(outpost.game_id.is_non_zero(), 'Outpost not in game');
        assert(self.get_active_outposts(outpost.game_id) == 1, 'Game not ended');
        assert(outpost.is_active(), 'Outpost not active');
    }
}

#[generate_trait]
impl OutpostFortificationsImpl of OutpostFortificationsTrait {
    /// Applies destruction to fortifications based on mortality rates
    /// # Arguments
    /// * `mortalities` - The mortality rates for each fortification type
    /// * `hash_state` - Random state for destruction calculations
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

/// Calculates protection provided by fortifications
/// # Arguments
/// * `fortifications` - Current fortification levels
/// * `efficacy` - Effectiveness of each fortification type
/// * `decay` - Decay factor
/// # Returns
/// * Protection value as a u64
fn get_protection(fortifications: Fortifications, efficacy: Fortifications, decay: u64) -> u64 {
    let total = (fortifications * efficacy).sum();
    total / (total + decay)
}

/// Calculates how many fortifications are destroyed
/// # Arguments
/// * `probability` - Chance of destruction (0-100%)
/// * `hash_state` - Random state for calculations
/// * `fortification` - Type of fortification
/// # Returns
/// * Number of fortifications destroyed
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
