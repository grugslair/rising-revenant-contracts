use starknet::{testing, ContractAddress};

fn impersonate(address: ContractAddress) {
    testing::set_contract_address(address);
    testing::set_account_contract_address(address);
}


fn ADMIN() -> ContractAddress {
    0x1.try_into().unwrap()
}

fn PLAYER_1() -> ContractAddress {
    0x4201.try_into().unwrap()
}

fn PLAYER_2() -> ContractAddress {
    0x4202.try_into().unwrap()
}

fn OTHER() -> ContractAddress {
    0x69.try_into().unwrap()
}
