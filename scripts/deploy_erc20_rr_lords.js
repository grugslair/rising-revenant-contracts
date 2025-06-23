import {
  splitCallDescriptions,
  declareContract,
  loadAccountManifestFromCmdArgs,
  deployContract,
} from "./stark-utils.js";

const erc20RRLordsContractName = "erc20_rr_lords";

const main = async () => {
  const account_manifest = await loadAccountManifestFromCmdArgs();

  const contractPath = `../target/${account_manifest.profile}/rising_revenant_${erc20RRLordsContractName}.contract_class.json`;
  const casmPath = `../target/${account_manifest.profile}/rising_revenant_${erc20RRLordsContractName}.compiled_contract_class.json`;

  const classHash = await declareContract(
    account_manifest.account,
    contractPath,
    casmPath
  );
  console.log(
    `Declared ${erc20RRLordsContractName} with classHash: ${classHash}`
  );
  const { contract_address } = await deployContract(
    account_manifest.account,
    classHash,
    [],
    0,
    false
  );
  console.log(
    `Deployed ${erc20RRLordsContractName} at address: ${contract_address}`
  );
  account_manifest;
};

if (process.argv[1] === import.meta.filename) {
  await main();
}
