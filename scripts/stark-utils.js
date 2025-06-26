import {
  Contract,
  CairoCustomEnum,
  CallData,
  Account,
  cairo,
  RPC,
  stark,
  ec,
  hash,
  byteArray,
  events as cairoEvents,
} from "starknet";
import { fileURLToPath } from "url";
import { dirname } from "path";
import commandLineArgs from "command-line-args";
import * as fs from "fs";
import * as path from "path";
import * as accounts from "web3-eth-accounts";
import * as toml from "toml";
import { version } from "os";

const __filename = fileURLToPath(import.meta.url);
const __dirname = process.cwd();
const returnKey =
  "0x17c9a55536e844e86b35cd70d23a4e304a30e5e08de591b6788319186160f50";

export const isDict = (obj) => {
  return typeof obj === "object" && !Array.isArray(obj) && obj !== null;
};

export const loadJson = (path) => {
  return JSON.parse(fs.readFileSync(resolvePath(path)));
};

export const loadToml = (path) => {
  return toml.parse(fs.readFileSync(resolvePath(path)));
};

export const resolvePath = (rpath) => {
  return path.resolve(__dirname, rpath);
};

export const getContractAddress = (mainfest, contractName) => {
  return getContractFromManifest(mainfest, contractName)?.address;
};

export const getContractFromManifest = (manifest, contractName) => {
  for (const contract of manifest.contracts) {
    if (contract.tag === contractName) {
      return contract;
    }
  }
  return null;
};

export const readKeystorePK = async (
  keystorePath,
  accountAddress,
  password
) => {
  let data = loadJson(keystorePath);
  data.address = accountAddress;
  return (await accounts.decrypt(data, password)).privateKey;
};

export const getContract = async (provider, contractAddress) => {
  const { abi: abi } = await provider.getClassAt(contractAddress);
  return new Contract(abi, contractAddress, provider);
};

export const makeCairoEnum = (option) => {
  let [key, value] = parseEnumObject(option);
  return new CairoCustomEnum({ [key]: value });
};

export const parseEnumObject = (obj) => {
  if (["string"].includes(typeof obj)) {
    return [obj, {}];
  } else {
    for (const o in obj) {
      return [o, obj[o]];
    }
  }
};

export const makeCall = (contract, entrypoint, calldata) => {
  return contract.populate(entrypoint, calldata);
};

export class AccountManifest {
  constructor(dojo_toml_path, manifest_path, profile, privateKey = null) {
    this.dojo_toml = loadToml(dojo_toml_path);
    this.manifest = loadJson(manifest_path);
    this.rpc_url = this.dojo_toml.env.rpc_url;
    this.profile = profile;
    privateKey = privateKey || this.dojo_toml.env.private_key;
    if (privateKey) {
      this.account = new Account(
        { nodeUrl: this.rpc_url },
        this.dojo_toml.env.account_address,
        privateKey
      );
    }
    this.contracts = {};
  }

  async init_keystore(password) {
    const privateKey = await readKeystorePK(
      await resolvePath(this.dojo_toml.env.keystore_path),
      this.dojo_toml.env.account_address,
      password
    );
    this.account = new Account(
      { nodeUrl: this.dojo_toml.env.rpc_url },
      this.dojo_toml.env.account_address,
      privateKey
    );
  }

  getContract(tag) {
    if (this.contracts[tag]) {
      return this.contracts[tag];
    } else {
      const data = getContractFromManifest(this.manifest, tag);
      if (data) {
        this.contracts[tag] = new Contract(
          data.abi,
          data.address,
          this.account
        );
        return this.contracts[tag];
      } else {
        throw new Error(`Contract ${tag} not found in manifest`);
      }
    }
  }
  getContractAddress(tag) {
    return getContractAddress(this.manifest, tag);
  }

  async execute(calls) {
    const { transaction_hash } = await this.account.execute(calls, {
      version: 3,
    });
    await this.account.waitForTransaction(transaction_hash, {
      retryInterval: 100,
      successStates: [
        RPC.ETransactionStatus.RECEIVED,
        RPC.ETransactionExecutionStatus.SUCCEEDED,
        RPC.ETransactionStatus.ACCEPTED_ON_L2,
        RPC.ETransactionStatus.ACCEPTED_ON_L1,
      ],
    });
    return transaction_hash;
  }
  getWorldContract() {
    return new Contract(
      this.manifest.world.abi,
      this.manifest.world.address,
      this.account
    );
  }
}

export const batchCalls = (calls, batchSize) => {
  const chunks = [];
  for (let i = 0; i < calls.length; i += batchSize) {
    chunks.push(calls.slice(i, i + batchSize));
  }
  return chunks;
};

export const splitCallDescriptions = (calls_metas) => {
  const descriptions = [];
  const calls = [];
  for (const [call, meta] of calls_metas) {
    descriptions.push(meta.description);
    calls.push(call);
  }
  return [calls, descriptions];
};

export const loadAccountManifest = async (
  profile,
  password = null,
  privateKey = null
) => {
  const account_manifest = new AccountManifest(
    `./dojo_${profile}.toml`,
    `./manifest_${profile}.json`,
    profile,
    privateKey
  );
  if (password && !privateKey) {
    await account_manifest.init_keystore(password);
  } else if (account_manifest.dojo_toml.env.keystore_path && !privateKey) {
    throw new Error(
      `Keystore path is set, but no password provided. Please provide a password.`
    );
  }
  return account_manifest;
};

export const deployContract = async (
  account,
  classHash,
  callData,
  salt,
  unique
) => {
  const deployResponse = await account.deployContract(
    { classHash, salt, unique, constructorCalldata: callData },
    { version: 3 }
  );
  await account.waitForTransaction(deployResponse.transaction_hash);
  console.log(
    `Deployed contract with class Hash: ${classHash} and address: ${deployResponse.contract_address}`
  );
  return {
    salt,
    unique,
    contract_address: deployResponse.contract_address,
    class_hash: classHash,
    constructor_calldata: callData,
    deployer_address: account.address,
    transaction_hash: deployResponse.transaction_hash,
  };
};

export const declareContract = async (account, contractPath, CasmPath) => {
  const contract = loadJson(contractPath);

  const classHash = hash.computeContractClassHash(contract);
  try {
    await account.getClassByHash(classHash);
    console.log(`Already declared with classHash\n\t\t${classHash}`);
  } catch {
    const casm = loadJson(CasmPath);
    const declareResponse = await account.declare({
      contract,
      casm,
      version: 3,
    });
    await account.waitForTransaction(declareResponse.transaction_hash);
    console.log(`Declared with classHash\n\t\t${declareResponse.class_hash}`);
  }
  return classHash;
};

export const loadAccountManifestFromCmdArgs = async () => {
  const optionDefinitions = [
    { name: "profile", type: String, defaultOption: true, defaultValue: "dev" },
    { name: "password", alias: "p", type: String, defaultValue: null },
  ];
  const options = commandLineArgs(optionDefinitions);
  return await loadAccountManifest(options.profile, options.password);
};

export const getReturns = async (rpc, txHash) => {
  let receipt;
  try {
    receipt = await rpc.getTransactionReceipt(txHash);
  } catch (e) {
    await rpc.waitForTransaction(txHash);
    receipt = await rpc.getTransactionReceipt(txHash);
  }

  let events = [];

  for (const event of receipt.events) {
    if (event.keys.length && event.keys[0] === returnKey) {
      events.push(event);
    }
  }
  return events;
};
export const getReturn = async (rpc, txHash) => {
  return (await getReturns(rpc, txHash))[0].data;
};
export const dataToUint256 = (data) => {
  return cairo.uint256(data[1] + data[0].substring(2).padStart(32, "0"));
};

export const uint256ToHex = (value) => {
  const low = BigInt(value.low).toString(16).padStart(32, "0");
  const high = BigInt(value.high).toString(16).padStart(32, "0");
  return "0x" + high + low;
};

export const newKeyPair = () => {
  const privateKey = stark.randomAddress();
  const publicKey = ec.starkCurve.getStarkKey(privateKey);
  return {
    privateKey,
    publicKey,
  };
};

export const newAccount = async (account, classHash) => {
  const { privateKey, publicKey } = newKeyPair();
  const { transaction_hash, contract_address } = await account.deploy(
    {
      classHash,
      salt: publicKey,
      unique: false,
      constructorCalldata: CallData.compile({ public_key: publicKey }),
    },
    {
      version: 3,
    }
  );
  return new Account(
    { nodeUrl: account.channel.nodeUrl },
    contract_address[0],
    privateKey
  );
};

export const newAccounts = async (account, classHash, amount) => {
  let calls = [];
  let keys = [];
  for (let i = 0; i < amount; i++) {
    const { privateKey, publicKey } = newKeyPair();
    calls.push({
      classHash,
      salt: publicKey,
      unique: false,
      constructorCalldata: CallData.compile({ public_key: publicKey }),
    });
    keys.push({ privateKey, publicKey });
  }

  const { transaction_hash, contract_address } = await account.deploy(calls, {
    version: 3,
  });
  return contract_address.map((address, i) => {
    return new Account(
      { nodeUrl: account.channel.nodeUrl },
      address,
      keys[i].privateKey
    );
  });
};

export const callOptions = (caller) => {
  const now_seconds = Math.floor(Date.now() / 1000);
  return {
    caller,
    execute_after: now_seconds - 3600,
    execute_before: now_seconds + 3600,
  };
};

export const stringToByteArrayCompiled = (string) => {
  return CallData.toHex([byteArray.byteArrayFromString(string)]);
};

export const poseidonHashString = (string) => {
  return hash.computePoseidonHashOnElements(stringToByteArrayCompiled(string));
};

export const dataToByteArray = (data) => {
  const [pending_word, pending_word_len] = data.splice(-2);
  return { data, pending_word, pending_word_len };
};

export const byteDataToString = (data) => {
  return byteArray.stringFromByteArray(dataToByteArray(data));
};

export const getAllEvents = async (accountOrProvider, eventFilter) => {
  let allEvents = [];
  let { events, continuation_token } = await accountOrProvider.getEvents(
    eventFilter
  );
  allEvents.push(...events);
  while (parseInt(continuation_token.split(",").at(-1), 16)) {
    ({ events, continuation_token } = await accountOrProvider.getEvents({
      ...eventFilter,
      continuation_token,
    }));
    allEvents.push(...events);
  }
  return allEvents;
};

const isTopLevelEvent = (item) => {
  return (
    item.type === "event" &&
    item.name.endsWith("::Event") &&
    item.kind === "enum"
  );
};

export const parseAbisTypes = (abis) => {
  abis = Array.isArray(abis) ? abis : [abis];
  let variants = {};
  let abiTypes = {};
  for (let abi of abis) {
    if (isDict(abi) && "abi" in abi) {
      abi = abi.abi;
    }
    for (const item of abi) {
      if (["event", "struct", "enum"].includes(item.type)) {
        if (isTopLevelEvent(item)) {
          for (const variant of item.variants) {
            variants[variant.type] = variant;
          }
        } else {
          abiTypes[item.name] = item;
        }
      }
    }
  }
  abiTypes.Event = {
    type: "event",
    name: "Event",
    kind: "enum",
    variants: Object.values(variants),
  };
  return abiTypes;
};

export class Abi {
  constructor(abis) {
    this.abiTypes = parseAbisTypes(abis);
    const abiAsArray = Object.values(this.abiTypes);
    this.abiEvents = cairoEvents.getAbiEvents(abiAsArray);
    this.abiStructs = CallData.getAbiStruct(abiAsArray);
    this.abiEnums = CallData.getAbiEnum(abiAsArray);
  }

  parseType(typeName, rawData) {
    const rawIter = rawData[Symbol.iterator]();
    responseParser();
  }
}
