// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


interface IYieldSyncV1EMPStrategyInteractor
{
	/**
	* @notice Total amounts locked
	* @param __utilizedERC20 {address}
	*/
	function utilizedERC20TotalAmount(address __utilizedERC20)
		external
		view
		returns (uint256 utilizedERC20Amount_)
	;


	/**
	* @notice Deposit utilizedERC20
	* @param _from {address}
	* @param __utilizedERC20 {address}
	* @param _utilizedERC20Amount {uint256}
	*/
	function utilizedERC20Deposit(address _from, address __utilizedERC20, uint256 _utilizedERC20Amount)
		external
	;

	/**
	* @notice Withdraw utilizedERC20
	* @param _to {address}
	* @param __utilizedERC20 {address}
	* @param _utilizedERC20Amount {uint256}
	*/
	function utilizedERC20Withdraw(address _to, address __utilizedERC20, uint256 _utilizedERC20Amount)
		external
	;
}
