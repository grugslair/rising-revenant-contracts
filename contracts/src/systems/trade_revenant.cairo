#[starknet::interface]
trait ITradeRevenantActions<TContractState> {
    // Create a new trade
    fn create(self: @TContractState, game_id: u32, revenant_id: u128, price: u128) -> u32;

    // Revoke an initiated trade
    fn revoke(self: @TContractState, game_id: u32, trade_id: u32);

    // Purchase an existing trade
    fn purchase(self: @TContractState, game_id: u32, trade_id: u32);

    // Modify the price of an existing trade
    fn modify_price(self: @TContractState, game_id: u32, trade_id: u32, new_price: u128);
}

// Trade for reinforcement
#[dojo::contract]
mod trade_revenant_actions {
    use super::ITradeRevenantActions;

    use openzeppelin::token::erc20::interface::{
        IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
    };

    use realmsrisingrevenant::components::game::{
        Game, GameStatus, GameTracker, GameEntityCounter, GameTrait, GameImpl,
    };

    use realmsrisingrevenant::components::outpost::{Outpost, OutpostStatus};

    use realmsrisingrevenant::components::player::PlayerInfo;
    use realmsrisingrevenant::components::revenant::{Revenant, RevenantStatus,};

    use realmsrisingrevenant::components::trade_revenant::{TradeRevenant, TradeStatus};

    use starknet::{ContractAddress, get_block_info, get_caller_address};

    #[external(v0)]
    impl TradeRevenantActionImpl of ITradeRevenantActions<ContractState> {
        fn create(self: @ContractState, game_id: u32, revenant_id: u128, price: u128) -> u32 {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_is_playing(world);

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            let mut revenant = get!(world, (game_id, revenant_id), Revenant);
            assert(revenant.status != RevenantStatus::not_start, 'revenant not exists');
            assert(revenant.owner == player, 'not owner');
            let mut outpost = get!(world, (game_id, revenant.outpost_id), Outpost);
            assert(outpost.lifes > 0, 'outpost has been destroyed');

            game_data.trade_count += 1;

            let entity_id = game_data.trade_count;
            let trade = TradeRevenant {
                game_id,
                entity_id,
                price,
                revenant_id,
                outpost_id: revenant.outpost_id,
                seller: player,
                buyer: starknet::contract_address_const::<0x0>(),
                status: TradeStatus::selling,
            };

            set!(world, (player_info, game_data, trade));

            entity_id
        }

        fn revoke(self: @ContractState, game_id: u32, trade_id: u32) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_is_playing(world);

            let mut trade = get!(world, (game_id, trade_id), TradeRevenant);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller == player, 'not owner');

            trade.status = TradeStatus::revoked;

            set!(world, (trade, game_data));
        }

        fn purchase(self: @ContractState, game_id: u32, trade_id: u32) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address(); //get the address of the person calling the api

            let mut game = get!(world, game_id, Game); // get the game struct
            game.assert_is_playing(world); // check if the game is on going

            let mut trade = get!(world, (game_id, trade_id), TradeRevenant);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller != player, 'unable purchase your own trade');

            let mut revenant = get!(world, (game_id, trade.revenant_id), Revenant);
            let mut outpost = get!(world, (game_id, trade.outpost_id), Outpost);
            // TODO: Should we consider checking whether the current outpost has been destroyed? 
            // For now, we can handle this logic on the front end.
            assert(outpost.lifes > 0, 'outpost has been destoryed');

            // let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
            let seller_amount: u128 = trade.price * 95 / 100;
            let contract_amount: u128 = trade.price - seller_amount.into();

            // let result = erc20
            //     .transfer_from(sender: player, recipient: trade.seller, amount: seller_amount);
            // assert(result, 'need approve for erc20');
            // let result = erc20
            //     .transfer_from(
            //         sender: player, recipient: game.reward_pool_addr, amount: contract_amount
            //     );
            // assert(result, 'need approve for erc20');

            revenant.owner = player;
            outpost.owner = player;

            let mut buyer_info = get!(world, (game_id, player), PlayerInfo);
            let mut seller_info = get!(world, (game_id, trade.seller), PlayerInfo);
            buyer_info.revenant_count += 1;
            buyer_info.outpost_count += 1;
            seller_info.revenant_count -= 1;
            seller_info.outpost_count -= 1;

            trade.status = TradeStatus::sold;
            trade.buyer = player;

            set!(world, (trade, revenant, outpost, buyer_info, seller_info));
        }

        fn modify_price(self: @ContractState, game_id: u32, trade_id: u32, new_price: u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut game = get!(world, game_id, (Game));
            game.assert_is_playing(world);

            let mut trade = get!(world, (game_id, trade_id), TradeRevenant);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller == player, 'not owner');

            trade.price = new_price;

            set!(world, (trade));
        }
    }
}

#[cfg(test)]
mod trade_revenant_tests {
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use realmsrisingrevenant::tests::test_utils::{
        DefaultWorld, EVENT_BLOCK_INTERVAL, PREPARE_PHRASE_INTERVAL, _init_world, _init_game,
        _create_revenant, _add_block_number,
    };
    use realmsrisingrevenant::systems::trade_revenant::{
        trade_revenant_actions, ITradeRevenantActionsDispatcher,
        ITradeRevenantActionsDispatcherTrait
    };

    use realmsrisingrevenant::components::game::{
        Game, game_tracker, GameTracker, GameStatus, GameEntityCounter, GameImpl, GameTrait
    };
    use realmsrisingrevenant::components::outpost::{
        Outpost, OutpostStatus, OutpostImpl, OutpostTrait
    };
    use realmsrisingrevenant::components::player::PlayerInfo;
    use realmsrisingrevenant::components::revenant::{
        Revenant, RevenantStatus, RevenantImpl, RevenantTrait
    };
    use realmsrisingrevenant::components::trade_revenant::{TradeRevenant, TradeStatus};


    #[test]
    #[available_gas(3000000000)]
    fn test_create_trade() {
        let (DefaultWorld{world, caller, revenant_action, trade_revenant_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        let price = 10;
        let trade_id = trade_revenant_action.create(game_id, revenant_id, price);
        let trade = get!(world, (game_id, trade_id), TradeRevenant);
        assert(trade.price == price, 'wrong trade trade');
        assert(trade.revenant_id == revenant_id, 'wrong revenant id');
        assert(trade.outpost_id == 1, 'wrong outpost id');
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('trade had been revoked', 'ENTRYPOINT_FAILED',))]
    fn test_revoke_trade() {
        let (DefaultWorld{world, caller, revenant_action, trade_revenant_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        // create buyer
        let buyer = starknet::contract_address_const::<0xABCD>();
        starknet::testing::set_contract_address(buyer);
        let (buyer_revenant_id, _) = _create_revenant(revenant_action, game_id);
        starknet::testing::set_contract_address(caller);

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        let price = 10;
        let trade_id = trade_revenant_action.create(game_id, revenant_id, price);
        trade_revenant_action.revoke(game_id, trade_id);

        let trade = get!(world, (game_id, trade_id), TradeRevenant);
        assert(trade.status == TradeStatus::revoked, 'wrong status');

        // should panic because trade has been revoked
        starknet::testing::set_contract_address(buyer);
        trade_revenant_action.purchase(game_id, trade_id);
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_purchase_trade() {
        let (DefaultWorld{world, caller, revenant_action, trade_revenant_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        // create buyer
        let buyer = starknet::contract_address_const::<0xABCD>();
        starknet::testing::set_contract_address(buyer);
        let (buyer_revenant_id, _) = _create_revenant(revenant_action, game_id);
        starknet::testing::set_contract_address(caller);

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        let price = 10;
        let trade_id = trade_revenant_action.create(game_id, revenant_id, price);

        starknet::testing::set_contract_address(buyer);
        trade_revenant_action.purchase(game_id, trade_id);

        let revenant = get!(world, (game_id, revenant_id), Revenant);
        let outpost = get!(world, (game_id, outpost_id), Outpost);
        assert(revenant.owner == buyer, 'wrong revenant owner');
        assert(outpost.owner == buyer, 'wrong outpost owner');

        let player_info = get!(world, (game_id, buyer), PlayerInfo);
        assert(player_info.outpost_count == 2, 'wrong player info outpost');
        assert(player_info.revenant_count == 2, 'wrong player info revenant');
    }
}