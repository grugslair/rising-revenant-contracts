use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct WorldEvent {
    #[key]
    game_id: u32,
    #[key]
    entity_id: u128,
    // TODO: see detail in EventType
    // event_type: u32,
    x: u32,
    y: u32,
    radius: u32,
    // How many outpost has been destroyed by this event
    destroy_count: u32,
    block_number: u64
}
// mod EventType {
// const not_defined: u32 = 0;
// TODO: Define world event 
// const plague: u32 = 1;
// Goblin / Earthquake / Hurricane / Dragon / etc...
// }

// #[generate_trait]
// impl WorldEventImpl of OutpostTrait {
// fn assert_existed(self: Outpost) {
// assert(self.status != OutpostStatus::not_created, 'Outpost not exist');
// }
// }

// This will track the outpost destroied by each event
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct WorldEventTracker {
    #[key]
    game_id: u32,
    #[key]
    event_id: u128,
    outpost_id: u128
}