#[cfg(test)]
mod tests {
    use core::option::OptionTrait;

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;
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
    use realmsrisingrevenant::components::trade::{Trade, TradeStatus};
    use realmsrisingrevenant::components::world_event::{WorldEvent};

    use realmsrisingrevenant::constants::{
        EVENT_INIT_RADIUS, GAME_CONFIG, OUTPOST_INIT_LIFE, REINFORCEMENT_INIT_COUNT,
        AUTO_CREATE_NEW_WORLD_EVENT
    };

    use realmsrisingrevenant::systems::game::{IGameActionsDispatcher, IGameActionsDispatcherTrait};
    use realmsrisingrevenant::systems::revenant::{
        IRevenantActionsDispatcher, IRevenantActionsDispatcherTrait
    };
    use realmsrisingrevenant::systems::trade::{
        ITradeActionsDispatcher, ITradeActionsDispatcherTrait
    };
    use realmsrisingrevenant::systems::world_event::{
        IWorldEventActionsDispatcher, IWorldEventActionsDispatcherTrait
    };
    use realmsrisingrevenant::tests::test_utils::{
        DefaultWorld, EVENT_BLOCK_INTERVAL, PREPARE_PHRASE_INTERVAL, _init_world, _init_game,
        _create_revenant, _add_block_number,
    };
    use starknet::{ContractAddress, syscalls::deploy_syscall};

    #[test]
    #[available_gas(3000000000)]
    fn test_create_game() {
        let DefaultWorld{world, game_action, caller, test_erc, .. } = _init_world();
        let game_id = game_action
            .create(
                PREPARE_PHRASE_INTERVAL, EVENT_BLOCK_INTERVAL, test_erc.contract_address, 0_u256
            );
        assert(game_id == 1, 'game id incorrect');

        let game_tracker = get!(world, GAME_CONFIG, GameTracker);
        assert(game_tracker.count == 1, 'wrong game trakcer');

        let (mut game, game_counter) = get!(world, (game_id), (Game, GameEntityCounter));
        game.assert_existed();
        game.assert_can_create_outpost(world);

        assert(game.status == GameStatus::preparing, 'wrong game status');
        assert(game_counter.outpost_count == 0, 'wrong outpost count');

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);
        game_action.refresh_status(game_id);

        let mut game = get!(world, (game_id), Game);
        // Cannot test refresh_status because it calls `set!`
        // which will cause error `must be called thru executor` during testing.
        game.assert_is_playing(world);
    }
    #[test]
    #[available_gas(3000000000)]
    fn test_create_revenant() {
        let DefaultWorld{world, game_action, revenant_action, test_erc, caller, .. } =
            _init_world();
        let game_id = game_action
            .create(
                PREPARE_PHRASE_INTERVAL, EVENT_BLOCK_INTERVAL, test_erc.contract_address, 2_u256
            );
        test_erc.approve(revenant_action.contract_address, 2_u256);
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        let (game, game_counter) = get!(world, (game_id), (Game, GameEntityCounter));
        assert(game_counter.revenant_count == 1, 'wrong revenant count');
        assert(game_counter.outpost_count == 1, 'wrong outpost count');
        assert(game_counter.outpost_exists_count == 1, 'wrong outpost count');
        assert(game_counter.remain_life_count == OUTPOST_INIT_LIFE, 'wrong remain lifes');

        let revenant = get!(world, (game_id, revenant_id), Revenant);
        assert(revenant.outpost_count == 1, 'wrong revenant info');
        assert(revenant.owner == caller, 'wrong revenant owner');
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_purchase_reinforcement() {
        let (DefaultWorld{world, caller, revenant_action, test_erc, .. }, game_id) = _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        let mut revenant = get!(world, (game_id, revenant_id), Revenant);

        let purchase_count = 10_u32;
        let price = revenant_action.get_current_price(game_id, purchase_count);
        test_erc.approve(revenant_action.contract_address, price.into());
        let purchase_result = revenant_action.purchase_reinforcement(game_id, purchase_count);
        assert(purchase_result, 'Failed to purchase');
        let player_info = get!(world, (game_id, caller), PlayerInfo);
        let expected_purchase_count = REINFORCEMENT_INIT_COUNT + purchase_count;
        assert(player_info.reinforcement_count == expected_purchase_count, 'wrong purchase count');

        let game_counter = get!(world, (game_id), GameEntityCounter);
        assert(
            game_counter.reinforcement_count == expected_purchase_count, 'wrong reinforcement count'
        );

        starknet::testing::set_block_timestamp(starknet::get_block_timestamp() + 100);
        let price2 = revenant_action.get_current_price(game_id, purchase_count);
        assert(price2 > price, 'wrong price');

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);
        revenant_action.reinforce_outpost(game_id, outpost_id);
        // 1-2 reinforcements: Unshielded; 3-5 reinforcements: 1 Shield
        revenant_action.reinforce_outpost(game_id, outpost_id);
        revenant_action.reinforce_outpost(game_id, outpost_id);

        let outpost = get!(world, (game_id, outpost_id), (Outpost));
        assert(outpost.lifes == OUTPOST_INIT_LIFE + 1, 'life value is wrong');
        let game_counter = get!(world, (game_id), GameEntityCounter);
        assert(game_counter.remain_life_count == OUTPOST_INIT_LIFE + 1, 'wrong remain lifes');
        assert(
            game_counter.reinforcement_count == expected_purchase_count - 3,
            'wrong reinforcement count'
        );
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_set_world_event() {
        let (DefaultWorld{world, caller, world_event_action, .. }, game_id) = _init_game();

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        let world_event = world_event_action.create(game_id);
        assert(world_event.radius == EVENT_INIT_RADIUS, 'event radius is wrong');

        _add_block_number(EVENT_BLOCK_INTERVAL + 1);
        let world_event_2 = world_event_action.create(game_id);
        assert(world_event_2.radius == EVENT_INIT_RADIUS + 1, 'event radius is wrong');

        let game_counter = get!(world, (game_id), GameEntityCounter);
        assert(game_counter.event_count == 2, 'wrong game counter');
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_destroy_outpost() {
        let (DefaultWorld{world, caller, revenant_action, world_event_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);
        let world_event = world_event_action.create(game_id);
        let destoryed = world_event_action
            .destroy_outpost(game_id, world_event.entity_id, outpost_id);

        let outpost = get!(world, (game_id, outpost_id), Outpost);
        if destoryed {
            assert(outpost.lifes == OUTPOST_INIT_LIFE - 1, 'life value is wrong');
            assert(outpost.last_affect_event_id == world_event.entity_id, 'wrong affect id');
            let world_event2 = get!(world, (game_id, world_event.entity_id), WorldEvent);
            assert(world_event2.destroy_count == 1, 'wrong destory count');
        } else {
            assert(outpost.lifes == OUTPOST_INIT_LIFE, 'life value is wrong');
            let world_event2 = get!(world, (game_id, world_event.entity_id), WorldEvent);
            assert(world_event2.destroy_count == 0, 'wrong destory count');
        }
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Outpost has been destroyed', 'ENTRYPOINT_FAILED',))]
    fn test_cannot_purchase_destoryed_outpost() {
        // Create initial outposts
        let (DefaultWorld{world, caller, revenant_action, world_event_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        // need two more outposts for preventing game end
        starknet::testing::set_contract_address(starknet::contract_address_const::<0x0001>());
        let (_, _) = _create_revenant(revenant_action, game_id);
        starknet::testing::set_contract_address(starknet::contract_address_const::<0x0002>());
        let (_, _) = _create_revenant(revenant_action, game_id);

        starknet::testing::set_contract_address(caller);
        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);
        // Loop until the outpost has been destoryed
        loop {
            _add_block_number(EVENT_BLOCK_INTERVAL + 1);
            let world_event = world_event_action.create(game_id);
            let destoryed = world_event_action
                .destroy_outpost(game_id, world_event.entity_id, outpost_id);

            if destoryed {
                let outpost = get!(world, (game_id, outpost_id), Outpost);
                if (outpost.lifes == 0) {
                    break;
                };
            };
        };

        // should panic because this outpost's life count is 0
        revenant_action.reinforce_outpost(game_id, outpost_id);
    }


    #[test]
    #[available_gas(3000000000)]
    fn test_game_end() {
        // Create initial outposts
        let (DefaultWorld{world, caller, revenant_action, world_event_action, .. }, game_id) =
            _init_game();
        let (revenant_id, outpost_id) = _create_revenant(revenant_action, game_id);
        let (_, _) = _create_revenant(
            revenant_action, game_id
        ); // need two outpost for checking game end

        let game_counter = get!(world, (game_id), GameEntityCounter);
        assert(game_counter.remain_life_count == OUTPOST_INIT_LIFE * 2, 'wrong remain lifes');
        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        // Loop world event
        world_event_action.create(game_id);
        loop {
            _add_block_number(EVENT_BLOCK_INTERVAL + 1);
            let game_counter = get!(world, (game_id), GameEntityCounter);
            let world_event = get!(world, (game_id, game_counter.event_count), WorldEvent);
            let destoryed = world_event_action
                .destroy_outpost(game_id, world_event.entity_id, outpost_id);

            let game_counter = get!(world, (game_id), GameEntityCounter);
            if destoryed {
                if game_counter.outpost_exists_count == 1 {
                    break;
                };

                if (AUTO_CREATE_NEW_WORLD_EVENT == 0) {
                    world_event_action.create(game_id);
                } else {
                    // If the event has an impact, a new event will be automatically generated.
                    assert(
                        game_counter.event_count.into() == world_event.entity_id + 1,
                        'new event failed create'
                    );
                }
            } else {
                world_event_action.create(game_id);
            };
        };

        let (game, game_counter) = get!(world, (game_id), (Game, GameEntityCounter));
        assert(game.status == GameStatus::ended, 'wrong game status');
        assert(game_counter.remain_life_count == OUTPOST_INIT_LIFE, 'wrong remain lifes');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_create_and_revoke_trade() {
        let (DefaultWorld{world, caller, revenant_action, trade_action, test_erc, .. }, game_id) =
            _init_game();
        let (revenant_id, _) = _create_revenant(revenant_action, game_id);

        // Create seller's reinforcement balance
        let purchase_count = 10_u32;
        let price = revenant_action.get_current_price(game_id, purchase_count);
        test_erc.approve(revenant_action.contract_address, price.into());
        revenant_action.purchase_reinforcement(game_id, purchase_count);
        let player_info = get!(world, (game_id, caller), PlayerInfo);
        let expected_purchase_count = REINFORCEMENT_INIT_COUNT + purchase_count;
        assert(
            player_info.reinforcement_count == expected_purchase_count, 'wrong init purchase count'
        );

        // Test Create Trade. the seller's reinforcement should decrease by 1
        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);
        let trade_id = trade_action.create(game_id, price);
        let trade = get!(world, (game_id, trade_id), Trade);
        assert(trade.status == TradeStatus::selling, 'wrong trade status');
        assert(trade.price == price, 'wrong trade price');
        let player_info = get!(world, (game_id, caller), PlayerInfo);
        assert(
            player_info.reinforcement_count == expected_purchase_count - 1, 'failed create trade'
        );

        // Test Revoke Trade
        trade_action.revoke(game_id, trade_id);
        let trade = get!(world, (game_id, trade_id), Trade);
        assert(trade.status == TradeStatus::revoked, 'wrong trade status');
        let player_info = get!(world, (game_id, caller), PlayerInfo);
        assert(player_info.reinforcement_count == expected_purchase_count, 'failed revoke trade');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_purchase_trade() {
        let (DefaultWorld{world, caller, revenant_action, trade_action, test_erc, .. }, game_id) =
            _init_game();
        let (revenant_id, _) = _create_revenant(revenant_action, game_id);

        // Create buyer
        let buyer = starknet::contract_address_const::<0xABCD>();
        starknet::testing::set_contract_address(buyer);
        let (buyer_revenant_id, _) = _create_revenant(revenant_action, game_id);
        starknet::testing::set_contract_address(caller);
        let buyer_revenant = get!(world, (game_id, buyer_revenant_id), Revenant);
        assert(buyer_revenant.owner == buyer, 'wrong buyer revenant');

        let purchase_count = 10_u32;
        let price = revenant_action.get_current_price(game_id, purchase_count);
        test_erc.approve(revenant_action.contract_address, price.into());
        revenant_action.purchase_reinforcement(game_id, purchase_count);

        _add_block_number(PREPARE_PHRASE_INTERVAL + 1);

        // Test Purchase. the buyer's reinforcement should increase from 0 to 1
        let trade_id = trade_action.create(game_id, price); // create trade by seller
        let buyer_info = get!(world, (game_id, buyer), PlayerInfo);
        assert(
            buyer_info.reinforcement_count == REINFORCEMENT_INIT_COUNT, 'wrong buyer purchase count'
        );
        starknet::testing::set_contract_address(buyer); // switch to buyer 
        test_erc.approve(trade_action.contract_address, price.into());
        trade_action.purchase(game_id, buyer_revenant_id, trade_id);
        let buyer_info = get!(world, (game_id, buyer), PlayerInfo);
        assert(
            buyer_info.reinforcement_count == REINFORCEMENT_INIT_COUNT + 1, 'failed purchase trade'
        );
    }
}
