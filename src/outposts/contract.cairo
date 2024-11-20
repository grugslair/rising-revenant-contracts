use super::models::Outpost;
use rising_revenant::fortifications::Fortification;

/// Interface for managing outposts in the Rising Revenant game
#[starknet::interface]
trait IOutpost<TContractState> {
    /// Creates a new outpost for the caller in the specified game
    /// # Arguments
    /// * `game_id` - The ID of the game to create the outpost in
    /// # Returns
    /// * The ID of the newly created outpost
    fn purchase(ref self: TContractState, game_id: felt252) -> felt252;

    /// Retrieves an outpost's data by its ID
    /// # Arguments
    /// * `outpost_id` - The ID of the outpost to retrieve
    /// # Returns
    /// * The Outpost struct containing all outpost data
    fn get(self: @TContractState, outpost_id: felt252) -> Outpost;

    /// Applies the current world event's effects to the specified outpost
    /// # Arguments
    /// * `outpost_id` - The ID of the outpost to apply the event to
    /// # Panics
    /// * If the outpost is not active
    /// * If the outpost is not in the event's radius
    fn apply_event(ref self: TContractState, outpost_id: felt252);

    /// Adds fortifications to an outpost
    /// # Arguments
    /// * `outpost_id` - The ID of the outpost to fortify
    /// * `fortification_type` - The type of fortification to add
    /// * `amount` - The amount of fortification to add
    /// # Panics
    /// * If the outpost is not active
    /// * If the outpost is under an active event
    fn fortify(
        ref self: TContractState,
        outpost_id: felt252,
        fortification_type: Fortification,
        amount: u256
    );
}

#[dojo::contract]
mod outpost_actions {
    use starknet::get_caller_address;
    use super::{IOutpost};
    use dojo::model::ModelStorage;
    use rising_revenant::{
        utils::get_hash_state,
        fortifications::models::{
            Fortifications, Fortification, FortificationsTrait, FortificationAttributesTrait
        },
        outposts::{
            Outpost, OutpostTrait, OutpostModels, systems::{OutpostsActiveTrait, OutpostEventTrait}
        },
        world_events::WorldEventTrait, map::{Point, PointTrait}, addresses::{AddressBook},
        contribution::{ContributionTrait, ContributionEvent}, game::GameTrait, vrf::{VRF, Source},
        world::default_namespace
    };
    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    #[abi(embed_v0)]
    impl OutpostImpl of IOutpost<ContractState> {
        fn purchase(ref self: ContractState, game_id: felt252) -> felt252 {
            let mut world = self.world(default_namespace());
            world.assert_preparing(game_id);
            let randomness = world.randomness(Source::Nonce(get_caller_address()));

            world.make_outpost(game_id, get_caller_address(), randomness)
        }

        fn get(self: @ContractState, outpost_id: felt252) -> Outpost {
            let world = self.world(default_namespace());
            world.get_outpost(outpost_id)
        }

        fn apply_event(ref self: ContractState, outpost_id: felt252) {
            let mut world = self.world(default_namespace());
            let mut outpost = world.get_outpost(outpost_id);
            let event = world.get_world_event(outpost.game_id);

            world.assert_playing(outpost.game_id);
            assert(outpost.is_active(), 'Outpost is not active');
            assert(event.in_range(outpost.position), 'Outpost not in radius');

            world.set_event_applied(outpost_id, event.event_id);
            outpost
                .apply_event(
                    event,
                    world.get_fortification_attributes(outpost.game_id, event.event_type),
                    get_hash_state((event.event_id, outpost.id))
                );
            world.increase_caller_contribution(outpost.game_id, ContributionEvent::EventApplied);
            if !outpost.is_active() {
                world
                    .increase_caller_contribution(
                        outpost.game_id, ContributionEvent::OutpostDestroyed
                    );
                world.reduce_active_outposts(outpost.game_id);
            };
        }

        fn fortify(
            ref self: ContractState,
            outpost_id: felt252,
            fortification_type: Fortification,
            amount: u256
        ) {
            let mut world = self.world(default_namespace());
            let caller = get_caller_address();
            let mut outpost = world.get_outpost(outpost_id);
            let event = world.get_world_event(outpost.game_id);
            assert(outpost.is_active(), 'Outpost is not active');
            assert(
                !outpost.position.in_range(event.position, event.radius_sq),
                'Cannot fortify under event'
            );
            outpost.fortifications.add(fortification_type, amount.try_into().unwrap());

            world.write_model(@outpost);
            IERC20MintableBurnableDispatcher {
                contract_address: world.get_address(fortification_type),
            }
                .burn_from(caller, amount);
        }
    }
}
