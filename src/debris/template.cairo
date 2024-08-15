use dojo::world::IWorldDispatcher;
use risingrevenant::tokens::erc20::basic::IERC20MetadataTrait;

impl ERC20DebrisMetaDataImpl of IERC20MetadataTrait {
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


#[dojo::contract]
mod name_erc20 {
    use risingrevenant::{
        tokens::erc20::{
            basic::{ERC20_basic_component, IERC20Mint},
            internals::{
                ERC20BasicTotalSupplyImpl, ERC20BasicBalanceImpl, ERC20BasicTransferImpl,
                ERC20BasicAllowanceImpl
            }
        },
        debris::utils::ERC20DebrisMintImpl
    };
    use super::{ERC20DebrisMetaDataImpl};
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
            ERC20DebrisMintImpl,
            ERC20DebrisMetaDataImpl,
            ERC20BasicTotalSupplyImpl,
            ERC20BasicBalanceImpl,
            ERC20BasicTransferImpl,
            ERC20BasicAllowanceImpl
        >;
}
