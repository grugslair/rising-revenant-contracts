use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher};


#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum DNSUserType {
    None,
    Owner,
    Writer,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct DNSDomain {
    #[key]
    domain: felt252,
    registered: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct DNSAddress {
    #[key]
    domain: felt252,
    #[key]
    path: felt252,
    owner: ContractAddress,
    address: ContractAddress,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct DNSUser {
    #[key]
    domain: felt252,
    #[key]
    user: ContractAddress,
    level: DNSUserType,
}

#[generate_trait]
impl DNSReadImpl of DNSRead {
    fn domain_exists(self: @IWorldDispatcher, domain: felt252) -> bool {
        DNSDomainStore::get_registered(*self, domain)
    }
    fn get_user_level(
        self: @IWorldDispatcher, domain: felt252, user: ContractAddress
    ) -> DNSUserType {
        DNSUserStore::get_level(*self, domain, user)
    }
    fn is_domain_owner(self: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool {
        match self.get_user_level(domain, user) {
            DNSUserType::Owner => true,
            _ => false,
        }
    }
    fn can_write_domain(self: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool {
        match self.get_user_level(domain, user) {
            DNSUserType::Writer | DNSUserType::Owner => true,
            _ => false,
        }
    }
    fn get_address(self: @IWorldDispatcher, domain: felt252, path: felt252) -> ContractAddress {
        DNSAddressStore::get_address(*self, domain, path)
    }
}

#[generate_trait]
impl DNSImpl of DNSWrite {
    fn register_domain(self: IWorldDispatcher, domain: felt252) {
        assert(!self.domain_exists(domain), 'Domain already exists');
        DNSDomain { domain, registered: true }.set(self);
        self.set_user_level(domain, get_caller_address(), DNSUserType::Owner);
    }
    fn set_user_level(
        self: IWorldDispatcher, domain: felt252, user: ContractAddress, level: DNSUserType
    ) {
        assert(self.is_domain_owner(domain, get_caller_address()), 'Caller is not an owner');
        DNSUser { domain, user, level }.set(self);
    }
    fn set_address(
        self: IWorldDispatcher, domain: felt252, path: felt252, address: ContractAddress
    ) {
        let caller = get_caller_address();
        let model = DNSAddressStore::get(self, domain, path);
        if model.address.is_non_zero() {
            assert(
                self.is_domain_owner(domain, caller) || model.owner == caller,
                'Caller is not an owner'
            );
        }
        assert(self.can_write_domain(domain, caller), 'Caller cannot writer');
        DNSAddress { domain, path, owner: caller, address }.set(self);
    }
}


#[dojo::interface]
trait IDNSTrait {
    fn domain_exists(world: @IWorldDispatcher, domain: felt252) -> bool;
    fn register_domain(ref world: IWorldDispatcher, domain: felt252);
    fn set_address(
        ref world: IWorldDispatcher, domain: felt252, path: felt252, address: ContractAddress
    );
    fn get_address(ref world: IWorldDispatcher, domain: felt252, path: felt252) -> ContractAddress;
    fn set_owner(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress);
    fn set_writer(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress);
    fn remove_user(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress);
    fn is_owner(world: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool;
    fn can_write(world: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool;
}

#[dojo::contract]
mod dns {
    use starknet::{ContractAddress, get_caller_address};
    use super::{IDNSTrait, DNSRead, DNSWrite, DNSUserType};

    #[abi(embed_v0)]
    impl IDNSImpl of IDNSTrait<ContractState> {
        fn domain_exists(world: @IWorldDispatcher, domain: felt252) -> bool {
            world.domain_exists(domain)
        }
        fn register_domain(ref world: IWorldDispatcher, domain: felt252) {
            world.register_domain(domain);
        }
        fn set_address(
            ref world: IWorldDispatcher, domain: felt252, path: felt252, address: ContractAddress
        ) {
            world.set_address(domain, path, address);
        }
        fn get_address(
            ref world: IWorldDispatcher, domain: felt252, path: felt252
        ) -> ContractAddress {
            world.get_address(domain, path)
        }
        fn set_owner(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress) {
            world.set_user_level(domain, user, DNSUserType::Owner);
        }
        fn set_writer(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress) {
            world.set_user_level(domain, user, DNSUserType::Writer);
        }
        fn remove_user(ref world: IWorldDispatcher, domain: felt252, user: ContractAddress) {
            world.set_user_level(domain, user, DNSUserType::None);
        }
        fn is_owner(world: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool {
            world.is_domain_owner(domain, user)
        }
        fn can_write(world: @IWorldDispatcher, domain: felt252, user: ContractAddress) -> bool {
            world.can_write_domain(domain, user)
        }
    }
}

