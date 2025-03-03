import {
  RpcProvider,
  Account,
  CallData,
  byteArray,
  CairoCustomEnum,
  Contract,
  hash,
} from "starknet";

import * as accounts from "web3-eth-accounts";

import * as fs from "fs";
import * as path from "path";

const loadToml = (rpath) => {
  return toml.parse(fs.readFileSync(rpath));
};

const loadJson = (rpath) => {
  return JSON.parse(fs.readFileSync(path.resolve(__dirname, rpath)));
};

const readKeystorePK = async (keystorePath, accountAddress, password) => {
  let data = loadJson(keystorePath);
  data.address = accountAddress;
  return (await accounts.decrypt(data, password)).privateKey;
};

const getContract = async (provider, contractAddress) => {
  console.log(contractAddress);
  const { abi } = await provider.getClassAt(contractAddress);
  return new Contract(abi, contractAddress, provider);
};

const getAccount = async (rpcUrl, accountAddress, privateKey) => {
  return Account({ nodeUrl: rpcUrl }, accountAddress, privateKey);
};

const declareContract = async (account, contract, casm_path) => {
  const contract = loadJson(files.contract);
  const classHash = hash.computeContractClassHash(contract);
  try {
    await account.getClassByHash(classHash);
    console.log(`Already declared with class Hash ${classHash}`);
  } catch {
    try {
      const casm = loadJson(casm_path);
      const declareResponse = await account.declare(
        { contract, casm },
        { version: 3 }
      );
      await account.waitForTransaction(declareResponse.transaction_hash);
      console.log(`Declared with class Hash ${declareResponse.class_hash}`);
    } catch (err) {
      console.log(`Failed to declare with class hash ${classHash}`);
      console.log(err);
    }
  }

  return classHash;
};

const getContracts = (targetPath) => {
  let contracts = {};
  for (const file of fs.readdirSync(targetPath)) {
    const name = path.basename(file).split(".", 1);

    if (file.endsWith(".contract_class.json")) {
      name in contracts || (contracts[name] = {});
      contracts[name].contract = loadJson(path.join(targetPath, file));
    } else if (file.endsWith(".compiled_contract_class.json")) {
      name in contracts || (contracts[name] = {});
      contracts[name].casm_path = path.join(targetPath, file);
    }
  }
  return contracts;
};


const calculateUDCContractAddressFromHash = (
  salt,
  classHash,
  callData,
  deployerAddress,
  unique
) => {
  if (unique) {
    salt = hash.computePedersenHash(salt, deployerAddress);
    deployerAddress =
      "0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf";
  } else {
    deployerAddress = "0x0";
  }
  return hash.calculateContractAddressFromHash(
    salt,
    classHash,
    callData,
    deployerAddress
  );
};

const deployContract = async (account, classHash, callData, salt, unique) => {
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

const thing = {
  abi: [],
  class_hash: "0x",
  tag: "rising_revenant-game_actions",
};

const deployment = {
  salt: "0x0",
  unique: true,
  contract_address: "0x0",
  class_hash: "0x0",
  constructor_args: ["0x0"],
  deployer_address: "0x0",
  transaction_hash: "0x0",
};

const makeManifest = (contracts, deployments, contracts) => {
  return {
    classes: {},
    deployments: {},
  };
};
