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
        outpost::models::{Outpost, OutpostTrait, OutpostsActiveTrait},
        world_event::models::{CurrentEvent, CurrentEventTrait},
        models::{Point, PointTrait},
        addresses::{GetAddressTrait, selectors}
    };
    use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use tokens::erc20::interfaces::{
        IERC20MintableBurnableDispatcher, IERC20MintableBurnableDispatcherTrait
    };
    #[abi(embed_v0)]
    impl OutpostImpl of IOutpost<ContractState>{
        fn purchase(ref world: IWorldDispatcher){
            // TODO: get_outpost_price
            let randomness: felt252 = 0;
            let price: u256 = 0;
            let location: Point{x:0, y:0};
            let caller = get_caller_address();
            let erc20 = ERC20ABIDispatcher{contract_address: self.get_address_from_selector(selectors::GAME_TOKEN)};
            // erc20.transfer_from(caller, self.get_address_from_selector(selectors::GAME_WALLET), price);
            // let outpost = Outpost{
            //     game_id: 0,
            //     outpost_id: randomness,
            //     position: location,
            //     fortifications: Fortifications::new(),
            //     hp: 100
            // };

        }

        fn get(world: @IWorldDispatcher, outpost_id: felt252) -> Outpost {
            self.get_outpost(world, outpost_id)
        }

        fn apply_event(ref world: IWorldDispatcher, outpost_id: felt252) {
            let mut outpost = world.get_outpost(outpost_id);
            let event = world.get_current_event(outpost.game_id);

            world.assert_playing(outpost.game_id);
            assert(outpost.is_active(), 'Outpost is not active');
            assert(outpost.game_id == game_id, 'Outpost not in game');
            assert(event.in_range(outpost.position), 'Outpost not in radius');
            
            outpost.apply_event(event, get_hash_state((event.seed, outpost.id)));
            if !outpost.is_active() {
                let outposts_left = self.reduce_active_outposts(game_id);
            }
        
        }

        fn fortify(ref world: IWorldDispatcher, id: felt252, fortification_type: Fortification, amount: u256) {
            let caller = get_caller_address();
            let mut outpost = self.get_outpost(world, outpost_id);
            outpost.fortifications.add(fortification_type, amount);
            outpost.set(world);
            IERC20MintableBurnableDispatcher { contract_address: self.get_address(Fortification), }
                .burn_from(recipient, amount);
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {

    }
}
