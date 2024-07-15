// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockERC20 is ERC20
{
	constructor (string memory name, string memory symbol)
		ERC20(name, symbol)
	{
		// Sent msg.sender 100m MOCKERC20 tokens
		_mint(msg.sender, 100_000_000_000_000_000_000_000_000);
	}
}
