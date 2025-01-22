use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::{ModelStorage, Model}, event::EventStorage};
use rising_revenant::{
    fortifications::models::Fortifications, core::ToNonZero, utils::felt252_to_u128,
    vrgda::{LogisticVRGDA, VRGDATrait}, fixed::FixedToDecimal
};
use cubit::f128::{Fixed, FixedTrait, ONE_u128};

const N_RARITIES: u128 = 5;
const CARE_PACKAGE_CLASS_HASH_SELECTOR: felt252 = 'care-package';
#[derive(Serde, Copy, Drop, PartialEq, Introspect)]
enum Rarity {
    None,
    Common,
    Rare,
    Epic,
    Legendary,
}

#[derive(Drop, Serde, Introspect)]
struct LogisticVRGDAStore {
    target_price_mag: u128,
    decay_constant_mag: u128,
    max_sellable_mag: u128,
    time_scale_mag: u128,
}

impl LogisticVRGDAStoreIntoLogisticVRGDA of Into<@LogisticVRGDAStore, LogisticVRGDA> {
    fn into(self: @LogisticVRGDAStore) -> LogisticVRGDA {
        LogisticVRGDA {
            target_price: Fixed { mag: *self.target_price_mag, sign: false },
            decay_constant: Fixed { mag: *self.decay_constant_mag, sign: false },
            max_sellable: Fixed { mag: *self.max_sellable_mag, sign: false },
            time_scale: Fixed { mag: *self.time_scale_mag, sign: false },
        }
    }
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

#[dojo::model]
#[derive(Drop, Serde)]
struct CarePackageMarket {
    #[key]
    game_id: felt252,
    token_address: ContractAddress,
    vrgda: LogisticVRGDAStore,
    sold: u128,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CarePackage {
    #[key]
    token_id: felt252,
    game_id: felt252,
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

#[dojo::event]
#[derive(Drop, Serde, Copy)]
struct CarePackageContents {
    #[key]
    token_id: felt252,
    game_id: felt252,
    recipient: ContractAddress,
    fortifications: Fortifications,
}

#[generate_trait]
impl CarePackageMarketImpl of CarePackageMarketTrait {
    fn get_care_package_price(self: @CarePackageMarket, start_time: u64, timestamp: u64) -> u256 {
        let vrgda: LogisticVRGDA = self.vrgda.into();
        vrgda.get_vrgda_price((timestamp - start_time).into(), (*self.sold).into()).to_decimal(18)
    }
    fn purchase_care_package(ref self: CarePackageMarket, start_time: u64, timestamp: u64) -> u256 {
        let price = self.get_care_package_price(start_time, timestamp);
        self.sold += 1;
        price
    }
}

#[generate_trait]
impl CarePackageStorageImpl of CarePackageStorage {
    fn get_care_package(self: @WorldStorage, token_id: felt252) -> CarePackage {
        self.read_model(token_id)
    }

    fn set_care_package_rarity(
        ref self: WorldStorage, game_id: felt252, token_id: felt252, rarity: Rarity
    ) {
        self.write_model(@CarePackage { token_id, game_id, rarity, opened: false });
    }

    fn set_care_package_opened(ref self: WorldStorage, token_id: felt252) {
        self.write_member(Model::<CarePackage>::ptr_from_keys(token_id), selector!("opened"), true);
    }

    fn get_care_package_rarity(self: @WorldStorage, token_id: felt252) -> Rarity {
        self.read_member(Model::<CarePackage>::ptr_from_keys(token_id), selector!("rarity"))
    }

    fn get_care_package_game_id(self: @WorldStorage, token_id: felt252) -> felt252 {
        self.read_member(Model::<CarePackage>::ptr_from_keys(token_id), selector!("game_id"))
    }

    fn get_care_package_opened(self: @WorldStorage, token_id: felt252) -> bool {
        self.read_member(Model::<CarePackage>::ptr_from_keys(token_id), selector!("opened"))
    }

    fn set_care_package_market(
        ref self: WorldStorage,
        game_id: felt252,
        token_address: ContractAddress,
        target_price_mag: u128,
        decay_constant_mag: u128,
        max_sellable: u64,
        time_scale_mag: u128,
    ) {
        let max_sellable_mag = max_sellable.into() * ONE_u128;
        self
            .write_model(
                @CarePackageMarket {
                    game_id,
                    token_address,
                    vrgda: LogisticVRGDAStore {
                        target_price_mag, decay_constant_mag, max_sellable_mag, time_scale_mag
                    },
                    sold: 0
                }
            );
    }

    fn get_care_package_market(self: @WorldStorage, game_id: felt252) -> CarePackageMarket {
        self.read_model(game_id)
    }

    fn get_care_package_token_address(self: @WorldStorage, game_id: felt252) -> ContractAddress {
        self
            .read_member(
                Model::<CarePackageTokenAddress>::ptr_from_keys(game_id), selector!("token_address")
            )
    }

    fn emit_care_package_contents(
        ref self: WorldStorage,
        game_id: felt252,
        token_id: felt252,
        recipient: ContractAddress,
        fortifications: Fortifications,
    ) {
        self.emit_event(@CarePackageContents { game_id, token_id, recipient, fortifications });
    }
}
