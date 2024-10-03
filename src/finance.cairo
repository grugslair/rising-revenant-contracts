use starknet::ContractAddress;
use openzeppelin_token::erc20::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use rising_revenant::{addresses::{AddressBook}, address_selectors};


#[derive(Copy, Drop)]
struct FinanceAccount {
    erc20_address: ERC20ABIDispatcher,
    wallet_address: ContractAddress,
}

#[generate_trait]
impl FinanceInfoImpl of Finance {
    fn get_finance_account(self: @IWorldDispatcher) -> FinanceAccount {
        FinanceAccount {
            erc20_address: ERC20ABIDispatcher {
                contract_address: self.get_address(address_selectors::GAME_TOKEN_SELECTOR)
            },
            wallet_address: self.get_address(address_selectors::GAME_WALLET_SELECTOR),
        }
    }
    fn receive(ref self: FinanceAccount, from: ContractAddress, amount: u256) {
        self.erc20_address.transfer_from(from, self.wallet_address, amount);
    }
    fn send(ref self: FinanceAccount, to: ContractAddress, amount: u256) {
        self.erc20_address.transfer(to, amount);
    }
}
