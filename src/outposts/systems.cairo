use core::{cmp::min, poseidon::HashState, num::traits::Bounded};
use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use cubit::f128::{Fixed, FixedTrait};
use rising_revenant::{
    world_events::{WorldEvent, models::WorldEventEffectTrait},
    fortifications::{Fortifications, Fortification, FortificationsTrait},
    outposts::{Outpost, models::{OutpostsActive, OutpostSetup, OutpostEvent}},
    hash::{hash_value, make_hash_state}, map::MapTrait, core::BoundedT,
};

//! Outpost system implementations for managing outposts and their interactions in the game.
//!
//! This module provides core functionality for:
//! * Creating and managing outposts
//! * Calculating and applying damage
//! * Managing fortification destruction
//! * Tracking active outposts and events

/// Variables used in damage calculations
/// * `efficacy` - The effectiveness of fortifications (0-100%)
/// * `f_value` - Decay factor that reduces damage effectiveness
/// * `power` - Base power of the damage being applied

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
impl OutpostImpl of OutpostTrait {
    #[inline(always)]
    fn get_outpost(self: @WorldStorage, id: felt252) -> Outpost {
        self.read_model(id)
    }

    /// Retrieves outpost setup configuration for a game
    fn get_outpost_setup(self: @WorldStorage, game_id: felt252) -> OutpostSetup {
        self.read_model(game_id)
    }

    /// Retrieves an event associated with a specific outpost
    fn get_outpost_event(
        self: @WorldStorage, outpost_id: felt252, event_id: felt252
    ) -> OutpostEvent {
        self.read_model((outpost_id, event_id))
    }

    /// Retrieves the active outposts counter for a game
    fn get_outposts_active(self: @WorldStorage, game_id: felt252) -> OutpostsActive {
        self.read_model(game_id)
    }

    /// Gets the initial HP value for outposts in a game
    fn get_starting_hp(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<OutpostSetup>::ptr_from_keys(game_id), selector!("hp"))
    }

    /// Gets the count of active outposts in a game
    fn get_active_outposts(self: @WorldStorage, game_id: felt252) -> u32 {
        self.read_member(Model::<OutpostsActive>::ptr_from_keys(game_id), selector!("active"))
    }

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
            position: self.get_empty_point(game_id, make_hash_state(seed)),
            fortifications: Default::default(),
            hp: self.get_starting_hp(game_id),
        };
        self.write_model(@outpost);

        outposts_active.active += 1;
        self.write_model(@outposts_active);
        outpost.id
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

    /// Applies damage to an outpost
    /// # Arguments
    /// * `event` - The damage calculation variables
    fn apply_damage(ref self: Outpost, event: @WorldEvent) {
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
    fn apply_event(ref self: Outpost, event: @WorldEvent, hash_state: HashState) {
        self.apply_damage(event);
        if self.is_active() {
            self.apply_destruction(*event.mortalities, hash_state);
        };
    }
    /// Checks if an outpost is still active (has HP)
    #[inline(always)]
    fn is_active(self: @Outpost) -> bool {
        (*self.hp).is_non_zero()
    }
}


/// Calculates protection provided by fortifications
/// # Arguments
/// * `fortifications` - Current fortification levels
/// * `efficacy` - Effectiveness of each fortification type
/// * `f_value` - Decay factor
/// # Returns
/// * Protection value as a u64
fn get_protection(fortifications: Fortifications, efficacy: Fortifications, f_value: u64) -> u64 {
    let total = (fortifications * efficacy).sum();
    total / (total + f_value)
}

