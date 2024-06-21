// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    event TokenRedeemed(address indexed user, uint256 itemNumber, uint256 tokensSpent); 
    event TokenMinted(address indexed account, uint256 amount); 
    event TokenBurned(address indexed account, uint256 amount); 

    mapping(address => uint256) private _redemptionCount;
    mapping(address => mapping(uint256 => bool)) private _itemRedeemed;

    constructor() ERC20("DegenToken", "DGN") {}

    function mintTokens(address account, uint256 amount) external onlyOwner {
        _mint(account, amount); 
        emit TokenMinted(account, amount); 
    }

    function transferDegenTokens(address recipient, uint256 amount) external {
        _transfer(_msgSender(), recipient, amount); 
    }

    function redeemToken(uint256 itemNumber) external {
        uint256 requiredTokens = getRedemptionCost(itemNumber); 
        require(balanceOf(_msgSender()) >= requiredTokens, "Not enough tokens"); 
        require(!isItemRedeemed(itemNumber), "Item already redeemed");

        _burn(_msgSender(), requiredTokens); 
        _redemptionCount[_msgSender()] += 1; 
        _itemRedeemed[_msgSender()][itemNumber] = true;

        emit TokenRedeemed(_msgSender(), itemNumber, requiredTokens); 
    }

    function burnDegenTokens(uint256 amount) external {
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance to burn"); 
        _burn(_msgSender(), amount); 
        emit TokenBurned(_msgSender(), amount); 
    }

    function balanceOfUser() external view returns (uint256) {
        return balanceOf(_msgSender()); 
    }

    function redemptionCount(address account) external view returns (uint256) {
        return _redemptionCount[account]; 
    }

    function getRedemptionCost(uint256 itemNumber) public pure returns (uint256) {
        if (itemNumber == 1) {
            return 100; //Cost for  Sword
        } else if (itemNumber == 2) {
            return 500; // Cost for Shield
        } else if (itemNumber == 3) {
            return 700; // Cost for improving Health
        } else if (itemNumber == 4) {
            return 800; // Cost for a smoke bomb
        } else {
            revert("Invalid item number"); 
        }
    }

    function isItemRedeemed(uint256 itemNumber) public view returns (bool) {
        return _itemRedeemed[_msgSender()][itemNumber];
    }
}
