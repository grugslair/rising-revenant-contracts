use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

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
    

}

