// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";


struct MessageHashData
{
	bytes signature;
	address signer;
}


interface ISignatureProtocol is
	IERC1271
{
	/// @inheritdoc IERC1271
	function isValidSignature(bytes32 _messageHash, bytes memory _signature)
		external
		view
		override
		returns (bytes4 magicValue)
	;


	/**
	* @param initiator {address}
	* @param yieldSyncV1Vault {address}
	*/
	function yieldSyncV1VaultInitialize(address initiator, address yieldSyncV1Vault)
		external
	;
}
