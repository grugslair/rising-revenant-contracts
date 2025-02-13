import {
  RpcProvider,
  Account,
  CallData,
  byteArray,
  CairoCustomEnum,
  Contract,
  hash,
} from "starknet";

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const profile = process.argv[2];
const setupFileName = process.argv[3];
const gameName = process.argv[4];
const startTime = parseInt(process.argv[5]);

const gameActionsTag = "rising_revenant-game_actions";

const loadJson = (rpath) => {
  return JSON.parse(fs.readFileSync(path.resolve(__dirname, rpath)));
};

const getContractAddress = (mainfest, contractName) => {
  for (const contract of mainfest.contracts) {
    if (contract.tag === contractName) {
      return contract.address;
    }
  }
  return null;
};

const getContract = async (provider, contractAddress) => {
  console.log(contractAddress);
  const { abi: abi } = await provider.getClassAt(contractAddress);
  return new Contract(abi, contractAddress, provider);
};

const executeCalls = async (provider, account, calls) => {
  const transaction = await account.execute(calls);
  const response = await provider.waitForTransaction(
    transaction.transaction_hash
  );
  return response.transaction_hash;
};

const manifest = loadJson(`../manifest_${profile}.json`);

// connect provider
const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });

// connect your account. To adapt to your own account:
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);

const gameContract = await getContract(
  provider,
  getContractAddress(manifest, gameActionsTag)
);
const ONE_MAG = 0x10000000000000000;
const Dec18 = 1e18;

const valueToMag = (value) => {
  return BigInt(ONE_MAG * value);
};

const valueToDec18 = (value) => {
  return BigInt(Dec18 * value);
};

const parseEventVars = (values) => {
  let new_values = {};
  for (const str of ["efficacy", "mortalities", "power", "f_value"]) {
    new_values[str] = values[str];
  }
  new_values.min_radius_sq = BigInt(values.min_radius ** 2);
  new_values.max_radius_sq = BigInt(values.max_radius ** 2);
  new_values.radius_sq_increase = BigInt(values.radius_increase ** 2);
  return new_values;
};

const parseSetUpValues = (values, gameName, start_time) => {
  let new_values = {};
  for (const str of [
    "game_erc20_token",
    "game_beneficiary",
    "map_size_x",
    "map_size_y",
    "outpost_hp",
    "care_package_max_sellable",
    "event_min_interval",
    "outpost_uri",
    "care_package_uri",
    "claim_period",
  ]) {
    new_values[str] = values[str];
  }
  new_values.name = gameName;

  new_values.prep_start = start_time;
  new_values.prep_stop = start_time + values.prep_time;
  new_values.events_start = new_values.prep_stop + values.grace_time;

  // Outpost price
  new_values.outpost_price = valueToDec18(values.outpost_price);

  // Care package values
  new_values.care_package_target_price_mag = valueToMag(
    values.care_package_target_price
  );
  new_values.care_package_decay_constant_mag = valueToMag(
    values.care_package_decay_constant
  );
  new_values.care_package_time_scale_mag = valueToMag(
    values.care_package_time_scale
  );

  // Event values
  for (const str of ["dragon_vars", "goblin_vars", "earthquake_vars"]) {
    new_values[str] = parseEventVars(values[str]);
  }

  // Contribution values
  new_values.winner_purchase_permille = BigInt(
    values.winner_purchase_percent * 10
  );
  new_values.contribution_purchase_permille = BigInt(
    values.contribution_purchase_percent * 10
  );

  return new_values;
};

const config = loadJson(`../game_setup_configs/${setupFileName}.json`);
console.log(config);
const values = parseSetUpValues(config, gameName, startTime);
console.log(values);

const tx_hash = await executeCalls(provider, account, [
  gameContract.populate("create_game", values),
]);
console.log(tx_hash);
