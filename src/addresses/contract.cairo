use starknet::ContractAddress;

#[starknet::interface]
trait IAddress<TContractState> {
    fn get_address(self: @TContractState, name: felt252) -> ContractAddress;
    fn set_address(ref self: TContractState, name: felt252, address: ContractAddress);
}

#[dojo::contract]
mod address_actions {
    use super::IAddress;
    use starknet::ContractAddress;
    use dojo::model::ModelStorage;
    use rising_revenant::{
        world::{default_namespace, WorldTrait}, addresses::systems::{AddressBook, Address}
    };

    #[abi(embed_v0)]
    impl AddressImpl of IAddress<ContractState> {
        fn get_address(self: @ContractState, name: felt252) -> ContractAddress {
            let world = self.world(default_namespace());
            world.get_address(name)
        }

        fn set_address(ref self: ContractState, name: felt252, address: ContractAddress) {
            let mut world = self.world(default_namespace());
            world.assert_caller_is_creator();
            world.write_model(@Address { name, address });
        }
    }
}
