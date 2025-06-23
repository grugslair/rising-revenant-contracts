use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20Admin<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn grant_owner(ref self: TContractState, owner: ContractAddress);
    fn revoke_owner(ref self: TContractState, owner: ContractAddress);
    fn grant_minter(ref self: TContractState, minter: ContractAddress);
    fn revoke_minter(ref self: TContractState, minter: ContractAddress);
    fn is_owner(self: @TContractState, owner: ContractAddress) -> bool;
    fn is_minter(self: @TContractState, minter: ContractAddress) -> bool;
}


#[starknet::contract]
mod erc20_rr_lords {
    use openzeppelin_token::erc20::{ERC20Component, ERC20HooksEmptyImpl, interface::IERC20Metadata};
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use super::IERC20Admin;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    // External
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;

    // Internal
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        owners: Map<ContractAddress, bool>,
        minters: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owners.write(get_caller_address(), true);
    }

    #[abi(embed_v0)]
    impl ERC20MetadataImpl of IERC20Metadata<ContractState> {
        fn name(self: @ContractState) -> ByteArray {
            "Rising Revenant Lords"
        }

        fn symbol(self: @ContractState) -> ByteArray {
            "RR-LORDS"
        }

        fn decimals(self: @ContractState) -> u8 {
            18
        }
    }

    #[abi(embed_v0)]
    impl IERC20AdminImpl of IERC20Admin<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.assert_caller_is_minter();
            self.erc20.mint(recipient, amount);
        }

        fn grant_owner(ref self: ContractState, owner: ContractAddress) {
            self.assert_caller_is_owner();
            self.owners.write(owner, true);
        }

        fn revoke_owner(ref self: ContractState, owner: ContractAddress) {
            self.assert_caller_is_owner();
            self.owners.write(owner, false);
        }

        fn grant_minter(ref self: ContractState, minter: ContractAddress) {
            self.assert_caller_is_owner();
            self.minters.write(minter, true);
        }

        fn revoke_minter(ref self: ContractState, minter: ContractAddress) {
            self.assert_caller_is_owner();
            self.minters.write(minter, false);
        }

        fn is_owner(self: @ContractState, owner: ContractAddress) -> bool {
            self.owners.read(owner)
        }

        fn is_minter(self: @ContractState, minter: ContractAddress) -> bool {
            self.minters.read(minter)
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn assert_caller_is_owner(self: @ContractState) {
            assert(self.is_owner(get_caller_address()), 'Caller is not an owner');
        }
        fn assert_caller_is_minter(self: @ContractState) {
            assert(self.is_minter(get_caller_address()), 'Caller is not a minter');
        }
    }
}
