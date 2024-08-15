use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;
use risingrevenant::tokens::erc20::{
    basic::{IERC20MetadataTrait, IERC20MintTrait}, internals::{ERC20MintTrait, Transfer}
};

impl ERC20TemplateMetaDataImpl of IERC20MetadataTrait {
    fn name(self: @IWorldDispatcher) -> ByteArray {
        "Name"
    }
    fn symbol(self: @IWorldDispatcher) -> felt252 {
        'SYM'
    }
    fn decimals(self: @IWorldDispatcher) -> u8 {
        18
    }
}

impl ERC20TemplateMintImpl of IERC20MintTrait {
    fn mint(self: IWorldDispatcher, recipient: ContractAddress, amount: u256) -> Transfer {
        self.mint_token(recipient, amount)
    }
}

#[dojo::contract]
mod name_erc20 {
    use risingrevenant::tokens::erc20::{
        basic::{ERC20_basic_component, IERC20Mint},
        internals::{
            ERC20BasicTotalSupplyImpl, ERC20BasicBalanceImpl, ERC20BasicTransferImpl,
            ERC20BasicAllowanceImpl
        }
    };
    use super::{ERC20TemplateMetaDataImpl, ERC20TemplateMintImpl};
    component!(path: ERC20_basic_component, storage: erc20_basic_storage, event: ERC20BasicEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20_basic_storage: ERC20_basic_component::Storage,
    }

    #[event]
    #[derive(Copy, Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20BasicEvent: ERC20_basic_component::Event,
    }


    #[abi(embed_v0)]
    impl IERC20BasicImpl =
        ERC20_basic_component::ERC20BasicImpl<
            ContractState,
            ERC20TemplateMintImpl,
            ERC20TemplateMetaDataImpl,
            ERC20BasicTotalSupplyImpl,
            ERC20BasicBalanceImpl,
            ERC20BasicTransferImpl,
            ERC20BasicAllowanceImpl
        >;
}
