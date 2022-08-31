import { ethers } from "hardhat";

// deploy Buy-me-a-coffee contract on Goerli
const deploy = async () => {
    const contractFactory = await ethers.getContractFactory('BuyMeACoffee');
    const contract = await contractFactory.deploy();
    console.log(`this contract was deployed on ${contract.address}`);
    
}

deploy();