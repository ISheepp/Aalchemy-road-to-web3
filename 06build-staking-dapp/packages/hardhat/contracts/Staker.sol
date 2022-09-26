// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamps;

    // 每秒钟的利息
    uint256 public constant rewardRatePerSecond = 0.1 ether;
    // 定义了质押的开始和结束时间
    uint256 public withdrawalDeadline = block.timestamp + 120 seconds;
    uint256 public claimDeadline = block.timestamp + 240 seconds;
    // 初始区块
    uint256 public currentBlock = 0;

    event Stake(address indexed sender, uint256 amount);
    event Reveived(address, uint256);
    event Execute(address indexed sender, uint256 amount);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier withdrawalDeadlineReached(bool requireReached) {
        uint256 timeRemaining = withdrawalTimeLeft();
        if (requireReached) {
            require(timeRemaining == 0, "withdrawal period is not reached yet");
        } else {
            require(timeRemaining > 0, "withdrawal period has been reached");
        }
        _;
    }

    modifier claimDeadlineReached(bool requireReached) {
        uint256 timeRemaining = claimPeriodLeft();
        if (requireReached) {
            require(timeRemaining == 0, "Claim deadline is not reached yet");
        } else {
            require(timeRemaining > 0, "Claim deadline has been reached");
        }
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Stake already completed!");
        _;
    }

    /**
     * @dev 返回取款剩余的时间
     */
    function withdrawalTimeLeft() public view returns (uint256) {
        if (block.timestamp >= withdrawalDeadline) {
            return (0);
        } else {
            return (withdrawalDeadline - block.timestamp);
        }
    }

    /**
     * @dev 返回索取剩余时间
     */
    function claimPeriodLeft() public view returns (uint256) {
        if (block.timestamp >= claimDeadline) {
            return (0);
        } else {
            return (claimDeadline - block.timestamp);
        }
    }

    /**
     * @dev 质押函数 只能质押ETH
     */
    function stake()
        public
        payable
        withdrawalDeadlineReached(false)
        claimDeadlineReached(false)
    {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
        emit Stake(msg.sender, msg.value);
    }

    /**
     * @dev 取款
     */
    function withdraw()
        public
        withdrawalDeadlineReached(true)
        claimDeadlineReached(false)
        notCompleted
    {
        require(balances[msg.sender] > 0, "You have no balances to withdraw!");
        uint individualBalance = balances[msg.sender];
        // 最终withdraw的数量
        uint individualRewards = individualBalance + ((block.timestamp - depositTimestamps[msg.sender]) * rewardRatePerSecond);
        balances[msg.sender] = 0;

        // Transfer ETH
        (bool result, ) = msg.sender.call{value:individualRewards}("");
        require(result, "withdraw failed :( ");
    }

    function execute() public claimDeadlineReached(true) notCompleted {
        uint contractBalance = address(this).balance;
        exampleExternalContract.complete{value: address(this).balance}();
    }

    function killTime() public {
        currentBlock = block.timestamp;
    }

    receive() external payable {
        emit Reveived(msg.sender, msg.value);
    }
}
