use realmsrisingrevenant::constants::OUTPOST_MAX_COUNT;
use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Revenant {
    #[key]
    game_id: u32,
    #[key]
    entity_id: u128,
    outpost_id: u128,
    owner: ContractAddress,
    first_name_idx: u32,
    last_name_idx: u32,
    outpost_count: u32,
    status: u32
}

mod RevenantStatus {
    const not_start: u32 = 0;
    const started: u32 = 1;
// TODO: More status, like outpost has reach limit / has been beated / etc...
}

#[generate_trait]
impl RevenantImpl of RevenantTrait {
    fn assert_started(self: Revenant) {
        assert(self.status == RevenantStatus::started, 'Revenant has not been created');
    }

    fn assert_can_create_outpost(self: Revenant) {
        assert(self.status == RevenantStatus::started, 'Revenant has not been created');
        assert(self.outpost_count < OUTPOST_MAX_COUNT, 'You have reach the limit');
    }
}
