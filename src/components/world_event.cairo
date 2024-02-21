use starknet::ContractAddress;

use risingrevenant::components::game::Position;

use risingrevenant::utils::{calculate_distance};


#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct WorldEventSetup {
    #[key]
    game_id: u128,
    start_radius: u32,
    radius_increase: u32,
}

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct WorldEvent {
    #[key]
    game_id: u128,
    #[key]
    event_id: u128,
    position: Position,
    radius: u32,
    number: u32,
    block_number: u64,
    previous_event: u128,
    next_event: u128,
}
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct CurrentWorldEvent {
    #[key]
    game_id: u128,
    event_id: u128,
    position: Position,
    radius: u32,
    number: u32,
    block_number: u64,
    previous_event: u128,
}

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct OutpostImpacted {
    #[key]
    game_id: u128,
    #[key]
    event_id: u128,
    #[key]
    outpost_id: u32,
    impacted: bool,
}
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct OutpostVerified {
    #[key]
    game_id: u128,
    #[key]
    event_id: u128,
    #[key]
    outpost_id: Position,
    verified: bool,
}


#[generate_trait]
impl CurrentWorldEventImpl of CurrentWorldEventTrait {
    fn to_event(self: @CurrentWorldEvent, next_event: u128,) -> WorldEvent {
        WorldEvent {
            game_id: *self.game_id,
            event_id: *self.event_id,
            position: *self.position,
            radius: *self.radius,
            number: *self.number,
            block_number: *self.block_number,
            previous_event: *self.previous_event,
            next_event,
        }
    }
    fn is_impacted(self: @CurrentWorldEvent, outpost_position: Position) -> bool {
        let distance = calculate_distance(*self.position, outpost_position);
        distance <= *self.radius
    }
}
// mod EventType {
// const not_defined: u32 = 0;
// TODO: Define world event 
// const plague: u32 = 1;
// Goblin / Earthquake / Hurricane / Dragon / etc...
// }


