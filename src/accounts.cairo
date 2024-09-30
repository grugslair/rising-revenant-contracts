use starknet::ContractAddress;
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::{addresses::{GetAddressTrait, selectors},};


#[derive(Copy, Drop)]
struct AccountInfo {
    erc20_address: ERC20ABIDispatcher,
    wallet_address: ContractAddress,
}

#[generate_trait]
impl AccountInfoImpl of Account {
    fn get_account(self: @IWorldDispatcher) -> AccountInfo {
        AccountInfo {
            erc20_address: ERC20ABIDispatcher {
                contract_address: self.get_address_from_selector(selectors::GAME_TOKEN)
            },
            wallet_address: self.get_address_from_selector(selectors::GAME_WALLET),
        }
    }
    fn receive(ref self: AccountInfo, from: ContractAddress, amount: u256) {
        self.erc20_address.transfer_from(from, self.wallet_address, amount);
    }
}
