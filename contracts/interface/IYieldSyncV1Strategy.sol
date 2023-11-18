// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


struct Allocation
{
	uint8 denominator;
	uint8 numerator;
}


interface IYieldSyncV1Strategy is
	IERC20
{
	/**
	* @notice token to allocation
	* @dev [view-mapping]
	* @param token {address}
	* @return {Allocation}
	*/
	function token_allocation(address token)
		external
		view
		returns (Allocation memory)
	;


	/**
	* @notice Value of position denominated in WETH
	* @param target {address}
	* @return positionValueInWETH_ {uint256}
	*/
	function positionValueInWETH(address target)
		external
		view
		returns (uint256 positionValueInWETH_)
	;

	/**
	* @notice
	* @param _token {address}
	* @return utilized_ {bool}
	*/
	function token_utilized(address _token)
		external
		view
		returns (bool utilized_)
	;

	/**
	* @notice Array of utilized tokens
	* @return utilizedToken_ {address[]}
	*/
	function utilizedToken()
		external
		view
		returns (address[] memory utilizedToken_)
	;

	/**
	* @notice Return value of token denominated in WETH
	* @param _token {uint256}
	* @return tokenValueInWETH_ {uint256}
	*/
	function utilizedTokenValueInWETH(address _token)
		external
		view
		returns (uint256 tokenValueInWETH_)
	;
}
