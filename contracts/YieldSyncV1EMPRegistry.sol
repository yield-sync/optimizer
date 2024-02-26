// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IYieldSyncV1EMPRegistry } from "./interface/IYieldSyncV1EMPRegistry.sol";


contract YieldSyncV1EMPRegistry is
	IYieldSyncV1EMPRegistry
{
	address public manager;
	address public yieldSyncV1EMPDeployer;
	address public yieldSyncV1EMPStrategyDeployer;

	uint256 public yieldSyncEMPIdTracker;
	uint256 public yieldSyncEMPStrategyIdTracker;

	mapping (address yieldSyncV1EMP => uint256 yieldSyncV1EMPId) public override yieldSyncV1EMP_yieldSyncV1EMPId;

	mapping (
		address yieldSyncV1EMPStrategy => uint256 yieldSyncV1EMPStrategyId
	) public override yieldSyncV1EMPStrategy_yieldSyncV1EMPStrategyId;

	mapping (uint256 yieldSyncV1EMPId => address yieldSyncV1EMP) public override yieldSyncV1EMPId_yieldSyncV1EMP;

	mapping (
		uint256 yieldSyncV1EMPStrategyId => address yieldSyncV1EMPStrategy
	) public override yieldSyncV1EMPStrategyId_yieldSyncV1EMPStrategy;


	constructor ()
	{
		yieldSyncEMPIdTracker = 0;
		yieldSyncEMPStrategyIdTracker = 0;

		manager = msg.sender;
	}


	modifier authManager()
	{
		require(manager == msg.sender, "manager != msg.sender");

		_;
	}


	/// @inheritdoc IYieldSyncV1EMPRegistry
	function yieldSyncV1EMPDeployerUpdate(address _yieldSyncV1EMPDeployer)
		public
		override
		authManager()
	{
		require(yieldSyncV1EMPDeployer == address(0), "yieldSyncV1EMPDeployer != address(0)");

		yieldSyncV1EMPDeployer = _yieldSyncV1EMPDeployer;
	}

	/// @inheritdoc IYieldSyncV1EMPRegistry
	function yieldSyncV1EMPRegister(address _yieldSyncV1EMP)
		public
		override
	{
		require(yieldSyncV1EMPDeployer == msg.sender, "yieldSyncV1EMPDeployer != msg.sender");

		yieldSyncEMPIdTracker++;

		yieldSyncV1EMP_yieldSyncV1EMPId[_yieldSyncV1EMP] = yieldSyncEMPIdTracker;
		yieldSyncV1EMPId_yieldSyncV1EMP[yieldSyncEMPIdTracker] = _yieldSyncV1EMP;
	}

	/// @inheritdoc IYieldSyncV1EMPRegistry
	function yieldSyncV1EMPStrategyDeployerUpdate(address _yieldSyncV1EMPStrategyDeployer)
		public
		override
		authManager()
	{
		require(yieldSyncV1EMPStrategyDeployer == address(0), "yieldSyncV1EMPStrategyDeployer != address(0)");

		yieldSyncV1EMPStrategyDeployer = _yieldSyncV1EMPStrategyDeployer;
	}

	/// @inheritdoc IYieldSyncV1EMPRegistry
	function yieldSyncV1EMPStrategyRegister(address _yieldSyncV1EMPStrategy)
		public
		override
	{
		require(yieldSyncV1EMPStrategyDeployer == msg.sender, "yieldSyncV1EMPStrategyDeployer != msg.sender");

		yieldSyncEMPStrategyIdTracker++;

		yieldSyncV1EMPStrategy_yieldSyncV1EMPStrategyId[_yieldSyncV1EMPStrategy] = yieldSyncEMPStrategyIdTracker;
		yieldSyncV1EMPStrategyId_yieldSyncV1EMPStrategy[yieldSyncEMPStrategyIdTracker] = _yieldSyncV1EMPStrategy;
	}
}
