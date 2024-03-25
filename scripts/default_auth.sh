#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";
# export RPC_URL="https://api.cartridge.gg/x/rr-demo/katana";

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
 CurrentGame,$GAME_ADDRESS \
 GamePhases,$GAME_ADDRESS \
 GameMap,$GAME_ADDRESS \
 GameERC20,$GAME_ADDRESS \
 GameTradeTax,$GAME_ADDRESS \
 GamePotConsts,$GAME_ADDRESS \
 GameState,$GAME_ADDRESS \
 GamePot,$GAME_ADDRESS \
 DevWallet,$GAME_ADDRESS \
 Outpost,$OUTPOST_ACTIONS_ADDRESS \
 OutpostMarket,$OUTPOST_ACTIONS_ADDRESS \
 OutpostSetup,$OUTPOST_ACTIONS_ADDRESS \
 PlayerInfo,$PAYMENT_ACTIONS_ADDRESS \
 PlayerContribution,$PAYMENT_ACTIONS_ADDRESS \
 ReinforcementMarket,$REINFORCEMENTS_ACTIONS_ADDRESS \
 OutpostTrade,$TRADE_OUTPOST_ACTIONS_ADDRESS \
 ReinforcementTrade,$TRADE_REINFORCEMENTS_ACTIONS_ADDRESS \
 WorldEventSetup,$WORLD_EVENT_ADDRESS \
 WorldEvent,$WORLD_EVENT_ADDRESS \
 CurrentWorldEvent,$WORLD_EVENT_ADDRESS \
 OutpostVerified,$WORLD_EVENT_ADDRESS \
 > /dev/null

echo "Default authorizations have been successfully set."