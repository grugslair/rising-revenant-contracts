use core::poseidon::poseidon_hash_span;
use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
use dojo::{world::WorldStorage, model::ModelStorage};
use openzeppelin_token::erc721::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
use rising_revenant::{
    game::{GameStorage, ClassHashVariant, models::GamePhasePreppingTrait, GameTrait},
    fortifications::{Fortifications, FortificationTokenTrait}, core::ToNonZero,
    utils::{felt252_to_u128, deploy_contract},
    care_packages::{Rarity, CarePackageStorage, CarePackage, CarePackageMarketTrait},
    tokens::{deploy_erc721_mintable, erc721_owner_of, erc721_mint}, game_pot::GamePotTrait,
    world::WorldTrait, seed::SeedProbability,
};
// use origami_defi::auction::vrgda::{LogisticVRGDA, VRGDATrait};
use cubit::f128::types::fixed::{Fixed, FixedTrait};

/// Calculates the types of fortifications based on total and randomness.
///
/// # Arguments
///
/// * `total` - The total number of fortifications.
/// * `randomness` - A random value used to determine the distribution of fortification types.
///
/// # Returns
///
/// A `Fortifications` struct containing the calculated number of palisades, trenches, walls, and
/// basements.
fn get_fortifications_types(total: u128, mut randomness: u128) -> Fortifications {
    let (palisades_trenches, walls_and_basements) = randomness.split_value(total);
    let (palisades_u128, trenches_u128) = randomness.split_value(palisades_trenches);
    let (walls_u128, basements_u128) = randomness.split_value(walls_and_basements);
    Fortifications {
        palisades: palisades_u128.try_into().unwrap(),
        trenches: trenches_u128.try_into().unwrap(),
        walls: walls_u128.try_into().unwrap(),
        basements: basements_u128.try_into().unwrap(),
    }
}

/// Returns the range of fortifications based on the rarity.
///
/// # Arguments
///
/// * `rarity` - The rarity level of the fortifications.
///
/// # Returns
///
/// A tuple containing the minimum and maximum extra fortifications plus one.
fn get_range_of_fortifications(rarity: Rarity) -> (u128, u128) {
    match rarity {
        Rarity::None => { panic!("Rarity not set") },
        Rarity::Common => (8, 1),
        Rarity::Rare => (10, 3),
        Rarity::Epic => (12, 4),
        Rarity::Legendary => (15, 6),
    }
}

/// Determines the fortifications based on rarity and randomness.
///
/// # Arguments
///
/// * `rarity` - The rarity level of the fortifications.
/// * `randomness` - A random value used to determine the fortifications.
///
/// # Returns
///
/// A `Fortifications` struct with the calculated fortifications.
fn get_fortifications(rarity: Rarity, randomness: felt252) -> Fortifications {
    let mut randomness = felt252_to_u128(randomness);
    let (base, divmod) = get_range_of_fortifications(rarity);
    let value = randomness.get_value(divmod.non_zero());
    get_fortifications_types(base + value, randomness)
}

/// Determines the rarity based on randomness.
///
/// # Arguments
///
/// * `randomness` - A random value used to determine the rarity.
///
/// # Returns
///
/// A `Rarity` enum value representing the determined rarity.
fn get_rarity(randomness: felt252) -> Rarity {
    let rarity = felt252_to_u128(randomness) % 100;
    if rarity < 65 {
        Rarity::Common
    } else if rarity < 85 {
        Rarity::Rare
    } else if rarity < 97 {
        Rarity::Epic
    } else {
        Rarity::Legendary
    }
}


#[generate_trait]
impl CarePackageImpl of CarePackageTrait {
    fn setup_care_package_market(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        base_uri: ByteArray,
        admin: ContractAddress,
        target_price_mag: u128,
        decay_constant_mag: u128,
        max_sellable: u64,
        time_scale_mag: u128,
    ) {
        self
            .set_care_package_market(
                game_id,
                self.deploy_care_package_token(game_id, game_name, base_uri, admin),
                target_price_mag,
                decay_constant_mag,
                max_sellable,
                time_scale_mag,
            );
    }

    fn deploy_care_package_token(
        ref self: WorldStorage,
        game_id: felt252,
        game_name: @ByteArray,
        base_uri: ByteArray,
        admin: ContractAddress,
    ) -> ContractAddress {
        deploy_erc721_mintable(
            self.get_class_hash(ClassHashVariant::ERC721Mintable),
            game_id,
            format!("RR Care Package {}", game_name),
            "RRCP",
            base_uri,
            admin,
            self.get_contract_address("care_package_actions"),
        )
    }

    fn open_care_package(ref self: WorldStorage, token_id: felt252, randomness: felt252) {
        let caller = get_caller_address();
        let care_package = self.get_care_package(token_id);
        self.assert_prep_ended(care_package.game_id);
        assert(caller == self.get_care_package_owner(@care_package), 'Not Owner');
        assert(!care_package.opened, 'Already opened');
        self.set_care_package_opened(token_id);
        let fortifications = get_fortifications(care_package.rarity, randomness);
        self.mint_fortifications(care_package.game_id, caller, fortifications);
        self.emit_care_package_contents(care_package.game_id, token_id, caller, fortifications);
    }

    fn purchase_care_package(
        ref self: WorldStorage, game_id: felt252, caller: ContractAddress, randomness: felt252,
    ) -> felt252 {
        let timestamp = get_block_timestamp();
        let phases = self.get_game_phase_prepping(game_id);
        phases.assert_preparing(timestamp);

        let mut market = self.get_care_package_market(game_id);
        let price = market.purchase_care_package(phases.prep_start, timestamp);
        let id = poseidon_hash_span([market.token_address.into(), market.sold.into()].span());
        self.set_care_package_sold(game_id, market.sold);

        self.pay_into_purchases_pot(game_id, caller, price);
        erc721_mint(market.token_address, caller, id.into());
        let rarity = get_rarity(randomness);
        self.set_care_package_rarity(game_id, id, rarity);
        self.emit_care_package_sold(game_id, id, rarity, timestamp, price, caller);
        id
    }

    // fn reveal_care_package_rarity(
    //     ref self: WorldStorage,
    //     game_id: felt252,
    //     token_id: felt252,
    //     caller: ContractAddress,
    //     randomness: felt252
    // ) {
    //     assert(caller == self.get_care_package_owner( token_id), 'Not Owner');
    //     assert(self.get_care_package_rarity(token_id) == Rarity::None, 'Already revealed');
    //     self.set_care_package_rarity(game_id, token_id, get_rarity(randomness));
    // }

    fn get_care_package_owner(self: @WorldStorage, care_package: @CarePackage) -> ContractAddress {
        erc721_owner_of(
            self.get_care_package_token_address(*care_package.game_id),
            (*care_package.token_id).into(),
        )
    }
    fn get_care_package_owner_from_id(self: @WorldStorage, token_id: felt252) -> ContractAddress {
        self.get_care_package_owner(@self.get_care_package(token_id))
    }
}
