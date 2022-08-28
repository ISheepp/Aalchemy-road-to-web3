import { task } from "hardhat/config";

import "dotenv/config";
import { HardhatUserConfig } from "hardhat/types";
import { NetworkUserConfig } from "hardhat/types";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = <string>process.env.PRIVATE_KEY;
const ENABLED = process.env.REPORT_GAS;
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY

const config: HardhatUserConfig = {
	solidity: "0.8.9",
	networks: {
		goerli: {
			url: GOERLI_URL,
			accounts: [PRIVATE_KEY]
		}
	},
	gasReporter: {
		currency: 'USD',
		gasPrice: 50,
		enabled: false,
		coinmarketcap: COINMARKETCAP_API_KEY,
		maxMethodDiff: 10,
	},

};

task("accounts", "Prints the list of accounts", async (args, hre) => {
	const accounts = await hre.ethers.getSigners();
	for (const account of accounts) {
		console.log(await account.getAddress());
	}
});


export default config;
