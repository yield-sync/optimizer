const { ethers } = require("hardhat");


export const D_18 = ethers.utils.parseUnits('1', 18);

export const ERROR = {
	REGISTRY: {
		ARRAY_UTILITY_NOT_SET:
			"!(_v1EMPArrayUtility != address(0))"
		,
		ARRAY_UTILITY_IS_ADDRESS_ZERO:
			"!(__v1EMPArrayUtility != address(0))"
		,
		EMP_UTILITY_NOT_SET:
			"!(_v1EMPUtility != address(0))"
		,
		NOT_EMP_DEPLOYER:
			"!(_v1EMPDeployer == msg.sender)"
		,
		NOT_STRATEGY_DEPLOYER:
			"!(_v1EMPStrategyDeployer == msg.sender)"
		,
		EMP_STRATEGY_DEPLOYER_IS_ADDRESS_ZERO:
			"!(__v1EMPStrategyDeployer != address(0))"
		,
		EMP_DEPLOYER_IS_ADDRESS_ZERO:
			"!(__v1EMPDeployer != address(0))"
		,
		EMP_UTILITY_IS_ADDRESS_ZERO:
			"!(__v1EMPUtility != address(0))"
		,
		ERC20_ADDRESS_ZERO:
			"!(_eRC20 != address(0))"
		,
		ETH_VALUE_FEED_ADDRESS_ZERO:
			"!(_v1EMPERC20ETHValueFeed != address(0))"
		,
		STRATEGY_UTILITY_IS_ADDRESS_ZERO:
			"!(__v1EMPStrategyUtility != address(0))"
		,
	},
	EMP: {
		DEPOSIT_NOT_OPEN:
			"!utilizedERC20DepositOpen"
		,
		FEE_RATE_GOVERNANCE_GREATER_THAN_100_PERCENT:
			"!(_feeRateGovernance)"
		,
		FEE_RATE_MANAGER_GREATER_THAN_100_PERCENT:
			"!(_feeRateManager)"
		,
		INVALID_BALANCE:
			"!(balanceOf(msg.sender) >= _eRC20Amount)"
		,
		INVALID_UTILIZED_ERC20_AMOUNT_LENGTH:
			"!(utilizedV1EMPStrategy.length == _v1EMPStrategyUtilizedERC20Amount.length)"
		,
		INVALID_UTILIZED_STRATEGY_ALLOCAITON:
			"!(utilizedERC20AmountAllocationActual == iV1EMP.utilizedV1EMPStrategy_allocation(utilizedV1EMPStrategy[i]))"
		,
		INVALID_STRATEGY_ERC20_AMOUNTS_LENGTH:
			"!(_v1EMPStrategyERC20Amount.length == _utilizedV1EMPStrategy.length)"
		,
		INVALID_UTILIZED_ERC20_LENGTH:
			"!(_utilizedERC20Amount.length == utilizedERC20.length)"
		,
		WITHDRAW_NOT_OPEN:
			"!utilizedERC20WithdrawOpen"
		,
		UTILIZED_ERC20_NOT_AVAILABLE:
			"!(utilizedERC20Available)"
		,
		ADDRESS_NOT_EMP:
			"!(_I_V1_EMP_REGISTRY.v1EMP_v1EMPId(_v1EMP) > 0)"
		,
	},
	EMP_UTILITY:
	{
		INVALID_ALLOCATION:
		"!(_v1EMP_utilizedERC20_utilizationERC20[_v1EMP][utilizedERC20[i]].allocation == utilizedERC20AllocationActual)"
		,
		UTILIZED_V1_EMP_STRATEGY_INVALID_ALLOCATION:
			"!(utilizedV1EMPStrategyAllocationTotal == _I_V1_EMP_REGISTRY.ONE_HUNDRED_PERCENT())"
		,
		INVALID_V1_EMP_STRATEGY:
			"!(_I_V1_EMP_REGISTRY.v1EMPStrategy_v1EMPStrategyId(_v1EMPStrategy[i]) > 0)"
		,
	},
	STRATEGY: {
		DEPOSIT_NOT_OPEN:
			"!utilizedERC20DepositOpen"
		,
		INTERACTOR_NOT_SET:
			"!(address(iV1EMPStrategyInteractor) != address(0))"
		,
		INVALID_BALANCE:
			"!(eMP_shares[msg.sender] >= _shares)"
		,
		INVALID_ERC20_ALLOCATION_TOTAL:
			"!(utilizedERC20AllocationTotal == _I_V1_EMP_REGISTRY.ONE_HUNDRED_PERCENT())"
		,
		INVALID_UTILIZED_ERC20:
			"!(_utilizedERC20[i] != address(0))"
		,
		INVALID_UTILIZED_ERC20_AMOUNT:
			"!(iV1EMPStrategy.utilizedERC20_utilizationERC20(utilizedERC20[i]).allocation == utilizedERC20AmountAllocationActual)"
		,
		INVAILD_PARAMS_DEPOSIT_LENGTH:
			"!(utilizedERC20.length == _utilizedERC20Amount.length)"
		,
		INVALID_PARAMS_UPDATE_LENGTHS:
			"!(_utilizedERC20.length == _utilizationERC20.length)"
		,
		INVALID_PARAMS_UPDATE_CONTAINS_DUPLCIATES:
			"IV1EMPArrayUtility(_I_V1_EMP_REGISTRY.v1EMPArrayUtility()).containsDuplicates(_utilizedERC20)"
		,
		INVALID_STRATEGY_INTERACTOR:
			"!_iStrategyInteractor"
		,
		UTILIZED_ERC20_AMOUNT_NOT_ZERO:
			"!(_utilizedERC20Amount[i] == 0)"
		,
		UTILIZED_ERC20_TRANSFERS_OPEN:
			"!(!utilizedERC20DepositOpen && !utilizedERC20WithdrawOpen)"
		,
		WITHDRAW_NOT_OPEN:
			"!utilizedERC20WithdrawOpen"
		,
		ERC20_NO_ETH_VALUE_FEED_AVAILABLE:
			"!(_I_V1_EMP_REGISTRY.eRC20_v1EMPERC20ETHValueFeed(_utilizedERC20[i]) != address(0))"
		,
	},
	STRATEGY_UTILITY: {
		ADDRESS_NOT_STRATEGY:
			"!(_I_V1_EMP_REGISTRY.v1EMPStrategy_v1EMPStrategyId(_v1EMPStrategy) > 0)"
		,
	},
	NOT_COMPUTED:
		"!computed"
	,
	NOT_AUTHORIZED:
		"!authorized"
	,
}

export const PERCENT = {
	HUNDRED: ethers.utils.parseUnits('1', 18),
	FIFTY: ethers.utils.parseUnits('.5', 18),
	FORTY: ethers.utils.parseUnits('.4', 18),
	TEN: ethers.utils.parseUnits('.1', 18),
	TWENTY_FIVE: ethers.utils.parseUnits('.25', 18),
	SEVENTY_FIVE: ethers.utils.parseUnits('.75', 18),
	ZERO: ethers.utils.parseUnits('0', 18),
}
