// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IV1EMP is
	IERC20
{
	/**
	* @dev [view-address]
	* @notice Manager
	* @return {address}
	*/
	function manager()
		external
		view
		returns (address)
	;

	/**
	* @dev [view-boolean]
	* @notice Utilized ERC20 Deposit Open
	* @return {bool}
	*/
	function utilizedERC20DepositOpen()
		external
		view
		returns (bool)
	;

	/**
	* @dev [view-boolean]
	* @notice Utilized ERC20 Withdraw Full
	* @return {bool}
	*/
	function utilizedERC20WithdrawFull()
		external
		view
		returns (bool)
	;

	/**
	* @dev [view-boolean]
	* @notice Utilized ERC20 Withdraw Open
	* @return {bool}
	*/
	function utilizedERC20WithdrawOpen()
		external
		view
		returns (bool)
	;

	/**
	* @notice Fee Rate for Manager
	* @dev [view-uint256]
	* @return {uint256}
	*/
	function feeRateManager()
		external
		view
		returns (uint256)
	;

	/**
	* @notice Fee Rate for Governance
	* @dev [view-uint256]
	* @return {uint256}
	*/
	function feeRateGovernance()
		external
		view
		returns (uint256)
	;

	/**
	* @dev [view-mapping]
	* @notice UtilizedV1EMPStrategy -> Allocation
	* @param _utilizedV1EMPStrategy {address}
	* @return {uin256}
	*/
	function utilizedV1EMPStrategy_allocation(address _utilizedV1EMPStrategy)
		external
		view
		returns (uint256)
	;


	/// @notice view


	/**
	* @notice Utilized ERC20 Total Balance
	*/
	function utilizedERC20TotalBalance()
		external
		view
		returns (uint256[] memory utilizedERC20TotalAmount_)
	;

	/**
	* @dev [view-address[]]
	* @notice Utilized V1 EMP Strategy
	* @return {address[]}
	*/
	function utilizedV1EMPStrategy()
		external
		view
		returns (address[] memory)
	;


	/// @notice mutative


	/**
	* @notice Update Fee Rate for Manager
	* @param _feeRateManager {uint256}
	*/
	function feeRateManagerUpdate(uint256 _feeRateManager)
		external
	;

	/**
	* @notice Update Fee Rate for Governance
	* @param _feeRateGovernance {uint256}
	*/
	function feeRateGovernanceUpdate(uint256 _feeRateGovernance)
		external
	;

	/**
	* @notice Update manager
	* @param _manager {address}
	*/
	function managerUpdate(address _manager)
		external
	;


	/**
	* @notice Utilized ERC20 Deposit
	* @param _utilizedERC20Amount {uint256[]}
	*/
	function utilizedERC20Deposit(uint256[] memory _utilizedERC20Amount)
		external
	;

	/**
	* @notice Utilized ERC20 Deposit Open Update
	* @param _utilizedERC20DepositOpen {bool}
	*/
	function utilizedERC20DepositOpenUpdate(bool _utilizedERC20DepositOpen)
		external
	;

	/**
	* @notice Utilized ERC20 Withdraw
	* @param _eRC20Amount {uint256}
	*/
	function utilizedERC20Withdraw(uint256 _eRC20Amount)
		external
	;

	/**
	* @notice Utilized ERC20 Withdraw Full Update
	* @param _utilizedERC20WithdrawFull {uint256}
	*/
	function utilizedERC20WithdrawFullUpdate(bool _utilizedERC20WithdrawFull)
		external
	;

	/**
	* @notice Utilized ERC20 Withdraw Open Update
	* @param _utilizedERC20WithdrawOpen {bool}
	*/
	function utilizedERC20WithdrawOpenUpdate(bool _utilizedERC20WithdrawOpen)
		external
	;

	/**
	* @notice Deposit utilized ERC20s into strategy
	* @param _v1EMPStrategyUtilizedERC20Amount {uint256[][]}
	*/
	function utilizedV1EMPStrategyDeposit(uint256[][] memory _v1EMPStrategyUtilizedERC20Amount)
		external
	;

	/**
	* @notice Utilized V1EMPStrategy Update
	* @param _v1EMPStrategy {address[]}
	* @param _allocation {uint256[]}
	*/
	function utilizedV1EMPStrategyUpdate(address[] memory _v1EMPStrategy, uint256[] memory _allocation)
		external
	;

	/**
	* @notice Utilized V1 EMP Strategy Sync
	*/
	function utilizedV1EMPStrategySync()
		external
	;


	/**
	* @notice Withdraw utilized ERC20s from strategy
	* @param _v1EMPStrategyERC20Amount {uint256[]}
	*/
	function utilizedV1EMPStrategyWithdraw(uint256[] memory _v1EMPStrategyERC20Amount)
		external
	;
}
