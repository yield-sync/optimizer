// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IV1EMPStrategyInteractor } from "./interface/IV1EMPStrategyInteractor.sol";


/**
* @notice This contract does not deposit tokens into a protocol
*/
contract SimpleV1EMPStrategyInteractor is
	IV1EMPStrategyInteractor
{
	address public immutable OWNER;


	constructor (address _owner)
	{
		OWNER = _owner;
	}


	function _onlyOwner()
		internal
		view
	{
		require(OWNER == msg.sender, "!(OWNER == msg.sender)");
	}

	modifier onlyOwner()
	{
		_onlyOwner();

		_;
	}


	/// @inheritdoc IV1EMPStrategyInteractor
	function utilizedERC20TotalBalance(address _utilizedERC20)
		public
		view
		override
		returns (uint256 utilizedERC20TotalAmount_)
	{
		return IERC20(_utilizedERC20).balanceOf(address(this));
	}


	/// @inheritdoc IV1EMPStrategyInteractor
	function utilizedERC20Deposit(address _from, address _utilizedERC20, uint256 _utilizedERC20Amount)
		public
		override
		onlyOwner()
	{
		IERC20(_utilizedERC20).transferFrom(_from, address(this), _utilizedERC20Amount);
	}

	/// @inheritdoc IV1EMPStrategyInteractor
	function utilizedERC20Withdraw(address _to, address _utilizedERC20, uint256 _utilizedERC20Amount)
		public
		override
		onlyOwner()
	{
		IERC20(_utilizedERC20).transfer(_to, _utilizedERC20Amount);
	}
}
