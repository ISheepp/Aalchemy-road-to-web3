//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BuyMeACoffee is Ownable {
    // 当留言被创造的时候释放
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );

    error CallFailed(address from);

    // 合约的部署者
    address payable private thisOwner;

    // 留言的结构体
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }

    // 类似数据库一张表，以上几个字段，多个数据
    Memo[] memos;

    // when deployed set owner by contract caller
    constructor() {
        thisOwner = payable(msg.sender);
    }

    /**
     * @dev 给owner捐赠咖啡（发送ETH并留言）
     * @param _message 留言的消息
     * @param _name 捐赠人的名字
     */
    function buyCoffee(string memory _message, string memory _name)
        public
        payable
    {
        // 需要ETH > 0
        require(msg.value > 0, "can't buy coffee for free!");
        memos.push(Memo(msg.sender, block.timestamp, _name, _message));
        emit NewMemo(msg.sender, block.timestamp, _name, _message);
    }

    /**
     * @dev 获取所有的留言
     * @return Memo[]
     */
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
     * @dev 提现，目前只支持提现至owner
     */
    function withdrawTips() public {
        (bool result, ) = thisOwner.call{value: address(this).balance}("");
        if (!result) {
            revert CallFailed(msg.sender);
        }
    }

    function getOwner() public view returns (address) {
        return thisOwner;
    }

    function changeOwner(address payable _addr) public onlyOwner {
        thisOwner = _addr;
        // 修改Ownable.sol的owner
        transferOwnership(_addr);
    }
}
