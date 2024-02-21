use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use openzeppelin::token::erc20::interface::{
    IERC20, IERC20Dispatcher, IERC20DispatcherImpl, IERC20DispatcherTrait
};

use risingrevenant::components::game::{GamePot, DevWallet, GamePotConsts, GameERC20,};

use risingrevenant::systems::game::{GameAction, GameActionTrait};


// DEV
use risingrevenant::constants::PLAYER_STARTING_AMOUNT;


#[derive(Copy, Drop, Print)]
struct PaymentSystem {
    game_action: GameAction,
    coin_erc_address: ContractAddress,
}


#[generate_trait]
impl PaymentSystemImpl of PaymentSystemTrait {
    fn new(game_action: @GameAction) -> PaymentSystem {
        let erc_20: GameERC20 = game_action.get_game();
        PaymentSystem { game_action: *game_action, coin_erc_address: erc_20.address }
    }
    // fn transfer<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(
    //     self: @PaymentSystem, sender: ContractAddress, recipient: ContractAddress, amount: T
    // ) {
    //     let erc20 = IERC20Dispatcher { contract_address: *self.coin_erc_address };
    //     let result = erc20.transfer_from(sender, recipient, amount: amount.into());
    //     assert(result, 'need approve for erc20');
    // }

    fn transfer<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(
        self: @PaymentSystem, sender: ContractAddress, recipient: ContractAddress, amount: T
    ) {
        let mut sender_wallet: DevWallet = self
            .game_action
            .get((*self.game_action.game_id, sender));
        let mut recipiant_wallet: DevWallet = self
            .game_action
            .get((*self.game_action.game_id, recipient));
        if (!sender_wallet.init) {
            sender_wallet.init = true;
            sender_wallet.balance = PLAYER_STARTING_AMOUNT;
        }
        if (!recipiant_wallet.init) {
            recipiant_wallet.init = true;
            recipiant_wallet.balance = PLAYER_STARTING_AMOUNT;
        }
        assert(sender_wallet.balance >= amount.into(), 'not enough cash');
        sender_wallet.balance -= amount.into();
        recipiant_wallet.balance += amount.into();
        self.game_action.set((sender_wallet, recipiant_wallet));
    }

    fn pay_into_pot<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(
        self: @PaymentSystem, sender: ContractAddress, amount: T
    ) {
        let pot_conts: GamePotConsts = self.game_action.get_game();
        self.transfer(sender, pot_conts.pot_address, amount);
        let mut game_pot: GamePot = self.game_action.get_game();
        game_pot.total_pot += amount.into();
        game_pot.confirmation_pot = game_pot.total_pot
            * pot_conts.confirmation_percent.into()
            / 100_u256;
        game_pot.ltr_pot = game_pot.total_pot * pot_conts.ltr_percent.into() / 100_u256;
        game_pot.dev_pot = game_pot.total_pot * pot_conts.dev_percent.into() / 100_u256;
        game_pot.winners_pot = game_pot.total_pot
            - game_pot.confirmation_pot
            - game_pot.ltr_pot
            - game_pot.dev_pot;
        self.game_action.set(game_pot);
    }

    fn pay_out_pot<T, +Into<T, u256>, +Copy<T>, +Drop<T>>(
        self: @PaymentSystem, recipient: ContractAddress, amount: T
    ) {
        let pot_conts: GamePotConsts = self.game_action.get_game();
        self.transfer(pot_conts.pot_address, recipient, amount);
    }
}


