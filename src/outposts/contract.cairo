use super::models::{Outpost, Fortifications};


#[dojo::interface]
trait IOutpost<TContractState> {
    fn purchase(ref world: IWorldDispatcher) -> felt252;
    fn get(world: @IWorldDispatcher, outpost_id: felt252) -> Outpost;
    fn run_event(ref world: IWorldDispatcher, outpost_id: felt252, event: felt252);
    fn fortify(ref world: IWorldDispatcher, outpost_id: felt252, fortifications: Fortifications);
}

#[dojo::contract]
mod outpost_actions {
    use starknet::get_caller_address;
    use super::{IOutpost};
    use risingrevenant::{
        utils::get_hash_state,
        fortifications::models::{Fortifications, Fortification, FortificationsTrait},
        outpost::models::{Outpost, OutpostTrait, OutpostsActiveTrait, OutpostEventTrait},
        world_event::models::{CurrentEvent, CurrentEventTrait}, models::{Point, PointTrait},
        addresses::{AddressTrait, selectors}, contribution::{ContributionTrait, ContributionEvent},
    };
    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    #[abi(embed_v0)]
    impl OutpostImpl of IOutpost<ContractState> {
        fn purchase(ref world: IWorldDispatcher) {
            // TODO: get_outpost_price
            let caller = get_caller_address();
        }

        fn get(world: @IWorldDispatcher, outpost_id: felt252) -> Outpost {
            self.get_outpost(world, outpost_id)
        }

        fn apply_event(ref world: IWorldDispatcher, outpost_id: felt252) {
            let mut outpost = world.get_outpost(outpost_id);
            let event = world.get_world_event(outpost.game_id);

            world.assert_playing(outpost.game_id);
            assert(outpost.is_active(), 'Outpost is not active');
            assert(event.in_range(outpost.position), 'Outpost not in radius');

            event.set_did_hit(world, true);
            outpost.apply_event(event, get_hash_state((event.seed, outpost.id)));
            outpost.set_event_applied(world, outpost.id, event.id);
            self.increase_caller_contribution(world, ContributionEvent::EventApplied);
            if !outpost.is_active() {
                self.increase_caller_contribution(world, ContributionEvent::OutpostDestroyed);
                let outposts_left = self.reduce_active_outposts(outpost.game_id);
            }
        }

        fn fortify(
            ref world: IWorldDispatcher,
            id: felt252,
            fortification_type: Fortification,
            amount: u256
        ) {
            let caller = get_caller_address();
            let mut outpost = self.get_outpost(world, outpost_id);
            let event = world.get_current_event(outpost.game_id);
            assert(outpost.is_active(), 'Outpost is not active');
            assert(
                !outpost.position.in_range(event.position, event.radius_sq),
                'Cannot fortify under event'
            );
            outpost.fortifications.add(fortification_type, amount);

            outpost.set(world);
            IERC20MintableBurnableDispatcher {
                contract_address: self.get_address_of(Fortification),
            }
                .burn_from(recipient, amount);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn make_outpost(self: IWorldDispatcher,) -> Outpost {}
    }
}
