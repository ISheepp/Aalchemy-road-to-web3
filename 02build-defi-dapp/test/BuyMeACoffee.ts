import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BuyMeACoffee } from "../typechain-types";
import { Signer } from "ethers";

describe("测试BuyMeACoffee合约", () => {

    const CONTRACT_NAME = "BuyMeACoffee";

    // deploy contract (loadFixture)
    const deploy = async () => {
        const contractFactory = await ethers.getContractFactory(CONTRACT_NAME);
        // 合约构造函数没有参数
        const contract = await contractFactory.deploy();
        // 创建3个accounts
        const [owner, other1, other2] = await ethers.getSigners();
        console.log(`deploy finished on address: ${contract.address}`);
        console.log(`合约部署账号：${owner.address}`);
        console.log(`测试账号1：${other1.address}`);
        console.log(`测试账号2：${other2.address}`);
        return { contract, owner, other1, other2 };
    }

    // test deploy and owner
    it("测试部署之后的账号是否等于owner", async () => {
        const { contract, owner } = await loadFixture(deploy);
        expect(await contract.getOwner()).to.equal(owner.address);
    })

    it("测试捐赠咖啡方法", async () => {
        const { contract, owner, other1, other2 } = await loadFixture(deploy);
        // other1 捐赠
        const receipt = await buyCoffeeWithWallet(contract, other1);
        // console.log(result);

        const contractBalance = await ethers.provider.getBalance(contract.address);
        // 测试合约的balance是否一致
        expect('0.01').to.equal(ethers.utils.formatEther(contractBalance));
        // 测试event 使用原始ethers测试

        // const receipt = await ethers.provider.getTransactionReceipt(result.hash);
        // const interface1 = new ethers.utils.Interface(["event NewMemo(address indexed from,uint256 timestamp,string name,string message);"]);
        // const data = receipt.logs[0].data;
        // const topics = receipt.logs[0].topics;
        // console.log(receipt.logs);
        // const event = interface1.decodeEventLog("NewMemo", data, topics);
        // console.log(event);
        // expect(event.from).to.equal();
        // expect(event.to).to.equal(<addr-of - receipent >);
        // expect(event.amount.toString()).to.equal(<amount-BigNumber >.toString());

        // 使用chai-matcher测试event
        await expect(receipt).to.emit(contract, "NewMemo")
            .withArgs(other1.address, anyValue, "ISheep", "hi i love you");


    })

    it("测试获取所有Memo", async () => {
        const { contract, owner, other1, other2 } = await loadFixture(deploy);
        const receipt = await buyCoffeeWithWallet(contract, other1);
        const receipt1 = await buyCoffeeWithWallet(contract, other2);
        
        await receipt.wait();
        
        let memos: Array<BuyMeACoffee.MemoStructOutput>  = await contract.getMemos();
        memos.forEach((memo)=>{
            console.log(memo);            
        })
    })



})

// 购买咖啡
async function buyCoffeeWithWallet(contract: BuyMeACoffee, address: Signer) {
    const option = {
        value: ethers.utils.parseEther("0.01")
    };
    const receipt = await contract.connect(address).buyCoffee("hi i love you", "ISheep", option);
    return receipt;
}
