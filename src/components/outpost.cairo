use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::player::{PlayerInfo,};
use risingrevenant::components::game::{Dimensions, Position, PositionTrait};
use risingrevenant::components::world_event::{WorldEvent};

use risingrevenant::utils::random::{Random};
use risingrevenant::utils::{calculate_distance};


#[derive(Model, Copy, Drop, Serde, SerdeLen)]
struct Outpost {
    #[key]
    game_id: u128,
    #[key]
    position: Position,
    owner: ContractAddress,
    life: u32,
    reinforces_remaining: u32,
    status: u8,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct OutpostMarket {
    #[key]
    game_id: u128,
    price: u256,
    available: u32,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct OutpostSetup {
    #[key]
    game_id: u128,
    life: u32,
    max_reinforcements: u32,
}


mod OutpostStatus {
    const not_created: u8 = 0;
    const active: u8 = 1;
    const destroyed: u8 = 2;
}


#[generate_trait]
impl OutpostImpl of OutpostTrait {
    fn assert_exists(self: @Outpost) {
        assert(*self.status != OutpostStatus::not_created, 'Outpost not exist');
        assert(*self.life > 0, 'Outpost has been destroyed');
    }
    fn assert_active(self: @Outpost) {
        assert(*self.status == OutpostStatus::active, 'Outpost has been destroyed');
    }
    fn is_impacted_by_event(self: @Outpost, event: WorldEvent) -> bool {
        let distance = calculate_distance(*self.position, event.position);
        distance <= event.radius
    }
}
