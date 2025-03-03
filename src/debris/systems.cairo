use super::super::hash::UpdateHashToU128;
use core::{poseidon::HashState, hash::HashStateTrait};
use dojo::world::WorldStorage;

use rising_revenant::{
    fortifications::Fortifications, seed::SeedProbability, outposts::{Outpost, OutpostTrait},
    core::ToNonZero,
};

use super::{DebrisStorage, Debris};

fn debris_calculation(ref seed: u128) -> u256 {
    let val = seed.get_value(1000.non_zero());
}

#[generate_trait]
impl DebrisImpl of DebrisTrait {
    fn calculate_fortification_debris(
        self: @WorldStorage, game_id: felt252, destroyed: Fortifications, mut seed: u128,
    ) -> Debris {
        Debris { stone: 0, wood: 0, obsidian: 0 }
    }
    fn fortifications_to_debris(
        ref self: WorldStorage, outpost: @Outpost, destroyed: Fortifications, randomness: HashState,
    ) {
        let game_id = *outpost.game_id;
        let debris = self.calculate_fortification_debris(game_id, destroyed, randomness.to_u128());

        self.mint_debris(game_id, self.get_outpost_owner(game_id, *outpost.id), debris);
    }
}
