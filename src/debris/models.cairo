use starknet::ContractAddress;
use dojo::{world::WorldStorage, model::ModelStorage};
use rising_revenant::erc20_mintable_burnable::erc20_mint;

#[derive(Drop)]
struct Debris {
    stone: u256,
    wood: u256,
    obsidian: u256,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct DebrisAddresses {
    #[key]
    game_id: felt252,
    stone: ContractAddress,
    wood: ContractAddress,
    obsidian: ContractAddress,
}

#[generate_trait]
impl DebrisStorageImpl of DebrisStorage {
    fn get_debris_addresses(self: @WorldStorage, game_id: felt252) -> DebrisAddresses {
        self.read_model(game_id)
    }

    fn set_debris_addresses(
        ref self: WorldStorage,
        game_id: felt252,
        stone: ContractAddress,
        wood: ContractAddress,
        obsidian: ContractAddress,
    ) {
        self.write_model(@DebrisAddresses { game_id, stone, wood, obsidian });
    }

    fn mint_debris(
        ref self: WorldStorage, game_id: felt252, player: ContractAddress, debris: Debris,
    ) {
        let DebrisAddresses {
            game_id: _, stone: stone_address, wood: wood_address, obsidian: obsidian_address,
        } = self.get_debris_addresses(game_id);
        let Debris { stone, wood, obsidian } = debris;
        if stone.is_non_zero() {
            erc20_mint(stone_address, player, stone);
        }
        if wood.is_non_zero() {
            erc20_mint(wood_address, player, wood);
        }
        if obsidian.is_non_zero() {
            erc20_mint(obsidian_address, player, obsidian);
        }
    }
}
