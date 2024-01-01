#[starknet::interface]
trait ITradeActions<TContractState> {
    // Create a new trade
    fn create(self: @TContractState, game_id: u32, count: u32, price: u128) -> u32;

    // Revoke an initiated trade
    fn revoke(self: @TContractState, game_id: u32, entity_id: u32);

    // Purchase an existing trade
    fn purchase(self: @TContractState, game_id: u32, trade_id: u32);

    // Modify the price of an existing trade
    fn modify_price(self: @TContractState, game_id: u32, trade_id: u32, new_price: u128);
}

#[dojo::contract]
mod trade_actions {
    use super::ITradeActions;

    use openzeppelin::token::erc20::interface::{
        IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
    };

    use realmsrisingrevenant::components::game::{
        Game, GameStatus, GameTracker, GameEntityCounter, GameTrait, GameImpl,
    };

    use realmsrisingrevenant::components::reinforcement::{
        ReinforcementBalance, ReinforcementBalanceImpl, ReinforcementBalanceTrait
    };

    use realmsrisingrevenant::components::player::{PlayerInfo, PlayerInfoImpl, PlayerInfoTrait};
    use realmsrisingrevenant::components::revenant::{Revenant, RevenantStatus,};

    use realmsrisingrevenant::components::trade::{Trade, TradeStatus};

    use starknet::{ContractAddress, get_block_info, get_caller_address};

    #[external(v0)]
    impl TradeActionImpl of ITradeActions<ContractState> {
        fn create(self: @ContractState, game_id: u32, count: u32, price: u128) -> u32 {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_is_playing(world);

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            player_info.check_player_exists(world);  // alex: only people that have bought a revenant can create trades
            assert(count > 0, 'count must larger than 0');
            assert(player_info.reinforcement_count >= count, 'No reinforcement can sell');

            player_info.reinforcement_count -= count;
            game_data.trade_count += count;

            let entity_id = game_data.trade_count;
            let trade = Trade {
                game_id,
                entity_id,
                price,
                count,
                seller: player,
                buyer: starknet::contract_address_const::<0x0>(),
                status: TradeStatus::selling,
            };

            set!(world, (player_info, game_data, trade));

            entity_id
        }

        fn revoke(self: @ContractState, game_id: u32, entity_id: u32) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let (mut game, mut game_data) = get!(world, game_id, (Game, GameEntityCounter));
            game.assert_is_playing(world);

            let mut trade = get!(world, (game_id, entity_id), Trade);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller == player, 'not owner');

            trade.status = TradeStatus::revoked;

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            player_info.reinforcement_count += trade.count;
            game_data.trade_count -= trade.count;

            set!(world, (player_info, trade, game_data));
        }

        fn purchase(self: @ContractState, game_id: u32, trade_id: u32) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address(); //get the address of the person calling the api

            let mut game = get!(world, game_id, Game); // get the game struct
            game.assert_is_playing(world); // check if the game is on going


            // this should be deleted   alex
            // let revenant = get!(world, (game_id, player_id), Revenant);    //fetch the revenants given a player_id? but probably you mean an entity_id
            // assert(revenant.owner == player, 'unable purchase for others');   // check if the revenant is owend by the player why? is it to check the user has ever bought into the game?
            // assert(revenant.status == RevenantStatus::started, 'not valid player');

            let mut trade = get!(world, (game_id, trade_id), Trade);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller != player, 'unable purchase your own trade');

            let erc20 = IERC20Dispatcher { contract_address: game.erc_addr };
            let seller_amount: u256 = trade.price.into() * 90 / 100;
            let contract_amount: u256 = trade.price.into() - seller_amount.into();

            let result = erc20
                .transfer_from(sender: player, recipient: trade.seller, amount: seller_amount);
            assert(result, 'need approve for erc20');
            let result = erc20
                .transfer_from(
                    sender: player, recipient: game.reward_pool_addr, amount: contract_amount
                );
            assert(result, 'need approve for erc20');

            let mut player_info = get!(world, (game_id, player), PlayerInfo);
            player_info.check_player_exists(world); // alex: only people that have bought revenants can buy trades
            player_info.reinforcement_count += trade.count;
            trade.status = TradeStatus::sold;
            trade.buyer = player;

            set!(world, (player_info, trade));
        }

        fn modify_price(self: @ContractState, game_id: u32, trade_id: u32, new_price: u128) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut game = get!(world, game_id, (Game));
            game.assert_is_playing(world);

            let mut trade = get!(world, (game_id, trade_id), Trade);
            assert(trade.status != TradeStatus::not_created, 'trade not exist');
            assert(trade.status != TradeStatus::sold, 'trade had been sold');
            assert(trade.status != TradeStatus::revoked, 'trade had been revoked');
            assert(trade.seller == player, 'not owner');

            trade.price = new_price;

            set!(world, (trade));
        }
    }
}
