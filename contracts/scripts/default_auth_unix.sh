#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# export RPC_URL="http://localhost:5050";
export RPC_URL="https://api.cartridge.gg/x/rr-demo/katana";

export WORLD_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.world.address')

export GAME_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "game_actions" ).address')

export WORLD_EVENT_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "world_event_actions" ).address')

export REVENANT_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "revenant_actions" ).address')

export TRADE_ACTIONS_ADDRESS=$(cat ./target/dev/manifest.json | jq -r '.contracts[] | select(.name == "trade_actions").address')

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo actions : $GAME_ADDRESS
echo " "
echo world event actions : $WORLD_EVENT_ADDRESS
echo " "
echo revenant actions : $REVENANT_ACTIONS_ADDRESS
echo " "
echo trade actions : $TRADE_ACTIONS_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> component authorizations
COMPONENTS=("Game" "GameTracker"  "GameEntityCounter"   "WorldEvent" "WorldEventTracker"   "Trade"    "Revenant"    "ReinforcementBalance"   "PlayerInfo"   "Outpost" "OutpostPosition" )

for component in ${COMPONENTS[@]}; do
    sozo auth writer $component $REVENANT_ACTIONS_ADDRESS  --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sozo auth writer $component $WORLD_EVENT_ADDRESS    --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sozo auth writer $component $GAME_ADDRESS   --world $WORLD_ADDRESS --rpc-url $RPC_URL
    sozo auth writer $component $TRADE_ACTIONS_ADDRESS --world $WORLD_ADDRESS --rpc-url $RPC_URL
done

echo "Default authorizations have been successfully set."