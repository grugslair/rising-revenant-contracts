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
import toml from "toml";
import * as accounts from "web3-eth-accounts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const profile = process.argv[2];

const erc20ContractName = "erc20_mintable_burnable";
const erc721ContractName = "erc721_mintable";
const gamePotContractName = "game_pot";

const gameActionsTag = "rising_revenant-game_actions";

const setClassHashEntryPoint = "set_class_hash";
const setVRFAddressEntryPoint = "set_vrf_address";

const loadToml = (rpath) => {
  return toml.parse(fs.readFileSync(rpath));
};

const loadJson = (rpath) => {
  return JSON.parse(fs.readFileSync(path.resolve(__dirname, rpath)));
};

let dojo_profile = loadToml(`./dojo_${profile}.toml`);

const accountAddress = dojo_profile.env.account_address;
const rpcUrl = dojo_profile.env.rpc_url;
const keystorePath = dojo_profile.env.keystore_path;

const readKeystorePK = async (keystorePath, accountAddress, password) => {
  let data = loadJson(keystorePath);
  data.address = accountAddress;
  return (await accounts.decrypt(data, password)).privateKey;
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
  const { abi } = await provider.getClassAt(contractAddress);
  return new Contract(abi, contractAddress, provider);
};

const manifest = loadJson(`../manifest_${profile}.json`);
const config = loadJson(`../config/${profile}.json`);

// connect provider
const provider = new RpcProvider({ nodeUrl: rpcUrl });

// connect your account. To adapt to your own account:
const privateKey = await readKeystorePK(
  keystorePath,
  accountAddress,
  process.env.KEYSTORE_PASSWORD
);
const account = new Account(provider, accountAddress, privateKey);

const erc20MintableBurnableCairoEnum = new CairoCustomEnum({
  ERC20MintableBurnable: {},
});
const erc721MintableCairoEnum = new CairoCustomEnum({ ERC721Mintable: {} });
const gamePotCairoEnum = new CairoCustomEnum({ GamePot: {} });

const gameContract = await getContract(
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
const gamePotClassHash = await declareContract(
  provider,
  account,
  profile,
  gamePotContractName
);

const executeCalls = async (provider, account, calls) => {
  const transaction = await account.execute(calls);
  const response = await provider.waitForTransaction(
    transaction.transaction_hash
  );
  return response.transaction_hash;
};

const makeSetClassHashCall = (variant, classHash) => {
  return gameContract.populate(setClassHashEntryPoint, {
    class_hash: classHash,
    variant,
  });
};

const makeSetClassHashCalls = async (classHashes) => {
  let calls = [];
  for (const [variant, classHash] of classHashes) {
    if (BigInt(classHash) !== (await gameContract.get_class_hash(variant)))
      calls.push(makeSetClassHashCall(variant, classHash));
  }
  return calls;
};

const makeSetVRFAddressCall = async (vrfAddress) => {
  const CurrentVRFAddress = await gameContract.get_vrf_address();
  if ((await gameContract.get_vrf_address()) !== BigInt(vrfAddress)) {
    return [
      gameContract.populate(setVRFAddressEntryPoint, {
        contract_address: vrfAddress,
      }),
    ];
  }
  return [];
};

const makeSetCreatorCalls = async (creatorAddresses) => {
  let calls = [];
  for (const address of creatorAddresses) {
    if (!(await gameContract.get_is_creator(address))) {
      calls.push(
        gameContract.populate("set_is_creator", { user: address, has: true })
      );
    }
  }
  return calls;
};

const makeSetAdminCalls = async (adminAddresses) => {
  let calls = [];
  for (const address of adminAddresses) {
    if (!(await gameContract.get_is_admin(address))) {
      calls.push(
        gameContract.populate("set_is_admin", { user: address, has: true })
      );
    }
  }
  return calls;
};

const calls = (
  await makeSetClassHashCalls([
    [erc721MintableCairoEnum, erc721ClassHash],
    [erc20MintableBurnableCairoEnum, erc20ClassHash],
    [gamePotCairoEnum, gamePotClassHash],
  ])
)
  .concat(await makeSetVRFAddressCall(config.vrf_address))
  .concat(await makeSetCreatorCalls(config.creators))
  .concat(await makeSetAdminCalls(config.admins));
console.log(calls);
if (calls.length) {
  console.log(await executeCalls(provider, account, calls));
}
