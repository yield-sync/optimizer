// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


import { IAssetAllocator } from "./interface/IAssetAllocator.sol";


contract AssetAllocator is
	IAssetAllocator
{
	constructor ()
	{}

	function allocate(address strategy)
		public
	{}

	function deallocate(address strategy)
		public
	{}

	function withdrawalRequestCreate()
		public
	{}
}
