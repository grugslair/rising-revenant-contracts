#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";
# export RPC_URL="https://api.cartridge.gg/x/rr-demo/katana";
# export RPC_URL="https://starknet-sepolia.public.blastapi.io/rpc/v0_6";

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export GAME_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::game::game_actions").address')

export WORLD_EVENT_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::world_event::world_event_actions").address')

export OUTPOST_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::outpost::outpost_actions").address')

export REINFORCEMENTS_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::reinforcement::reinforcement_actions").address')

export PAYMENT_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::payment::payment_actions").address')

export TRADE_OUTPOST_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::trade_outpost::trade_outpost_actions").address')

export TRADE_REINFORCEMENTS_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::contracts::trade_reinforcement::trade_reinforcement_actions").address')


echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo game actions : $GAME_ADDRESS
echo " "
echo world event actions : $WORLD_EVENT_ADDRESS
echo " "
echo outpost actions : $OUTPOST_ACTIONS_ADDRESS
echo " "
echo reinforcements actions : $REINFORCEMENTS_ACTIONS_ADDRESS
echo " "
echo payment actions : $PAYMENT_ACTIONS_ADDRESS
echo " "
echo trade outpost actions : $TRADE_OUTPOST_ACTIONS_ADDRESS
echo " "
echo trade reinforcements actions : $TRADE_REINFORCEMENTS_ACTIONS_ADDRESS
echo "---------------------------------------------------------------------------"


# enable system -> models authorizations
sozo auth grant --world $WORLD_ADDRESS --wait writer \
 CurrentGame,$WORLD_ADDRESS \
 CurrentGame,$GAME_ADDRESS \
 CurrentGame,$WORLD_EVENT_ADDRESS \
 CurrentGame,$OUTPOST_ACTIONS_ADDRESS \
 CurrentGame,$REINFORCEMENTS_ACTIONS_ADDRESS \
 CurrentGame,$PAYMENT_ACTIONS_ADDRESS \
 CurrentGame,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 CurrentGame,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePhases,$WORLD_ADDRESS \
 GamePhases,$GAME_ADDRESS \
 GamePhases,$WORLD_EVENT_ADDRESS \
 GamePhases,$OUTPOST_ACTIONS_ADDRESS \
 GamePhases,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePhases,$PAYMENT_ACTIONS_ADDRESS \
 GamePhases,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GamePhases,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GameMap,$WORLD_ADDRESS \
 GameMap,$GAME_ADDRESS \
 GameMap,$WORLD_EVENT_ADDRESS \
 GameMap,$OUTPOST_ACTIONS_ADDRESS \
 GameMap,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GameMap,$PAYMENT_ACTIONS_ADDRESS \
 GameMap,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GameMap,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GameERC20,$WORLD_ADDRESS \
 GameERC20,$GAME_ADDRESS \
 GameERC20,$WORLD_EVENT_ADDRESS \
 GameERC20,$OUTPOST_ACTIONS_ADDRESS \
 GameERC20,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GameERC20,$PAYMENT_ACTIONS_ADDRESS \
 GameERC20,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GameERC20,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GameTradeTax,$WORLD_ADDRESS \
 GameTradeTax,$GAME_ADDRESS \
 GameTradeTax,$WORLD_EVENT_ADDRESS \
 GameTradeTax,$OUTPOST_ACTIONS_ADDRESS \
 GameTradeTax,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GameTradeTax,$PAYMENT_ACTIONS_ADDRESS \
 GameTradeTax,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GameTradeTax,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePotConsts,$WORLD_ADDRESS \
 GamePotConsts,$GAME_ADDRESS \
 GamePotConsts,$WORLD_EVENT_ADDRESS \
 GamePotConsts,$OUTPOST_ACTIONS_ADDRESS \
 GamePotConsts,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePotConsts,$PAYMENT_ACTIONS_ADDRESS \
 GamePotConsts,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GamePotConsts,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GameState,$WORLD_ADDRESS \
 GameState,$GAME_ADDRESS \
 GameState,$WORLD_EVENT_ADDRESS \
 GameState,$OUTPOST_ACTIONS_ADDRESS \
 GameState,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GameState,$PAYMENT_ACTIONS_ADDRESS \
 GameState,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GameState,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePot,$WORLD_ADDRESS \
 GamePot,$GAME_ADDRESS \
 GamePot,$WORLD_EVENT_ADDRESS \
 GamePot,$OUTPOST_ACTIONS_ADDRESS \
 GamePot,$REINFORCEMENTS_ACTIONS_ADDRESS \
 GamePot,$PAYMENT_ACTIONS_ADDRESS \
 GamePot,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 GamePot,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 DevWallet,$WORLD_ADDRESS \
 DevWallet,$GAME_ADDRESS \
 DevWallet,$WORLD_EVENT_ADDRESS \
 DevWallet,$OUTPOST_ACTIONS_ADDRESS \
 DevWallet,$REINFORCEMENTS_ACTIONS_ADDRESS \
 DevWallet,$PAYMENT_ACTIONS_ADDRESS \
 DevWallet,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 DevWallet,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 Outpost,$WORLD_ADDRESS \
 Outpost,$GAME_ADDRESS \
 Outpost,$WORLD_EVENT_ADDRESS \
 Outpost,$OUTPOST_ACTIONS_ADDRESS \
 Outpost,$REINFORCEMENTS_ACTIONS_ADDRESS \
 Outpost,$PAYMENT_ACTIONS_ADDRESS \
 Outpost,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 Outpost,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostMarket,$WORLD_ADDRESS \
 OutpostMarket,$GAME_ADDRESS \
 OutpostMarket,$WORLD_EVENT_ADDRESS \
 OutpostMarket,$OUTPOST_ACTIONS_ADDRESS \
 OutpostMarket,$REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostMarket,$PAYMENT_ACTIONS_ADDRESS \
 OutpostMarket,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 OutpostMarket,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostSetup,$WORLD_ADDRESS \
 OutpostSetup,$GAME_ADDRESS \
 OutpostSetup,$WORLD_EVENT_ADDRESS \
 OutpostSetup,$OUTPOST_ACTIONS_ADDRESS \
 OutpostSetup,$REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostSetup,$PAYMENT_ACTIONS_ADDRESS \
 OutpostSetup,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 OutpostSetup,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 PlayerInfo,$WORLD_ADDRESS \
 PlayerInfo,$GAME_ADDRESS \
 PlayerInfo,$WORLD_EVENT_ADDRESS \
 PlayerInfo,$OUTPOST_ACTIONS_ADDRESS \
 PlayerInfo,$REINFORCEMENTS_ACTIONS_ADDRESS \
 PlayerInfo,$PAYMENT_ACTIONS_ADDRESS \
 PlayerInfo,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 PlayerInfo,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 PlayerContribution,$WORLD_ADDRESS \
 PlayerContribution,$GAME_ADDRESS \
 PlayerContribution,$WORLD_EVENT_ADDRESS \
 PlayerContribution,$OUTPOST_ACTIONS_ADDRESS \
 PlayerContribution,$REINFORCEMENTS_ACTIONS_ADDRESS \
 PlayerContribution,$PAYMENT_ACTIONS_ADDRESS \
 PlayerContribution,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 PlayerContribution,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 ReinforcementMarket,$WORLD_ADDRESS \
 ReinforcementMarket,$GAME_ADDRESS \
 ReinforcementMarket,$WORLD_EVENT_ADDRESS \
 ReinforcementMarket,$OUTPOST_ACTIONS_ADDRESS \
 ReinforcementMarket,$REINFORCEMENTS_ACTIONS_ADDRESS \
 ReinforcementMarket,$PAYMENT_ACTIONS_ADDRESS \
 ReinforcementMarket,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 ReinforcementMarket,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostTrade,$WORLD_ADDRESS \
 OutpostTrade,$GAME_ADDRESS \
 OutpostTrade,$WORLD_EVENT_ADDRESS \
 OutpostTrade,$OUTPOST_ACTIONS_ADDRESS \
 OutpostTrade,$REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostTrade,$PAYMENT_ACTIONS_ADDRESS \
 OutpostTrade,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 OutpostTrade,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 ReinforcementTrade,$WORLD_ADDRESS \
 ReinforcementTrade,$GAME_ADDRESS \
 ReinforcementTrade,$WORLD_EVENT_ADDRESS \
 ReinforcementTrade,$OUTPOST_ACTIONS_ADDRESS \
 ReinforcementTrade,$REINFORCEMENTS_ACTIONS_ADDRESS \
 ReinforcementTrade,$PAYMENT_ACTIONS_ADDRESS \
 ReinforcementTrade,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 ReinforcementTrade,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 WorldEventSetup,$WORLD_ADDRESS \
 WorldEventSetup,$GAME_ADDRESS \
 WorldEventSetup,$WORLD_EVENT_ADDRESS \
 WorldEventSetup,$OUTPOST_ACTIONS_ADDRESS \
 WorldEventSetup,$REINFORCEMENTS_ACTIONS_ADDRESS \
 WorldEventSetup,$PAYMENT_ACTIONS_ADDRESS \
 WorldEventSetup,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 WorldEventSetup,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 WorldEvent,$WORLD_ADDRESS \
 WorldEvent,$GAME_ADDRESS \
 WorldEvent,$WORLD_EVENT_ADDRESS \
 WorldEvent,$OUTPOST_ACTIONS_ADDRESS \
 WorldEvent,$REINFORCEMENTS_ACTIONS_ADDRESS \
 WorldEvent,$PAYMENT_ACTIONS_ADDRESS \
 WorldEvent,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 WorldEvent,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 CurrentWorldEvent,$WORLD_ADDRESS \
 CurrentWorldEvent,$GAME_ADDRESS \
 CurrentWorldEvent,$WORLD_EVENT_ADDRESS \
 CurrentWorldEvent,$OUTPOST_ACTIONS_ADDRESS \
 CurrentWorldEvent,$REINFORCEMENTS_ACTIONS_ADDRESS \
 CurrentWorldEvent,$PAYMENT_ACTIONS_ADDRESS \
 CurrentWorldEvent,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 CurrentWorldEvent,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostVerified,$WORLD_ADDRESS \
 OutpostVerified,$GAME_ADDRESS \
 OutpostVerified,$WORLD_EVENT_ADDRESS \
 OutpostVerified,$OUTPOST_ACTIONS_ADDRESS \
 OutpostVerified,$REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostVerified,$PAYMENT_ACTIONS_ADDRESS \
 OutpostVerified,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 OutpostVerified,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \


 > /dev/null
 
echo "Default authorizations have been successfully set."