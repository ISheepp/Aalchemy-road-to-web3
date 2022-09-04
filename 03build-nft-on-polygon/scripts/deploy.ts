import { ethers } from "hardhat";

const main = async () => {
    try {
        const contractFactory = await ethers.getContractFactory("ChainBattles");
        const contract = await contractFactory.deploy();
        await contract.deployed();
        console.log(`deploy address on : ${contract.address}`);
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }

};

main();

