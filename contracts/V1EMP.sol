// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IAccessControlEnumerable } from "@openzeppelin/contracts/access/IAccessControlEnumerable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { IERC20, IV1EMP, IV1EMPRegistry, IV1EMPUtility } from "./interface/IV1EMP.sol";
import { IV1EMPStrategy } from "./interface/IV1EMPStrategy.sol";


contract V1EMP is
	ReentrancyGuard,
	ERC20,
	IV1EMP
{
	address public override manager;

	address[] internal _utilizedV1EMPStrategy;

	bool public override utilizedERC20DepositOpen;
	bool public override utilizedERC20WithdrawFull;
	bool public override utilizedERC20WithdrawOpen;

	uint256 public constant override ONE_HUNDRED_PERCENT = 1e18;

	uint256 public override feeRateGovernance;
	uint256 public override feeRateManager;

	IV1EMPRegistry public immutable override I_V1_EMP_REGISTRY;
	IV1EMPUtility public immutable override I_V1_EMP_UTILITY;

	mapping (address utilizedV1EMPStrategy => uint256 allocation) public override utilizedV1EMPStrategy_allocation;


	receive ()
		external
		payable
	{}


	fallback ()
		external
		payable
	{}


	constructor (
		address _manager,
		address _v1EMPRegistry,
		bool _utilizedERC20WithdrawFull,
		string memory _name,
		string memory _symbol
	)
		ERC20(_name, _symbol)
	{
		manager = _manager;
		utilizedERC20WithdrawFull = _utilizedERC20WithdrawFull;

		I_V1_EMP_REGISTRY = IV1EMPRegistry(_v1EMPRegistry);
		I_V1_EMP_UTILITY = IV1EMPUtility(I_V1_EMP_REGISTRY.v1EMPUtility());
	}


	modifier authGovernanceOrManager()
	{
		require(
			msg.sender == manager || IAccessControlEnumerable(I_V1_EMP_REGISTRY.GOVERNANCE()).hasRole(bytes32(0), msg.sender),
			"!authorized"
		);

		_;
	}

	modifier utilizedERC20DepositOpenRequired()
	{
		require(utilizedERC20DepositOpen, "!utilizedERC20DepositOpen");

		_;
	}


	/// @notice view


	/// @inheritdoc IV1EMP
	function utilizedV1EMPStrategy()
		public
		view
		override
		returns (address[] memory)
	{
		return _utilizedV1EMPStrategy;
	}


	/// @notice mutative


	/// @inheritdoc IV1EMP
	function feeRateManagerUpdate(uint256 _feeRateManager)
		public
		authGovernanceOrManager()
	{
		require(_feeRateManager <= ONE_HUNDRED_PERCENT, "!(_feeRateManager <= ONE_HUNDRED_PERCENT)");

		feeRateManager = _feeRateManager;
	}

	/// @inheritdoc IV1EMP
	function feeRateGovernanceUpdate(uint256 _feeRateGovernance)
		public
		override
	{
		require(IAccessControlEnumerable(I_V1_EMP_REGISTRY.GOVERNANCE()).hasRole(bytes32(0), msg.sender), "!authorized");

		require(_feeRateGovernance <= ONE_HUNDRED_PERCENT, "!(_feeRateGovernance <= ONE_HUNDRED_PERCENT)");

		feeRateGovernance = _feeRateGovernance;
	}

	/// @inheritdoc IV1EMP
	function managerUpdate(address _manager)
		public
		override
		authGovernanceOrManager()
	{
		manager = _manager;
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20Deposit(uint256[] memory _utilizedERC20Amount)
		public
		override
		nonReentrant()
		utilizedERC20DepositOpenRequired()
	{
		utilizedERC20Update();

		(bool valid, uint256 utilizedERC20AmountTotalETHValue) = I_V1_EMP_UTILITY.utilizedERC20AmountValid(
			address(this),
			_utilizedERC20Amount
		);

		require(valid, "!valid");

		address[] memory _utilizedERC20 = I_V1_EMP_UTILITY.v1EMP_utilizedERC20(address(this));

		for (uint256 i = 0; i < _utilizedERC20.length; i++)
		{
			IERC20(_utilizedERC20[i]).transferFrom(msg.sender, address(this), _utilizedERC20Amount[i]);
		}

		uint256 mintAmountManager = utilizedERC20AmountTotalETHValue * feeRateManager / ONE_HUNDRED_PERCENT;

		uint256 mintAmountGovernancePayTo = utilizedERC20AmountTotalETHValue * feeRateGovernance / ONE_HUNDRED_PERCENT;

		_mint(manager, mintAmountManager);
		_mint(I_V1_EMP_REGISTRY.governancePayTo(), mintAmountGovernancePayTo);
		_mint(msg.sender, utilizedERC20AmountTotalETHValue - mintAmountManager - mintAmountGovernancePayTo);
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20DepositOpenToggle()
		public
		override
		authGovernanceOrManager()
	{
		utilizedERC20DepositOpen = !utilizedERC20DepositOpen;
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20Update()
		public
		override
	{
		I_V1_EMP_UTILITY.utilizedERC20Update();

		address[] memory __utilizedERC20 = I_V1_EMP_UTILITY.v1EMP_utilizedERC20(address(this));

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			for (uint256 ii = 0; ii < __utilizedERC20.length; ii++)
			{
				IERC20(__utilizedERC20[ii]).approve(
					address(IV1EMPStrategy(_utilizedV1EMPStrategy[i]).iV1EMPStrategyInteractor()),
					type(uint256).max
				);
			}
		}
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20Withdraw(uint256 _eRC20Amount)
		public
		override
		nonReentrant()
	{
		require(utilizedERC20WithdrawOpen, "!utilizedERC20WithdrawOpen");

		require(balanceOf(msg.sender) >= _eRC20Amount, "!(balanceOf(msg.sender) >= _eRC20Amount)");

		bool utilizedERC20Available = true;

		utilizedERC20Update();

		address[] memory _utilizedERC20 = I_V1_EMP_UTILITY.v1EMP_utilizedERC20(address(this));

		uint256[] memory _utilizedERC20TotalAmount = I_V1_EMP_UTILITY.utilizedERC20TotalBalance(address(this));

		uint256[] memory transferAmount = new uint256[](_utilizedERC20.length);

		for (uint256 i = 0; i < _utilizedERC20.length; i++)
		{
			require(totalSupply() != 0, "!(totalSupply() != 0)");

			transferAmount[i] = _utilizedERC20TotalAmount[i] * 1e18 / totalSupply() * _eRC20Amount / 1e18;

			if (IERC20(_utilizedERC20[i]).balanceOf(address(this)) < transferAmount[i])
			{
				utilizedERC20Available = false;

				break;
			}
		}

		if (utilizedERC20Available)
		{
			for (uint256 i = 0; i < _utilizedERC20.length; i++)
			{
				transfer(msg.sender, transferAmount[i]);
			}
		}
		else
		{
			if (!utilizedERC20WithdrawFull)
			{
				revert("!(utilizedERC20Available)");
			}

			uint256[] memory v1EMPStrategyERC20Amount = new uint256[](_utilizedV1EMPStrategy.length);

			uint256 _eRC20AmountPercentOfTotalSupply = _eRC20Amount * 1e18 / totalSupply();

			for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
			{
				v1EMPStrategyERC20Amount[i] = _eRC20AmountPercentOfTotalSupply * IV1EMPStrategy(
					_utilizedV1EMPStrategy[i]
				).eMP_equity(
					address(this)
				) / 1e18;
			}

			utilizedV1EMPStrategyWithdraw(v1EMPStrategyERC20Amount);
		}

		_burn(msg.sender, _eRC20Amount);
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20WithdrawFullToggle()
		public
		override
		authGovernanceOrManager()
	{
		utilizedERC20WithdrawFull = !utilizedERC20WithdrawFull;
	}

	/// @inheritdoc IV1EMP
	function utilizedERC20WithdrawOpenToggle()
		public
		override
		authGovernanceOrManager()
	{
		utilizedERC20WithdrawOpen = !utilizedERC20WithdrawOpen;
	}

	/// @inheritdoc IV1EMP
	function utilizedV1EMPStrategyDeposit(uint256[][] memory _v1EMPStrategyUtilizedERC20Amount)
		public
		override
		utilizedERC20DepositOpenRequired()
	{
		require(
			_v1EMPStrategyUtilizedERC20Amount.length == _utilizedV1EMPStrategy.length,
			"!(_v1EMPStrategyUtilizedERC20Amount.length == _utilizedV1EMPStrategy.length)"
		);

		require(
			I_V1_EMP_UTILITY.v1EMPStrategyUtilizedERC20AmountValid(address(this), _v1EMPStrategyUtilizedERC20Amount),
			"!I_V1_EMP_UTILITY.v1EMPStrategyUtilizedERC20AmountValid(address(this), _v1EMPStrategyUtilizedERC20Amount)"
		);

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			IV1EMPStrategy(_utilizedV1EMPStrategy[i]).utilizedERC20Deposit(address(this), _v1EMPStrategyUtilizedERC20Amount[i]);
		}
	}

	/// @inheritdoc IV1EMP
	function utilizedV1EMPStrategyUpdate(address[] memory _v1EMPStrategy, uint256[] memory _allocation)
		public
		override
		authGovernanceOrManager()
	{
		require(
			!utilizedERC20DepositOpen && !utilizedERC20WithdrawOpen,
			"!(!utilizedERC20DepositOpen && !utilizedERC20WithdrawOpen)"
		);

		require(_v1EMPStrategy.length == _allocation.length, "!(_v1EMPStrategy.length == _allocation.length)");

		uint256 utilizedV1EMPStrategyAllocationTotal;

		for (uint256 i = 0; i < _allocation.length; i++)
		{
			utilizedV1EMPStrategyAllocationTotal += _allocation[i];
		}

		require(
			utilizedV1EMPStrategyAllocationTotal == ONE_HUNDRED_PERCENT,
			"!(utilizedV1EMPStrategyAllocationTotal == ONE_HUNDRED_PERCENT)"
		);

		delete _utilizedV1EMPStrategy;

		for (uint256 i = 0; i < _v1EMPStrategy.length; i++)
		{
			_utilizedV1EMPStrategy.push(_v1EMPStrategy[i]);

			utilizedV1EMPStrategy_allocation[_v1EMPStrategy[i]] = _allocation[i];
		}

		utilizedERC20Update();
	}

	/// @inheritdoc IV1EMP
	function utilizedV1EMPStrategyWithdraw(uint256[] memory _v1EMPStrategyERC20Amount)
		public
		override
		authGovernanceOrManager()
	{
		require(
			_v1EMPStrategyERC20Amount.length == _utilizedV1EMPStrategy.length,
			"!(_v1EMPStrategyERC20Amount.length == _utilizedV1EMPStrategy.length)"
		);

		utilizedERC20Update();

		for (uint256 i = 0; i < _utilizedV1EMPStrategy.length; i++)
		{
			if (_v1EMPStrategyERC20Amount[i] > 0)
			{
				IV1EMPStrategy(_utilizedV1EMPStrategy[i]).utilizedERC20Withdraw(_v1EMPStrategyERC20Amount[i]);
			}
		}
	}
}
