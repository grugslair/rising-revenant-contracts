use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use risingrevenant::components::{
    game::{
        CurrentGame, GamePhases, GameMap, GameERC20, GameTradeTax, GamePotConsts, GameState,
        GamePot, DevWallet, Position
    },
    outpost::{Outpost, OutpostMarket, OutpostSetup}, player::{PlayerInfo, PlayerContribution},
    reinforcement::{ReinforcementBalance}, trade::{OutpostTrade, ReinforcementTrade},
    world_event::{WorldEventSetup, WorldEvent, CurrentWorldEvent, OutpostVerified}
};


trait SetTrait<T> {
    fn set(self: @T, world: IWorldDispatcher);
}

trait GetGameTrait<T> {
    fn get(world: IWorldDispatcher, game_id: u128) -> T;
}

trait GetTrait<T, K> {
    fn get(world: IWorldDispatcher, game_id: u128, key: K) -> T;
}

impl CurrentGameGetImpl of GetTrait<CurrentGame, ContractAddress> {
    fn get(world: IWorldDispatcher, game_id: u128, key: ContractAddress) -> CurrentGame {
        get!(world, key, CurrentGame)
    }
}
impl DevWalletGetImpl of GetTrait<DevWallet, ContractAddress> {
    fn get(world: IWorldDispatcher, game_id: u128, key: ContractAddress) -> DevWallet {
        get!(world, (game_id, key), DevWallet)
    }
}
impl OutpostGetImpl of GetTrait<Outpost, Position> {
    fn get(world: IWorldDispatcher, game_id: u128, key: Position) -> Outpost {
        get!(world, (game_id, key), Outpost)
    }
}
impl PlayerInfoGetImpl of GetTrait<PlayerInfo, ContractAddress> {
    fn get(world: IWorldDispatcher, game_id: u128, key: ContractAddress) -> PlayerInfo {
        get!(world, (game_id, key), PlayerInfo)
    }
}
impl PlayerContributionGetImpl of GetTrait<PlayerContribution, ContractAddress> {
    fn get(world: IWorldDispatcher, game_id: u128, key: ContractAddress) -> PlayerContribution {
        get!(world, (game_id, key), PlayerContribution)
    }
}
impl OutpostTradeGetImpl of GetTrait<OutpostTrade, u128> {
    fn get(world: IWorldDispatcher, game_id: u128, key: u128) -> OutpostTrade {
        get!(world, (game_id, key), OutpostTrade)
    }
}
impl ReinforcementTradeGetImpl of GetTrait<ReinforcementTrade, u128> {
    fn get(world: IWorldDispatcher, game_id: u128, key: u128) -> ReinforcementTrade {
        get!(world, (game_id, key), ReinforcementTrade)
    }
}
impl WorldEventGetImpl of GetTrait<WorldEvent, u128> {
    fn get(world: IWorldDispatcher, game_id: u128, key: u128) -> WorldEvent {
        get!(world, (game_id, key), WorldEvent)
    }
}
impl OutpostVerifiedGetImpl of GetTrait<OutpostVerified, (u128, Position)> {
    fn get(world: IWorldDispatcher, game_id: u128, key: (u128, Position)) -> OutpostVerified {
        let (world_event_id, outpost_id) = key;
        get!(world, (game_id, world_event_id, outpost_id), OutpostVerified)
    }
}

impl GameTradeTaxGetImpl of GetGameTrait<GameTradeTax> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GameTradeTax {
        get!(world, game_id, GameTradeTax)
    }
}

impl GameERC20GetImpl of GetGameTrait<GameERC20> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GameERC20 {
        get!(world, game_id, GameERC20)
    }
}

impl CurrentWorldEventGetImpl of GetGameTrait<CurrentWorldEvent> {
    fn get(world: IWorldDispatcher, game_id: u128) -> CurrentWorldEvent {
        get!(world, game_id, CurrentWorldEvent)
    }
}

impl WorldEventSetupGetImpl of GetGameTrait<WorldEventSetup> {
    fn get(world: IWorldDispatcher, game_id: u128) -> WorldEventSetup {
        get!(world, game_id, WorldEventSetup)
    }
}

impl ReinforcementBalanceGetImpl of GetGameTrait<ReinforcementBalance> {
    fn get(world: IWorldDispatcher, game_id: u128) -> ReinforcementBalance {
        get!(world, game_id, ReinforcementBalance)
    }
}

impl OutpostSetupGetImpl of GetGameTrait<OutpostSetup> {
    fn get(world: IWorldDispatcher, game_id: u128) -> OutpostSetup {
        get!(world, game_id, OutpostSetup)
    }
}

impl OutpostMarketGetImpl of GetGameTrait<OutpostMarket> {
    fn get(world: IWorldDispatcher, game_id: u128) -> OutpostMarket {
        get!(world, game_id, OutpostMarket)
    }
}

impl GameStateGetImpl of GetGameTrait<GameState> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GameState {
        get!(world, game_id, GameState)
    }
}

impl GamePhasesGetImpl of GetGameTrait<GamePhases> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GamePhases {
        get!(world, game_id, GamePhases)
    }
}

impl GamePotGetImpl of GetGameTrait<GamePot> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GamePot {
        get!(world, game_id, GamePot)
    }
}

impl GamePotConstsGetImpl of GetGameTrait<GamePotConsts> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GamePotConsts {
        get!(world, game_id, GamePotConsts)
    }
}

impl GameMapGetImpl of GetGameTrait<GameMap> {
    fn get(world: IWorldDispatcher, game_id: u128) -> GameMap {
        get!(world, game_id, GameMap)
    }
}

impl GameERC20SetImpl of SetTrait<GameERC20> {
    fn set(self: @GameERC20, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl CurrentWorldEventSetImpl of SetTrait<CurrentWorldEvent> {
    fn set(self: @CurrentWorldEvent, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl WorldEventSetupSetImpl of SetTrait<WorldEventSetup> {
    fn set(self: @WorldEventSetup, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl ReinforcementBalanceSetImpl of SetTrait<ReinforcementBalance> {
    fn set(self: @ReinforcementBalance, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl OutpostSetupSetImpl of SetTrait<OutpostSetup> {
    fn set(self: @OutpostSetup, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl OutpostMarketSetImpl of SetTrait<OutpostMarket> {
    fn set(self: @OutpostMarket, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}


impl GameStateSetImpl of SetTrait<GameState> {
    fn set(self: @GameState, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl GamePhasesSetImpl of SetTrait<GamePhases> {
    fn set(self: @GamePhases, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl GamePotSetImpl of SetTrait<GamePot> {
    fn set(self: @GamePot, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl GamePotConstsSetImpl of SetTrait<GamePotConsts> {
    fn set(self: @GamePotConsts, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl GameMapSetImpl of SetTrait<GameMap> {
    fn set(self: @GameMap, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}

impl DevWalletSetImpl of SetTrait<DevWallet> {
    fn set(self: @DevWallet, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl OutpostSetImpl of SetTrait<Outpost> {
    fn set(self: @Outpost, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl PlayerInfoSetImpl of SetTrait<PlayerInfo> {
    fn set(self: @PlayerInfo, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl PlayerContributionSetImpl of SetTrait<PlayerContribution> {
    fn set(self: @PlayerContribution, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl OutpostTradeSetImpl of SetTrait<OutpostTrade> {
    fn set(self: @OutpostTrade, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl ReinforcementTradeSetImpl of SetTrait<ReinforcementTrade> {
    fn set(self: @ReinforcementTrade, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl WorldEventSetImpl of SetTrait<WorldEvent> {
    fn set(self: @WorldEvent, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
impl OutpostVerifiedSetImpl of SetTrait<OutpostVerified> {
    fn set(self: @OutpostVerified, world: IWorldDispatcher) {
        set!(world, (*self,));
    }
}
