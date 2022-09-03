//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    // 使用库函数
    using Strings for uint256;
    using Counters for Counters.Counter;

    // define tokenId to store NFT ID
    Counters.Counter private _tokenIds;

    // define character
    struct Character {
        uint256 level;
        uint256 hp;
        uint256 strength;
    }
    

    mapping(uint256 => Character) public tokenIdToCharacter;

    // constructor for NFT
    constructor() ERC721("Chain Battle Forever", "CBF") {}

    /**
     * @dev generate and update the SVG image of our NFT
     */
    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "HP: ",
            getHP(tokenId),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            getStrength(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    /**
     * @dev 根据 tokenId 获取角色的等级
     */
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToCharacter[tokenId].level;
        return levels.toString();
    }

    /**
     * @dev 根据 tokenId 获取角色的HP
     */
    function getHP(uint256 tokenId) public view returns (string memory) {
        uint256 hp = tokenIdToCharacter[tokenId].hp;
        return hp.toString();
    }

    /**
     * @dev 根据 tokenId 获取角色的力量
     */
    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToCharacter[tokenId].strength;
        return strength.toString();
    }

    /**
     * @dev 根据 tokenId 获取 tokenUri
     */
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /**
     * @dev mint NFT tokenId 从1开始
     */
    function mint() public {
        // tokenId 从1开始
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        // 初始等级为0, HP 100, strength 15
        tokenIdToCharacter[newItemId].level = 0;
        tokenIdToCharacter[newItemId].hp = 100;
        tokenIdToCharacter[newItemId].strength = 15;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /**
     * @dev 训练角色，提升等级...
     */
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "you must own this token to train it");

        uint256 currentLevel = tokenIdToCharacter[tokenId].level;
        tokenIdToCharacter[tokenId].level = currentLevel + 1;

        uint256 currentHP = tokenIdToCharacter[tokenId].hp;
        tokenIdToCharacter[tokenId].hp = currentHP + 20;

        uint256 currentStrength = tokenIdToCharacter[tokenId].strength;
        tokenIdToCharacter[tokenId].strength = currentStrength + 10;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

}
