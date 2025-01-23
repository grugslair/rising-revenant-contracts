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

const erc20ContractName = "erc20_mintable_burnable";
const erc721ContractName = "erc721_mintable";

const gameActionsTag = "rising_revenant-game_actions";
const setClassHashEntryPoint = "set_class_hash";

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

const manifest = loadJson(`../manifest_${profile}.json`);

// connect provider
const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });

// connect your account. To adapt to your own account:
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);

const erc20MintableBurnableCairoEnum = new CairoCustomEnum({
  ERC20MintableBurnable: {},
});
const erc721MintableCairoEnum = new CairoCustomEnum({ ERC721Mintable: {} });

let gameContract = await getContract(
  provider,
  getContractAddress(manifest, gameActionsTag)
);

const declareContract = async (provider, account, profile, contractName) => {
  const contract = loadJson(
    `../target/${profile}/rising_revenant_${contractName}.contract_class.json`
  );

  const classHash = hash.computeContractClassHash(contract);
  try {
    await provider.getClassByHash(classHash);
    console.log(
      `${contractName} already declared with classHash\n\t\t${classHash}`
    );
  } catch {
    const casm = loadJson(
      `../target/${profile}/rising_revenant_${contractName}.compiled_contract_class.json`
    );
    const declareResponse = await account.declare({ contract, casm });
    await provider.waitForTransaction(declareResponse.transaction_hash);
    console.log(
      `${contractName} declared with classHash\n\t\t${declareResponse.class_hash}`
    );
  }
  return classHash;
};

const erc721ClassHash = await declareContract(
  provider,
  account,
  profile,
  erc721ContractName
);
const erc20ClassHash = await declareContract(
  provider,
  account,
  profile,
  erc20ContractName
);

const makeSetClassHashCall = (variant, classHash) => {
  gameContract.populate(setClassHashEntryPoint, {
    class_hash: classHash,
    variant,
  });
};

const calls = [
  makeSetClassHashCall(erc721MintableCairoEnum, erc721ClassHash),
  makeSetClassHashCall(erc20MintableBurnableCairoEnum, erc20ClassHash),
];

const transaction = await account.execute(calls);
const response = await provider.waitForTransaction(
  transaction.transaction_hash
);
console.log(response.transaction_hash);
