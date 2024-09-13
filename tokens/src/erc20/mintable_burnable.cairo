use starknet::ContractAddress;

#[starknet::interface]
trait IERC20MintableBurnable<TContractState> {
    fn set_writer(ref self: TContractState, writer: ContractAddress, authorized: bool);
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn_from(ref self: TContractState, account: ContractAddress, amount: u256);
}

#[starknet::contract]
mod erc20_mintable_burnable {
    use openzeppelin_token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::{
        ContractAddress, get_caller_address,
        storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map}
    };
    use super::IERC20MintableBurnable;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        owner: ContractAddress,
        writers: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, name: ByteArray, symbol: ByteArray, owner: ContractAddress
    ) {
        self.erc20.initializer(name, symbol);
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl ERC20MintableBurnableImpl of IERC20MintableBurnable<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            assert(self.writers.entry(get_caller_address()).read(), 'ERC20: unauthorized caller');
            self.erc20.mint(recipient, amount);
        }

        fn burn_from(ref self: ContractState, account: ContractAddress, amount: u256) {
            self.erc20._spend_allowance(get_caller_address(), account, amount);
            self.erc20.burn(account, amount);
        }

        fn set_writer(ref self: ContractState, writer: ContractAddress, authorized: bool) {
            assert(self.owner.read() == get_caller_address(), 'ERC20: unauthorized caller');
            self.writers.entry(writer).write(authorized);
        }
    }
}
