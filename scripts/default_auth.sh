#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";
# export RPC_URL="https://api.cartridge.gg/x/rr-demo/katana";

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export GAME_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::systems::game::game_actions").address')

export WORLD_EVENT_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::systems::world_event::world_event_actions").address')

export REVENANT_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::systems::revenant::revenant_actions").address')

export TRADE_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::systems::trade_reinforcement::trade_reinforcement_actions").address')

export TRADE_REV_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "risingrevenant::systems::trade_revenant::trade_revenant_actions").address')

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo game actions : $GAME_ADDRESS
echo " "
echo world event actions : $WORLD_EVENT_ADDRESS
echo " "
echo revenant actions : $REVENANT_ACTIONS_ADDRESS
echo " "
echo trade actions : $TRADE_ACTIONS_ADDRESS
echo " "
echo trade actions : $TRADE_REV_ACTIONS_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> component authorizations
COMPONENTS=("WorldEvent" "TradeReinforcement" "TradeRevenant" "Revenant" "ReinforcementBalance" "PlayerInfo" "Outpost" "OutpostPosition" "Game" "GameCountTracker" "GameEntityCounter")



for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $REVENANT_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 1 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $WORLD_EVENT_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 1 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $GAME_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 1 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $TRADE_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 1 
done

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $TRADE_REV_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sleep 1 
done

echo "Default authorizations have been successfully set."