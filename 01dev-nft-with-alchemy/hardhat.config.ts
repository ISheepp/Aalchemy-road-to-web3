import { task } from "hardhat/config";

import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
dotenvConfig({ path: resolve(__dirname, "./.env") });

import { HardhatUserConfig } from "hardhat/types";
import { NetworkUserConfig } from "hardhat/types";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
	solidity: "0.8.9",
	gasReporter: {
		currency: 'USD',
		gasPrice: 50,
		enabled: !!process.env.REPORT_GAS,
		coinmarketcap: process.env.COINMARKETCAP_API_KEY,
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
