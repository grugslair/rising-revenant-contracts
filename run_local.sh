#!/bin/sh

katana_log="katana.log"
torii_log="torii.log"
current_dir=$(pwd)

terminate_processes(){
    kill "$katana_pid"
    kill "$torii_pid"
    exit 0
}

trap 'terminate_processes' SIGINT

echo -e "\n####\n#### sozo build\n####\n"
sozo build
sleep 1


echo -e "\n####\n#### katana\n####\n"
{ (cd "$current_dir" && katana --disable-fee) > $katana_log; } &
katana_pid=$!
sleep 2
echo "Katana started"


echo -e "\n####\n#### deploy foo erc\n####\n"
declare_erc_output="1"
starkli declare deploy/foo_erc20.json --rpc http://0.0.0.0:5050 --account ./deploy/katana_account_1.json --keystore ./deploy/katana_keystore_1.json --keystore-password ""  > .tmp



while IFS= read -r line; do
    echo "$line"
    declare_erc_output="$line"
done < .tmp


erc_hash=$declare_erc_output

echo "$erc_hash"

deploy_erc_output=""
starkli deploy $erc_hash --rpc http://0.0.0.0:5050 --account ./deploy/katana_account_1.json --keystore ./deploy/katana_keystore_1.json --keystore-password "" >  .tmp1

while IFS= read -r line; do
    echo "$line"
    deploy_erc_output="$line"
done < .tmp1
deployed_contract=$deploy_erc_output
sleep 1


echo -e "\n####\n#### sozo migrate\n####\n"
# remove world_address in Scarb
sed -i  "s/.*world_address.*/#world_address = \"\"/" Scarb.toml

migrate_output=""
sozo migrate > .tmp2
while IFS= read -r line; do
    echo "$line"
    migrate_output="$migrate_output$line"'\n'
done < .tmp2

address=$(echo -n "$migrate_output" | grep "Successfully migrated World" | awk "{print \$NF}")

echo -e "\n===> World Address = $address\n"

# replace world_address in Scarb
sed -i  "s/#world_address = \"\"/world_address = \"$address\"/" Scarb.toml

echo -e "\n####\n#### start torii\n####\n"
sleep 1
{ (cd "$current_dir" && torii --world $address) > $torii_log; } &
torii_pid=$!

echo "The script has been completed, but the katana and torii processes are still running."
echo "Closing this process will also close the katana and torii processes."
echo -e "\nThe test erc20 address for create game is: \n$deployed_contract\n"

# make sure katana & torii are running
wait "$katana_pid"
wait "$torii_pid"
