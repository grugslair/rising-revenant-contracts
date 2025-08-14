use dojo::event::EventStorage;
use dojo::meta::Introspect;
use dojo::model::{Model, ModelStorage};
use dojo::world::WorldStorage;
use starknet::{ClassHash, ContractAddress, get_block_timestamp, get_caller_address};
/// Represents the different phases a game can be in.
///
/// * `NotCreated` - Game hasn't been created yet
/// * `Created` - Game is created but preparation hasn't started
/// * `Preparing` - Players can prepare their outposts
/// * `Hold` - Preparation is complete, waiting for game to start
/// * `Playing` - Game is actively being played
/// * `Claim` - Winners can claim their rewards
/// * `Ended` - Game is completely finished
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum GamePhase {
    NotCreated,
    Created,
    Preparing,
    Hold,
    Playing,
    Claim,
    Ended,
}

/// Stores the winning outpost information for a completed game
#[dojo::model]
#[derive(Drop, Serde)]
struct Winner {
    #[key]
    game_id: felt252,
    outpost_id: felt252,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect, DojoStore, Default)]
enum ClassHashVariant {
    #[default]
    ERC20MintableBurnable,
    ERC721Mintable,
    GamePot,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct GameClassHash {
    #[key]
    variant: ClassHashVariant,
    class_hash: ClassHash,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct GameContractAddress {
    #[key]
    selector: felt252,
    contract_address: ContractAddress,
}

/// Stores the timing information for different phases of the game
#[dojo::model]
#[derive(Drop, Serde, Copy, Default)]
struct GamePhases {
    /// Unique identifier for the game
    #[key]
    game_id: felt252,
    /// Timestamp when preparation phase starts
    prep_start: u64,
    /// Timestamp when preparation phase ends
    prep_stop: u64,
    /// Timestamp when the game events start
    events_start: u64,
    /// Duration of the claim period after game ends
    claim_period: u64,
    /// Timestamp when the game ended
    ended: u64,
}

#[derive(Drop, Serde, Introspect)]
struct GamePhasePrepping {
    prep_start: u64,
    prep_stop: u64,
}

#[derive(Drop, Serde, Introspect)]
struct GamePhasePlaying {
    events_start: u64,
    ended: u64,
}

#[derive(Drop, Serde, Introspect)]
struct GamePhaseClaiming {
    ended: u64,
    claim_period: u64,
}

#[generate_trait]
impl GamePhasePreppingImpl of GamePhasePreppingTrait {
    fn assert_preparing(self: @GamePhasePrepping, timestamp: u64) {
        let timestamp = get_block_timestamp();
        assert(
            timestamp >= *self.prep_start && timestamp <= *self.prep_stop,
            'Game is not in preparing phase',
        );
    }
}


#[dojo::event]
#[derive(Drop, Serde)]
struct GameName {
    #[key]
    game_id: felt252,
    name: ByteArray,
}

#[generate_trait]
impl GameStorageImpl of GameStorage {
    /// Retrieves the complete GamePhases struct for a specific game
    /// * `game_id` - The ID of the game
    fn get_game_phases(self: @WorldStorage, game_id: felt252) -> GamePhases {
        self.read_model(game_id)
    }

    fn new_game_phases(
        ref self: WorldStorage,
        game_id: felt252,
        prep_start: u64,
        prep_stop: u64,
        events_start: u64,
        claim_period: u64,
    ) {
        self
            .write_model(
                @GamePhases {
                    game_id, prep_start, prep_stop, events_start, claim_period, ended: 0,
                },
            );
    }

    fn get_game_phases_schema<T, +Serde<T>, +Introspect<T>>(
        self: @WorldStorage, game_id: felt252,
    ) -> T {
        self.read_schema(Model::<GamePhases>::ptr_from_keys(game_id))
    }

    fn get_game_phase_prepping(self: @WorldStorage, game_id: felt252) -> GamePhasePrepping {
        self.get_game_phases_schema(game_id)
    }

    fn get_game_phase_playing(self: @WorldStorage, game_id: felt252) -> GamePhasePlaying {
        self.get_game_phases_schema(game_id)
    }

    fn get_game_phase_claiming(self: @WorldStorage, game_id: felt252) -> GamePhaseClaiming {
        self.get_game_phases_schema(game_id)
    }

    fn get_game_phase_prep_start(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<GamePhases>::ptr_from_keys(game_id), selector!("prep_start"))
    }

    fn get_game_phase_prep_ended(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<GamePhases>::ptr_from_keys(game_id), selector!("prep_stop"))
    }

    fn set_game_name(ref self: WorldStorage, game_id: felt252, name: ByteArray) {
        self.emit_event(@GameName { game_id, name });
    }


    fn get_game_ended(self: @WorldStorage, game_id: felt252) -> u64 {
        self.read_member(Model::<GamePhases>::ptr_from_keys(game_id), selector!("ended"))
    }

    fn set_game_ended(ref self: WorldStorage, game_id: felt252) {
        self
            .write_member(
                Model::<GamePhases>::ptr_from_keys(game_id),
                selector!("ended"),
                get_block_timestamp(),
            );
    }

    /// Retrieves the winning outpost ID for a specific game
    /// * `game_id` - The ID of the game
    /// * Returns the outpost ID of the winner
    fn get_winning_outpost(self: @WorldStorage, game_id: felt252) -> felt252 {
        self.read_member(Model::<Winner>::ptr_from_keys(game_id), selector!("outpost_id"))
    }

    /// Sets the winning outpost for a specific game
    /// * `game_id` - The ID of the game
    /// * `outpost_id` - The ID of the winning outpost
    fn set_winning_outpost(ref self: WorldStorage, game_id: felt252, outpost_id: felt252) {
        self.write_model(@Winner { game_id, outpost_id });
    }

    fn set_class_hash(ref self: WorldStorage, variant: ClassHashVariant, class_hash: ClassHash) {
        self.write_model(@GameClassHash { variant, class_hash });
    }

    fn get_class_hash(self: @WorldStorage, variant: ClassHashVariant) -> ClassHash {
        self.read_member(Model::<GameClassHash>::ptr_from_keys(variant), selector!("class_hash"))
    }

    fn get_game_contract_address<T, +Serde<T>>(self: @WorldStorage, selector: felt252) -> T {
        self
            .read_member(
                Model::<GameContractAddress>::ptr_from_keys(selector),
                selector!("contract_address"),
            )
    }

    fn set_game_contract_address(
        ref self: WorldStorage, selector: felt252, contract_address: ContractAddress,
    ) {
        self.write_model(@GameContractAddress { selector, contract_address });
    }
}
