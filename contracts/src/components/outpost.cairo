use starknet::ContractAddress;
use realmsrisingrevenant::constants::OUTPOST_MAX_REINFORCEMENT;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Outpost {
    #[key]
    game_id: u32,
    #[key]
    entity_id: u128,
    revenant_id: u128,
    owner: ContractAddress,
    name_outpost: felt252,
    x: u32,
    y: u32,
    lifes: u32,
    shield: u8, //Alex
    reinforcement_count: u32,
    status: u32,
    last_affect_event_id: u128
}

// use to confirm if there's duplicate outpost at a same position
#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct OutpostPosition {
    #[key]
    game_id: u32,
    #[key]
    x: u32,
    #[key]
    y: u32,
    entity_id: u128
}

mod OutpostStatus {
    const not_created: u32 = 0;
    const created: u32 = 1;
// const destroyed: u32 = 2;
}

#[generate_trait]
impl OutpostImpl of OutpostTrait {
    fn assert_existed(self: Outpost) {
        assert(self.status != OutpostStatus::not_created, 'Outpost not exist');
        assert(self.lifes > 0, 'Outpost has been destroyed');
    }

    fn assert_can_reinforcement(self: Outpost) {
        self.assert_existed(); //Alex
        assert(self.reinforcement_count <= OUTPOST_MAX_REINFORCEMENT, 'reach reinforce limit');
    }

    //Alex
    // does cairo have else if?
    fn get_shields_amount(self: Outpost) -> u8 {
        let reinforcements = self.lifes;

        if (reinforcements < 3) {
            return 0;
        } else if (reinforcements < 6) {
            return 1;
        } else if (reinforcements < 10) {
            return 2;
        } else if (reinforcements < 14) {
            return 3;
        } else if (reinforcements < 20) {
            return 4;
        } else if (reinforcements == 20) {
            return 5;
        } else {
            return 7; //error 
        }
    }
}
