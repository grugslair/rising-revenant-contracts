use risingrevenant::tokens::erc20::{basic::{IERC20MetadataTrait, IERC20MintTrait}};

impl ERC20TemplateMetaDataImpl of IERC20MetadataTrait {
    fn name() -> ByteArray {
        "Name"
    }
    fn symbol() -> felt252 {
        'SYM'
    }
    fn decimals() -> u8 {
        18
    }
}

#[dojo::contract]
mod name_erc20 {
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use dojo::contract::{IContractDispatcher, IContractDispatcherTrait};
    use risingrevenant::tokens::erc20::{
        basic::{ERC20_basic_component, IERC20Mint}, IERC20CoreDispatcher, IERC20CoreDispatcherTrait
    };
    use super::{ERC20TemplateMetaDataImpl};

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
    impl IERC20MintImpl of IERC20Mint<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let world: IWorldDispatcher = self.world();

            // world
            //     .is_writer(
            //         IContractDispatcher { contract_address: get_contract_address() }.selector(),
            //         get_caller_address()
            //     );
            world.is_writer(self.selector(), get_caller_address());
            IERC20CoreDispatcher { contract_address: self.core_contract_address.read() }
                .mint(recipient, amount);
            true
        }
    }

    #[abi(embed_v0)]
    impl IERC20BasicImpl =
        ERC20_basic_component::ERC20BasicImpl<ContractState, ERC20TemplateMetaDataImpl,>;
}
