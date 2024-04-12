use risingrevenant::components::world_event::EventDefenseTrait;
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use risingrevenant::components::player::{PlayerInfo,};
use risingrevenant::components::game::{Dimensions, Position, PositionTrait};
use risingrevenant::components::world_event::{CurrentWorldEvent, EventType};
use risingrevenant::components::reinforcement::{ReinforcementType};

use risingrevenant::utils::random::{RandomTrait};
use risingrevenant::utils::{calculate_distance};


#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct Outpost {
    #[key]
    game_id: u128,
    #[key]
    position: Position,
    owner: ContractAddress,
    life: u32,
    reinforces_remaining: u32,
    reinforcement_type: ReinforcementType,
    status: u8,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct OutpostMarket {
    #[key]
    game_id: u128,
    price: u256,
    max_sellable: u32,
    max_per_player: u32
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct OutpostSetup {
    #[key]
    game_id: u128,
    life: u32,
    max_reinforcements: u32,
}

struct OutpostsSold {
    #[key]
    game_id: u128,
    sold: u32,
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
    fn is_impacted_by_event(self: @Outpost, event: CurrentWorldEvent) -> bool {
        let distance = calculate_distance(*self.position, event.position);
        distance <= event.radius
    }
    fn apply_world_event_damage(ref self: Outpost, event: CurrentWorldEvent) -> u32 {
        // find better way of doing thing

        let (probability, mut damage) = event
            .event_type
            .get_defense_probability(self.reinforcement_type);
        if probability == 255 {
            return 0;
        } else if probability != 0 {
            let mut random = RandomTrait::new();
            if random.next() < probability {
                return 0;
            }
        };
        self.reinforcement_type = ReinforcementType::None;
        if damage > self.life {
            damage = self.life;
        }
        self.life -= damage;
        return damage;
    }
}


#[derive(Serde, Copy, Drop, Introspect, PartialEq, Print)]
enum OutpostEventStatus {
    NotImpacted,
    UnVerified,
    Verified,
}

impl OutpostEventStatusFelt252 of Into<OutpostEventStatus, felt252> {
    fn into(self: OutpostEventStatus) -> felt252 {
        match self {
            OutpostEventStatus::NotImpacted => 0,
            OutpostEventStatus::UnVerified => 1,
            OutpostEventStatus::Verified => 2,
        }
    }
}
