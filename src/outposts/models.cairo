use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::{
    map::Point, fortifications::{Fortification, FortificationTrait, Fortifications},
};


/// OutpostSetup model represents configuration parameters for outposts in a game
///
/// Setup Model
///
/// # Arguments
/// * `game_id` - Unique identifier for the game instance (key field)
/// * `price` - Cost to create an outpost in this game
/// * `token_address` - Contract address of the token used for payments
/// * `max_outposts` - Maximum number of outposts allowed in the game
/// * `hp` - Initial health points for each outpost
///
/// The struct defines core setup values that determine how outposts function
/// within a specific game instance, including economic and gameplay parameters.
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostSetup {
    #[key]
    game_id: felt252,
    price: u256,
    token_address: ContractAddress,
    max_outposts: u32,
    hp: u64,
}

#[derive(Drop, Serde)]
struct Outpost {
    #[key]
    id: felt252,
    game_id: felt252,
    position: Point,
    fortifications: Fortifications,
    hp: u64,
}


mod model {
    use super::Point;
    /// A fortified structure that can be built and defended in the game.
    ///
    /// Game Model
    ///
    /// # Fields
    ///
    /// * `id` - Unique identifier for the outpost
    /// * `game_id` - The ID of the game instance this outpost belongs to
    /// * `position` - The coordinates of the outpost on the game map
    /// * `palisades` - Number of palisade defenses built
    /// * `trenches` - Number of trench defenses dug
    /// * `walls` - Number of wall defenses constructed
    /// * `basements` - Number of basements built
    /// * `hp` - Current health points of the outpost
    #[dojo::model]
    #[derive(Drop, Serde)]
    struct Outpost {
        #[key]
        id: felt252,
        game_id: felt252,
        position: Point,
        palisades: u64,
        trenches: u64,
        walls: u64,
        basements: u64,
        hp: u64,
    }
}

impl OutpostIntoOutpostModel of Into<@Outpost, @model::Outpost> {
    fn into(self: @Outpost) -> @model::Outpost {
        @model::Outpost {
            id: *self.id,
            game_id: *self.game_id,
            position: *self.position,
            palisades: *self.fortifications.palisades,
            trenches: *self.fortifications.trenches,
            walls: *self.fortifications.walls,
            basements: *self.fortifications.basements,
            hp: *self.hp,
        }
    }
}

impl OutpostModelIntoOutpost of Into<model::Outpost, Outpost> {
    fn into(self: model::Outpost) -> Outpost {
        Outpost {
            id: self.id,
            game_id: self.game_id,
            position: self.position,
            fortifications: Fortifications {
                palisades: self.palisades,
                trenches: self.trenches,
                walls: self.walls,
                basements: self.basements,
            },
            hp: self.hp,
        }
    }
}


/// Tracks events that affect specific outposts
///
/// Game Model
///
/// # Fields
///
/// * `outpost_id` - ID of the affected outpost
/// * `event_id` - Unique identifier for the event
/// * `applied` - Whether the event has been processed
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostEvent {
    #[key]
    outpost_id: felt252,
    #[key]
    event_id: felt252,
    applied: bool,
}

/// Tracks the number of active outposts in a game
///
/// Game Model
///
/// # Arguments
///
/// * `game_id` - Associated game instance
/// * `active` - Count of currently active outposts
#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct OutpostsActive {
    #[key]
    game_id: felt252,
    active: u32,
}

#[generate_trait]
impl OutpostStorageImpl of OutpostStorage {
    fn read_outpost_model(self: @WorldStorage, id: felt252) -> model::Outpost {
        self.read_model(id)
    }
    fn get_outpost(self: @WorldStorage, id: felt252) -> Outpost {
        self.read_outpost_model(id).into()
    }

    fn write_outpost_model(ref self: WorldStorage, outpost: @model::Outpost) {
        self.write_model(outpost);
    }

    fn update_outpost(ref self: WorldStorage, outpost: @Outpost) {
        self.write_outpost_model(outpost.into());
    }

    fn new_outpost(
        ref self: WorldStorage, id: felt252, game_id: felt252, position: Point, hp: u64,
    ) {
        self
            .write_model(
                @model::Outpost {
                    id, game_id, position, palisades: 0, trenches: 0, walls: 0, basements: 0, hp,
                },
            );
    }

    /// Retrieves outpost setup configuration for a game
    fn get_outpost_setup(self: @WorldStorage, game_id: felt252) -> OutpostSetup {
        self.read_model(game_id)
    }

    fn set_outpost_setup(
        ref self: WorldStorage,
        game_id: felt252,
        token_address: ContractAddress,
        price: u256,
        max_outposts: u32,
        hp: u64,
    ) {
        self.write_model(@OutpostSetup { game_id, token_address, price, max_outposts, hp });
    }

    /// Retrieves an event associated with a specific outpost
    fn get_outpost_event_applied(
        self: @WorldStorage, outpost_id: felt252, event_id: felt252,
    ) -> bool {
        self
            .read_member(
                Model::<OutpostEvent>::ptr_from_keys((outpost_id, event_id)), selector!("applied"),
            )
    }

    fn set_outpost_event_applied(ref self: WorldStorage, outpost_id: felt252, event_id: felt252) {
        self.write_model(@OutpostEvent { outpost_id, event_id, applied: true });
    }

    /// Retrieves the active outposts counter for a game
    fn get_outposts_active(self: @WorldStorage, game_id: felt252) -> OutpostsActive {
        self.read_model(game_id)
    }

    fn set_outposts_active(ref self: WorldStorage, game_id: felt252, active: u32) {
        self.write_model(@OutpostsActive { game_id, active });
    }

    /// Gets the initial HP value for outposts in a game
    fn get_starting_hp(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<OutpostSetup>::ptr_from_keys(game_id), selector!("hp"))
    }

    /// Gets the count of active outposts in a game
    fn get_active_outposts(self: @WorldStorage, game_id: felt252) -> u32 {
        self.read_member(Model::<OutpostsActive>::ptr_from_keys(game_id), selector!("active"))
    }

    fn get_outpost_token_address(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        self.read_member(Model::<OutpostSetup>::ptr_from_keys(game_id), selector!("token_address"))
    }

    fn get_outpost_fortification(
        self: @WorldStorage, id: felt252, fortification: Fortification,
    ) -> u64 {
        self.read_member(Model::<model::Outpost>::ptr_from_keys(id), fortification.selector())
    }

    fn set_outpost_fortification(
        ref self: WorldStorage, id: felt252, fortification: Fortification, amount: u64,
    ) {
        self
            .write_member(
                Model::<model::Outpost>::ptr_from_keys(id), fortification.selector(), amount,
            );
    }
}

