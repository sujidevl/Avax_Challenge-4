# Avax_Challenge-4

## Degen Token Contract

This Solidity contract is a custom implementation that extends the ERC20 token standard from OpenZeppelin. It provides functionalities such as minting, burning, transferring tokens, and redeeming specific items based on predefined token values. The contract also maintains a log of redeemed items for each user.

## Functionality Overview

1. `mint`: Only the contract owner can mint new tokens to a specified account.
2. `Burn`: Allows users to burn a specified amount of tokens from their own balance, with an accompanying event emission. It checks for sufficient funds before burning.
3. `transferTokens`: Enables users to transfer tokens to a specified recipient after proper approval and validation of available funds.
4. `redeem`: Allows users to redeem specific items based on predefined token values. It deducts the appropriate token amount from the user's balance and increments the count of redeemed items.
5. `balance`: Returns the balance of tokens for the caller.
6. `redeemedItemsCount`: Returns the count of redeemed items for a specified account.
7. `isItemRedeemed` : Checks whether the player redeemed item or not

## Prerequisites

The contract utilizes OpenZeppelin libraries, particularly version 4.9.0. Ensure that these libraries are properly installed.

## Usage

Deploy the contract using Avalanche Fuji Testnet Network, ensuring the Solidity version is 0.8.18 or higher. The contract supports functionalities for minting, burning, and transferring tokens, as well as the redemption of specific items based on predefined token values.

```javascript
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


```

## Author : Sujatha

