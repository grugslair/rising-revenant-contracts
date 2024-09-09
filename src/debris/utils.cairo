use starknet::{ContractAddress, get_contract_address, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::tokens::erc20::{basic::IERC20MintTrait, internals::{Transfer, ERC20MintTrait}};


impl ERC20DebrisMintImpl of IERC20MintTrait {
    fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> Transfer {
        assert(
            self.can_write_namespace(get_contract_address(), get_caller_address()),
            'ERC20: Unauthorized to mint'
        );
        self.mint_token(recipient, amount)
    }
}
