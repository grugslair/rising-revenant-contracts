import sys
import os
import subprocess
from pathlib import Path
import dotenv
import json

CONTRACT_PATH = Path(__file__).parent.parent

dotenv.load_dotenv(CONTRACT_PATH / ".env")

print(os.environ["STARKNET_RPC_URL"])
print(os.environ["DOJO_ACCOUNT_ADDRESS"])
print(os.environ["DOJO_PRIVATE_KEY"])


def get_name(string):
    return string.rsplit("::", 1)[-1]


def get_world(data):
    return data["world"]["address"]


def get_contracts_addresses(data):
    return {get_name(c["name"]): c["address"] for c in data["contracts"]}


def get_model_name(model):
    return next(
        get_name(s["name"]) for s in reversed(model["abi"]) if s["type"] == "struct"
    )


def get_models(data):
    return {get_model_name(m): m["name"] for m in data["models"]}


def run_cmd(cmd, cwd):
    # os.environ["SYSTEMD_COLORS"] = "1"
    print(cmd)
    if type(cmd) is str:
        cmd = cmd.split(" ")
    process = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, encoding="utf-8")
    for c in iter(lambda: process.stdout.read(1), ""):
        sys.stdout.write(c)


def make_authorisations_string(data: dict[str, list[str]], contract_addresses):
    return " ".join(
        [
            f"{m},{contract_addresses[contract]}"
            for contract, models in data.items()
            for m in models
        ]
    )


def main():
    run_cmd("sozo migrate apply", CONTRACT_PATH)
    manifest_path = CONTRACT_PATH / f"manifests/dev/manifest.json"
    autorisations_path = CONTRACT_PATH / "authorisations.json"
    print(f"Manifest path: {manifest_path}")
    erc20_token_address = (
        "0x072599086bffce6593a2e08169c21d23564f08be1e1d0b8e05a9768f20469a3f"
    )
    authorisations = json.load(autorisations_path.open())
    manifest = json.load(manifest_path.open())

    world_address = get_world(manifest)
    models = get_models(manifest)
    contract_addresses = get_contracts_addresses(manifest)

    auth_string = make_authorisations_string(
        authorisations["writer"], contract_addresses
    )
    run_cmd(
        f"sozo auth grant writer --world {world_address} {auth_string}", CONTRACT_PATH
    )
    run_cmd(
        f"sozo execute {contract_addresses['game_actions']} set_game_erc20 --calldata 0x0,{erc20_token_address}"
    )


main()
