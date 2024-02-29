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

# enable system -> component authorizations
COMPONENTS=(
    "CurrentGame"
    "GamePhases"
    "GameMap"
    "GameERC20"
    "GameTradeTax"
    "GamePotConsts"
    "GameState"
    "GamePot"
    "DevWallet"
    "Outpost"
    "OutpostMarket"
    "OutpostSetup"
    "PlayerInfo"
    "PlayerContribution"
    "ReinforcementMarket"
    "OutpostTrade"
    "ReinforcementTrade"
    "WorldEventSetup"
    "WorldEvent"
    "CurrentWorldEvent"
    "OutpostVerified"
)

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $WORLD_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $GAME_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $WORLD_EVENT_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $OUTPOST_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $REINFORCEMENTS_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $PAYMENT_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $TRADE_OUTPOST_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $TRADE_REINFORCEMENTS_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 0.2 
done


echo "Default authorizations have been successfully set."