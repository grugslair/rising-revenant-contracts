use array::{ArrayTrait, SpanTrait};
use dojo::world::{Context, IWorldDispatcherTrait};
use risingrevenant::components::Position;
use risingrevenant::components::WorldEvent;
use serde::Serde;
use starknet::ContractAddress;

fn emit(ctx: Context, name: felt252, values: Span<felt252>) {
    let mut keys = array::ArrayTrait::new();
    keys.append(name);
    ctx.world.emit(keys, values);
}


#[derive(Drop, Serde)]
struct SetWorldEvent {
    world_event: WorldEvent,
    position: Position
}
