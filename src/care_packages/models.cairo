use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}};
use rising_revenant::{
    fortifications::models::Fortifications, core::ToNonZero, utils::felt252_to_u128,
    vrgda::{LogisticVRGDA, VRGDATrait}, fixed::FixedToDecimal
};
use cubit::f128::types::fixed::{Fixed, FixedTrait};

const N_RARITIES: u128 = 5;
const CARE_PACKAGE_CLASS_HASH_SELECTOR: felt252 = 'care-package';
#[derive(Serde, Copy, Drop, PartialEq)]
enum Rarity {
    None,
    Common,
    Rare,
    Epic,
    Legendary,
}

impl UTIntoRarity<T, +TryInto<T, u8>,> of Into<T, Rarity> {
    fn into(self: T) -> Rarity {
        match self.try_into().unwrap() {
            0_u8 => Rarity::None,
            1_u8 => Rarity::Common,
            2_u8 => Rarity::Rare,
            3_u8 => Rarity::Epic,
            4_u8 => Rarity::Legendary,
            _ => panic!("Invalid rarity"),
        }
    }
}


struct U256 {
    high: u128,
    low: u128,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CarePackage {
    #[key]
    game_id: felt252,
    #[key]
    token_id: (u128, u128),
    rarity: Rarity,
    opened: bool,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CarePackageTokenAddress {
    #[key]
    game_id: felt252,
    contract_address: ContractAddress,
}


#[generate_trait]
impl CarePackageStorageImpl of CarePackageStorage {
    fn get_care_package(self: @WorldStorage, game_id: felt252, token_id: u256) -> CarePackage {
        self.read_model((game_id, token_id))
    }
    fn set_care_package_rarity(
        ref self: WorldStorage, game_id: felt252, token_id: u256, rarity: Rarity
    ) {
        let token_id = (token_id.low.into(), token_id.high.into());
        self.write_model(@CarePackage { game_id, token_id, rarity, opened: false });
    }

    fn set_care_package_opened(ref self: WorldStorage, game_id: felt252, token_id: felt252) {
        self
            .write_member(
                Model::<CarePackage>::ptr_from_keys((game_id, token_id)), selector!("opened"), true
            );
    }

    fn get_care_package_rarity(self: @WorldStorage, game_id: felt252, token_id: felt252) -> Rarity {
        self
            .read_member(
                Model::<CarePackage>::ptr_from_keys((game_id, token_id)), selector!("rarity")
            )
    }


    fn get_care_package_opened(self: @WorldStorage, game_id: felt252, token_id: felt252) -> bool {
        self
            .read_member(
                Model::<CarePackage>::ptr_from_keys((game_id, token_id)), selector!("opened")
            )
    }

    fn set_care_package_token_address(
        ref self: WorldStorage, game_id: felt252, contract_address: ContractAddress
    ) {
        self.write_model(@CarePackageTokenAddress { game_id, contract_address });
    }

    fn get_care_package_token_address(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        self
            .read_member(
                Model::<CarePackageTokenAddress>::ptr_from_keys(game_id),
                selector!("contract_address")
            )
    }
}
