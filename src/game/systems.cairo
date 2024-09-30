use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState}
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::{
    models::{Point, GeneratePointTrait}, game::models::{Map, MapStore, GameSetup, GameSetupStore}
};

#[generate_trait]
impl MapImpl of MapTrait {
    fn is_position_empty(self: @IWorldDispatcher, game_id: felt252, position: Point) -> bool {
        MapStore::get_outpost(*self, game_id, position).is_zero()
    }
    fn get_empty_point(self: @IWorldDispatcher, game_id: felt252, mut hash: HashState) -> Point {
        let map_size: Point = GameSetupStore::get_map_size(*self, game_id);

        loop {
            let point = map_size.generate_point(hash.finalize());
            if self.is_position_empty(game_id, point) {
                break point;
            }
            hash = hash.update('butter');
        }
    }
}
