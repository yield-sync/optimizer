// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IV1EMP } from "./interface/IV1EMP.sol";
import { IV1EMPUtility, IV1EMPArrayUtility, IV1EMPRegistry, UtilizationERC20 } from "./interface/IV1EMPUtility.sol";
import { IV1EMPETHValueFeed } from "./interface/IV1EMPETHValueFeed.sol";
import { IV1EMPRegistry } from "./interface/IV1EMPRegistry.sol";
import { IV1EMPStrategy } from "./interface/IV1EMPStrategy.sol";


contract V1EMPUtility is
	IV1EMPUtility
{
	using SafeMath for uint256;


	IV1EMPArrayUtility public immutable override I_V1_EMP_ARRAY_UTILITY;
	IV1EMPRegistry public immutable override I_V1_EMP_REGISTRY;


	mapping (
		address v1EMP => mapping(address v1EMPStrategy => uint256 utilizedERC20UpdateTracker)
	) public v1EMP_v1EMPStrategy_utilizedERC20UpdateTracker;


	receive ()
		external
		payable
	{}


	fallback ()
		external
		payable
	{}


	constructor (address _v1EMPRegistry)
	{
		I_V1_EMP_REGISTRY = IV1EMPRegistry(_v1EMPRegistry);
		I_V1_EMP_ARRAY_UTILITY = IV1EMPArrayUtility(I_V1_EMP_REGISTRY.v1EMPArrayUtility());
	}


	modifier authEMP()
	{
		require(I_V1_EMP_REGISTRY.v1EMP_v1EMPId(msg.sender) > 0, "!authorized");

		_;
	}


	/// @notice view


	/// @inheritdoc IV1EMPUtility
	function utilizedERC20TotalBalance()
		public
		view
		authEMP()
		returns (uint256[] memory utilizedERC20TotalAmount_)
	{
		IV1EMP iV1EMP = IV1EMP(msg.sender);

		address[] memory _utilizedERC20 =  iV1EMP.utilizedERC20();
		address[] memory _utilizedV1EMPStrategy =  iV1EMP.utilizedV1EMPStrategy();

		utilizedERC20TotalAmount_ = new uint256[](_utilizedERC20.length);

		for (uint256 i = 0; i < _utilizedERC20.length; i++)
		{
			utilizedERC20TotalAmount_[i] += IERC20(_utilizedERC20[i]).balanceOf(msg.sender);

			for (uint256 ii = 0; ii < _utilizedV1EMPStrategy.length; ii++)
			{
				utilizedERC20TotalAmount_[i] += IV1EMPStrategy(_utilizedV1EMPStrategy[ii]).iV1EMPStrategyInteractor(
				).utilizedERC20TotalBalance(
					_utilizedERC20[i]
				);
			}
		}
	}


	/// @notice mutative


	/// @inheritdoc IV1EMPUtility
	function utilizedERC20AmountValid(uint256[] memory _utilizedERC20Amount)
		public
		view
		override
		authEMP()
		returns (bool valid_, uint256 utilizedERC20AmountTotalETHValue_)
	{
		IV1EMP iV1EMP = IV1EMP(msg.sender);

		address[] memory utilizedERC20 = iV1EMP.utilizedERC20();

		require(_utilizedERC20Amount.length == utilizedERC20.length, "!(_utilizedERC20Amount.length == utilizedERC20.length)");

		valid_ = true;

		utilizedERC20AmountTotalETHValue_ = 0;

		uint256[] memory eRC20AmountETHValue = new uint256[](utilizedERC20.length);

		for (uint256 i = 0; i < utilizedERC20.length; i++)
		{
			uint256 utilizedERC20AmountETHValue = _utilizedERC20Amount[i].mul(
				IV1EMPETHValueFeed(I_V1_EMP_REGISTRY.eRC20_v1EMPERC20ETHValueFeed(utilizedERC20[i])).utilizedERC20ETHValue()
			).div(
				1e18
			);

			utilizedERC20AmountTotalETHValue_ += utilizedERC20AmountETHValue;

			eRC20AmountETHValue[i] = utilizedERC20AmountETHValue;
		}

		for (uint256 i = 0; i < utilizedERC20.length; i++)
		{
			uint256 utilizedERC20AllocationActual = eRC20AmountETHValue[i].mul(1e18).div(
				utilizedERC20AmountTotalETHValue_,
				"!computed"
			);

			if (utilizedERC20AllocationActual != iV1EMP.utilizedERC20_utilizationERC20(utilizedERC20[i]).allocation)
			{
				valid_ = false;

				break;
			}
		}

		return (valid_, utilizedERC20AmountTotalETHValue_);
	}

	/// @inheritdoc IV1EMPUtility
	function v1EMPStrategyUtilizedERC20AmountValid(uint256[][] memory _v1EMPStrategyUtilizedERC20Amount)
		public
		override
		authEMP()
		returns (bool valid_)
	{
		IV1EMP iV1EMP = IV1EMP(msg.sender);

		address[] memory utilizedV1EMPStrategy = iV1EMP.utilizedV1EMPStrategy();

		require(
			utilizedV1EMPStrategy.length == _v1EMPStrategyUtilizedERC20Amount.length,
			"!(utilizedV1EMPStrategy.length == _v1EMPStrategyUtilizedERC20Amount.length)"
		);

		valid_ = true;

		uint256 utilizedV1EMPStrategyERC20AmountETHValueTotal_ = 0;

		uint256[] memory utilizedV1EMPStrategyERC20AmountETHValue = new uint256[](utilizedV1EMPStrategy.length);

		for (uint256 i = 0; i < utilizedV1EMPStrategy.length; i++)
		{
			(uint256 utilizedERC20AmountETHValueTotal_, ) = IV1EMPStrategy(utilizedV1EMPStrategy[i]).utilizedERC20AmountETHValue(
				_v1EMPStrategyUtilizedERC20Amount[i]
			);

			utilizedV1EMPStrategyERC20AmountETHValueTotal_ += utilizedERC20AmountETHValueTotal_;

			utilizedV1EMPStrategyERC20AmountETHValue[i] = utilizedERC20AmountETHValueTotal_;
		}

		for (uint256 i = 0; i < utilizedV1EMPStrategy.length; i++)
		{
			uint256 utilizedERC20AmountAllocationActual = utilizedV1EMPStrategyERC20AmountETHValue[i].mul(1e18).div(
				utilizedV1EMPStrategyERC20AmountETHValueTotal_,
				"!computed"
			);

			if (utilizedERC20AmountAllocationActual != iV1EMP.utilizedV1EMPStrategy_allocation(utilizedV1EMPStrategy[i]))
			{
				valid_ = false;

				break;
			}
		}

		return valid_;
	}

	/// @inheritdoc IV1EMPUtility
	function utilizedERC20Generator()
		public
		override
		authEMP()
		returns (bool updatedRequired_, address[] memory utilizedERC20_, UtilizationERC20[] memory utilizationERC20_)
	{
		updatedRequired_ = false;

		IV1EMP iV1EMP = IV1EMP(msg.sender);

		address[] memory _utilizedV1EMPStrategy =  iV1EMP.utilizedV1EMPStrategy();

		uint256 utilizedERC20MaxLength = 0;

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			uint256 utilizedERC20UpdateTracker = IV1EMPStrategy(_utilizedV1EMPStrategy[i]).utilizedERC20UpdateTracker();

			if (v1EMP_v1EMPStrategy_utilizedERC20UpdateTracker[msg.sender][_utilizedV1EMPStrategy[i]] != utilizedERC20UpdateTracker)
			{
				updatedRequired_ = true;

				v1EMP_v1EMPStrategy_utilizedERC20UpdateTracker[msg.sender][_utilizedV1EMPStrategy[i]] = utilizedERC20UpdateTracker;
			}

			utilizedERC20MaxLength += IV1EMPStrategy(_utilizedV1EMPStrategy[i]).utilizedERC20().length;
		}

		if (!updatedRequired_)
		{
			return (updatedRequired_, utilizedERC20_, utilizationERC20_);
		}

		utilizedERC20_ = new address[](utilizedERC20MaxLength);

		uint256 utilizedERC20I = 0;

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			address[] memory strategyUtilizedERC20 = IV1EMPStrategy(_utilizedV1EMPStrategy[i]).utilizedERC20();

			for (uint256 ii = 0; ii < strategyUtilizedERC20.length; ii++)
			{
				utilizedERC20_[utilizedERC20I++] = strategyUtilizedERC20[ii];
			}
		}

		utilizedERC20_ = I_V1_EMP_ARRAY_UTILITY.removeDuplicates(utilizedERC20_);
		utilizedERC20_ = I_V1_EMP_ARRAY_UTILITY.sort(utilizedERC20_);

		uint256 utilizedERC20AllocationTotal;

		utilizationERC20_ = new UtilizationERC20[](utilizedERC20_.length);

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			IV1EMPStrategy iV1EMPStrategy = IV1EMPStrategy(_utilizedV1EMPStrategy[i]);

			for (uint256 ii = 0; ii < utilizedERC20_.length; ii++)
			{
				UtilizationERC20 memory utilizationERC20 = iV1EMPStrategy.utilizedERC20_utilizationERC20(utilizedERC20_[ii]);

				if (utilizationERC20.deposit)
				{
					utilizationERC20_[ii].deposit = true;

					uint256 utilizationERC20Allocation = utilizationERC20.allocation * iV1EMP.utilizedV1EMPStrategy_allocation(
						_utilizedV1EMPStrategy[i]
					) / 1e18;

					utilizationERC20_[ii].allocation += utilizationERC20Allocation;

					utilizedERC20AllocationTotal += utilizationERC20Allocation;
				}

				if (utilizationERC20.withdraw)
				{
					utilizationERC20_[ii].withdraw = true;
				}
			}
		}

		require(
			utilizedERC20AllocationTotal == iV1EMP.ONE_HUNDRED_PERCENT(),
			"!(utilizedERC20AllocationTotal == iV1EMP.ONE_HUNDRED_PERCENT())"
		);

		return (updatedRequired_, utilizedERC20_, utilizationERC20_);
	}
}
