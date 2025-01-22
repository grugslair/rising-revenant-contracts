use core::{cmp::min, poseidon::HashState, num::traits::Bounded, poseidon::poseidon_hash_span};
use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use cubit::f128::{Fixed, FixedTrait};
use rising_revenant::{
    world_events::{WorldEvent, WorldEventStorage, models::WorldEventEffectTrait},
    fortifications::{Fortifications, Fortification, FortificationsTrait},
    outposts::{Outpost, OutpostStorage}, game::GameStorage,
    tokens::{
        IERC721MintableDispatcher, IERC721MintableDispatcherTrait, deploy_erc721_mintable,
        erc721_owner_of
    },
    hash::{hash_value, make_hash_state}, map::{MapTrait, PointTrait}, core::BoundedT,
    world::WorldTrait
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
        let active = self.get_active_outposts(game_id) - 1;
        assert(active > 0, 'No active outposts');
        self.set_outposts_active(game_id, active);
        active
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
        assert(!self.get_outpost_event_applied(outpost_id, event_id), 'Event already applied');
        self.set_outpost_event_applied(outpost_id, event_id);
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
        ref self: WorldStorage, game_id: felt252, owner: ContractAddress, hp: u64, seed: felt252
    ) -> felt252 {
        let outposts_active = self.get_active_outposts(game_id) + 1;
        let id = poseidon_hash_span(['outpost', game_id, outposts_active.into()].span());
        let position = self.get_empty_point(game_id, make_hash_state(seed));

        self.new_outpost(id, game_id, position, hp);
        self.set_outpost_at_position(game_id, position, id);
        self.set_outposts_active(game_id, outposts_active);
        id
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

    fn event_effecting_outpost(self: @WorldStorage, outpost: @Outpost) -> bool {
        let event = self.get_current_event(*outpost.game_id);
        let radius_sq = self.get_last_event_radius_sq(*outpost.game_id, event.event_type);
        outpost.position.in_range(event.position, radius_sq)
            && !self.get_outpost_event_applied(*outpost.id, event.event_id)
    }

    fn increase_outpost_fortification(
        ref self: WorldStorage, outpost_id: felt252, fortification: Fortification, amount: u64
    ) {
        self
            .set_outpost_fortification(
                outpost_id,
                fortification,
                self.get_outpost_fortification(outpost_id, fortification) + amount
            );
    }

    fn get_outpost_owner(
        self: @WorldStorage, game_id: felt252, outpost_id: felt252
    ) -> ContractAddress {
        erc721_owner_of(self.get_outpost_token_address(game_id), outpost_id.into())
    }

    fn deploy_outpost_token(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        base_uri: ByteArray,
        admin: ContractAddress,
    ) -> ContractAddress {
        deploy_erc721_mintable(
            self.get_class_hash('erc721_mintable'),
            game_id,
            format!("RR Outpost {}", game_name),
            "RROP",
            base_uri,
            admin,
            self.get_contract_address("outpost_actions")
        )
    }

    fn setup_outpost_market(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        base_uri: ByteArray,
        admin: ContractAddress,
        price: u256,
        hp: u64
    ) {
        self
            .set_outpost_setup(
                game_id, self.deploy_outpost_token(game_id, game_name, base_uri, admin), price, hp
            );
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

