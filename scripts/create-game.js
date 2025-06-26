import {
  RpcProvider,
  Account,
  CallData,
  byteArray,
  CairoCustomEnum,
  Contract,
  hash,
} from "starknet";
import { loadAccountManifest, loadJson } from "./stark-utils.js";
import * as fs from "fs";
import commandLineArgs from "command-line-args";
import { program } from "commander";
import * as path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const gameActionsTag = "rising_revenant-game_actions";

const executeCalls = async (provider, account, calls) => {
  const transaction = await account.execute(calls);
  const response = await provider.waitForTransaction(
    transaction.transaction_hash
  );
  return response.transaction_hash;
};

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
    "max_outposts",
    "outpost_hp",
    "care_package_max_sellable",
    "event_min_interval",
    "outpost_uri",
    "care_package_uri",
    "claim_period",
    "event_created_contribution_points",
    "event_applied_contribution_points",
    "outpost_destroyed_contribution_points",
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

const argv = yargs(hideBin(process.argv))
  .usage("Usage: $0 <profile> <path> <name> <start_time> [options]")
  .positional("profile", {
    describe: 'The Scarb profile to use (e.g., "release", "sepolia")',
    type: "string",
  })
  .positional("path", {
    describe: "Path to the game configuration file",
    type: "string",
  })
  .positional("name", {
    describe: "Name of the Rising Revenant game",
    type: "string",
  })
  .positional("start_time", {
    describe: "Game start time in seconds since the Unix epoch (integer)",
    type: "number",
  })
  .option("password", {
    alias: "p",
    type: "string",
    describe:
      "Password for the keystore (required if --private_key is not provided)",
    default: null,
  })
  .option("private_key", {
    alias: "k",
    type: "string",
    describe:
      "Hex-encoded private key (required if --password is not provided)",
    default: null,
  })
  .check((argv) => {
    if (!argv.password && !argv.private_key) {
      throw new Error("You must provide either --password or --private_key.");
    }
    const [profile, path, name, start_time] = argv._;
    if (!Number.isInteger(start_time)) {
      throw new Error(
        "--start_time must be an integer (in seconds since epoch)."
      );
    }
    Object.assign(argv, { profile, path, name, start_time });
    return true;
  })
  .demandCommand(4, "You must provide: <profile> <path> <name> <start_time>")
  .strict().argv;

console.log(argv);

const account_manifest = await loadAccountManifest(
  argv.profile,
  argv.password,
  argv.private_key
);
const game_contract = account_manifest.getContract(gameActionsTag);
console.log();
const config = loadJson(argv.path);
const values = parseSetUpValues(config, argv.name, argv.start_time);
console.log(values);
const transaction_hash = await account_manifest.execute([
  game_contract.populate("create_game", values),
]);
console.log(transaction_hash);
