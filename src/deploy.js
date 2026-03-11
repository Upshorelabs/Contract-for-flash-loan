const { ethers } = require("ethers");
const solc = require("solc");

const RPC_URL = "https://bsc-dataseed1.binance.org/";
const PRIVATE_KEY = process.env.PRIVATE_KEY;  // stored in GitHub secrets
const PROFIT_WALLET = "0x7d534271652a400e603727d8c4f5ee0891e8e341";

const source = require("fs").readFileSync("./src/FlashLoanArbitrage.sol", "utf8");

async function main() {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

    console.log("Deploying contract from wallet:", wallet.address);

    const input = {
        language: "Solidity",
        sources: { "FlashLoanArbitrage.sol": { content: source } },
        settings: { outputSelection: { "*": { "*": ["*"] } } }
    };

    const output = JSON.parse(solc.compile(JSON.stringify(input)));
    const contractFile = output.contracts["FlashLoanArbitrage.sol"]["FlashLoanArbitrage"];
    const abi = contractFile.abi;
    const bytecode = contractFile.evm.bytecode.object;

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);

    const contract = await factory.deploy(PROFIT_WALLET);
    await contract.waitForDeployment();

    console.log("✅ Contract deployed successfully!");
    console.log("Contract Address:", await contract.getAddress());
}

main().catch(console.error);
