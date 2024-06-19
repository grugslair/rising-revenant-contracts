use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use token::components::token::erc20::erc20_balance::{
    IERC20BalanceDispatcher, IERC20BalanceDispatcherTrait
};

use risingrevenant::components::game::{GamePot, DevWallet, GamePotConsts, GameERC20,};
use risingrevenant::components::currency::{CurrencyTrait};

use risingrevenant::systems::game::{GameAction, GameActionTrait};


// DEV
use risingrevenant::constants::{PLAYER_STARTING_AMOUNT};


#[derive(Copy, Drop)]
struct PaymentSystem {
    game_action: GameAction,
    coin_erc_address: ContractAddress,
}


#[generate_trait]
impl PaymentSystemImpl of PaymentSystemTrait {
    fn new(game_action: GameAction) -> PaymentSystem {
        let erc_20: GameERC20 = game_action.get_game();
        PaymentSystem { game_action: game_action, coin_erc_address: erc_20.address }
    }
    fn transfer_from<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
        self: @PaymentSystem, sender: ContractAddress, recipient: ContractAddress, amount: T
    ) {
        let amount_256 = amount.convert();
        let erc20 = IERC20BalanceDispatcher { contract_address: *self.coin_erc_address };
        let result = erc20.transfer_from(sender, recipient, amount: amount_256);
        assert(result, 'need approve for erc20');
    }

    fn transfer<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
        self: @PaymentSystem, recipient: ContractAddress, amount: T
    ) {
        let amount_256 = amount.convert();
        let erc20 = IERC20BalanceDispatcher { contract_address: *self.coin_erc_address };
        let result = erc20.transfer(recipient, amount: amount_256);
        assert(result, 'Transaction failed');
    }

    // fn pay_out()<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
    //     self: PaymentSystem, sender: ContractAddress, amount: T
    // ) {

    // fn transfer<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
    //     self: PaymentSystem, sender: ContractAddress, recipient: ContractAddress, amount: T
    // ) {
    //     let mut sender_wallet: DevWallet = self.game_action.get(sender);
    //     let mut recipient_wallet: DevWallet = self.game_action.get(recipient);
    //     let amount_256 = amount.convert();
    //     if (!sender_wallet.init) {
    //         sender_wallet.init = true;
    //         sender_wallet.balance = PLAYER_STARTING_AMOUNT;
    //     }
    //     if (!recipient_wallet.init) {
    //         recipient_wallet.init = true;
    //         recipient_wallet.balance = PLAYER_STARTING_AMOUNT;
    //     }
    //     assert(sender_wallet.balance >= amount_256, 'not enough cash');
    //     sender_wallet.balance -= amount_256;
    //     recipient_wallet.balance += amount_256;
    //     self.game_action.set(sender_wallet);
    //     self.game_action.set(recipient_wallet);
    // }

    fn pay_into_pot<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
        self: PaymentSystem, sender: ContractAddress, amount: T
    ) {
        let pot_conts: GamePotConsts = self.game_action.get_game();
        let amount_256 = amount.convert();
        self.transfer_from(sender, pot_conts.pot_address, amount_256);
        let mut game_pot: GamePot = self.game_action.get_game();
        game_pot.total_pot += amount_256;
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

    fn pay_out_pot<T, +CurrencyTrait<T, u256>, +Copy<T>, +Drop<T>>(
        self: PaymentSystem, recipient: ContractAddress, amount: T
    ) {
        self.transfer(recipient, amount);
    }
}

