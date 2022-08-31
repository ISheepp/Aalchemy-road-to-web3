import { task } from "hardhat/config";

import "dotenv/config";
import { HardhatUserConfig } from "hardhat/types";
import { NetworkUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";

// task
import './tasks/utils/accounts';

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = <string>process.env.PRIVATE_KEY;
const ENABLED = process.env.REPORT_GAS;
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY

const config: HardhatUserConfig = {
	solidity: {
		version: "0.8.9",
		settings: {
			optimizer: {
				enabled: true,
				runs: 50,
			},
		}
	},
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



export default config;
