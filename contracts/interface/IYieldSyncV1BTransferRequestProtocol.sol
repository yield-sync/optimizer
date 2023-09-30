// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { ITransferRequestProtocol, TransferRequest } from "./ITransferRequestProtocol.sol";
import { IYieldSyncV1VaultRegistry } from "./IYieldSyncV1VaultRegistry.sol";


struct YieldSyncV1VaultProperty
{
	uint256 voteAgainstRequired;
	uint256 voteForRequired;
	uint256 maxVotePeriodSeconds;
	uint256 minVotePeriodSeconds;
}

struct TransferRequestPoll
{
	uint256 voteCloseTimestamp;
	address[] voteAgainstMembers;
	address[] voteForMembers;
}


interface IYieldSyncV1BTransferRequestProtocol is
	ITransferRequestProtocol
{
	event CreatedTransferRequest(address yieldSyncV1Vault, uint256 transferRequestId);
	event DeletedTransferRequest(address yieldSyncV1Vault, uint256 transferRequestId);
	event UpdateTransferRequest(address yieldSyncV1Vault, TransferRequest transferRequest);
	event UpdateTransferRequestPoll(address yieldSyncV1Vault, TransferRequestPoll transferRequestPoll);
	event MemberVoted(address yieldSyncV1Vault, uint256 transferRequestId, address member, bool vote);


	/**
	* @notice YieldSyncV1VaultRegistry Interfaced
	* @dev [view-address]
	* @return {IYieldSyncV1VaultRegistry}
	*/
	function YieldSyncV1VaultRegistry()
		external
		view
		returns (IYieldSyncV1VaultRegistry)
	;


	/**
	* @notice Getter for `_yieldSyncV1Vault_openTransferRequestIds`
	* @dev [view][mapping]
	* @param yieldSyncV1Vault {address}
	* @return {uint256[]}
	*/
	function yieldSyncV1Vault_openTransferRequestIds(address yieldSyncV1Vault)
		external
		view
		returns (uint256[] memory)
	;

	/**
	* @notice Getter for `_yieldSyncV1Vault_yieldSyncV1VaultProperty`
	* @dev [view][mapping]
	* @param yieldSyncV1Vault {address}
	* @return {YieldSyncV1VaultProperty}
	*/
	function yieldSyncV1Vault_yieldSyncV1VaultProperty(address yieldSyncV1Vault)
		external
		returns (YieldSyncV1VaultProperty memory)
	;

	/**
	* @notice Getter for `_yieldSyncV1Vault_transferRequestId_transferRequestPoll`
	* @dev [view][mapping]
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	* @return {TransferRequestPoll}
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestPoll(
		address yieldSyncV1Vault,
		uint256 transferRequestId
	)
		external
		view returns (TransferRequestPoll memory)
	;


	/**
	* @notice Delete transferRequest & all associated values
	* @dev [restriction] `YieldSyncV1Record` → admin
	* @dev Utilized by `YieldSyncV1Vault`
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestAdminDelete(
		address yieldSyncV1Vault,
		uint256 transferRequestId
	)
		external
	;

	/**
	* @notice Update transferRequest
	* @dev [restriction] `YieldSyncV1Record` → admin
	* @dev [update] `_transferRequest`
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	* @param transferRequest {TransferRequest}
	* Emits: `UpdateTransferRequest`
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestAdminUpdate(
		address yieldSyncV1Vault,
		uint256 transferRequestId,
		TransferRequest memory transferRequest
	)
		external
	;

	/**
	* @notice Create a transferRequest
	* @dev [restriction] `YieldSyncV1Record` → member
	* @dev [add] `_yieldSyncV1Vault_transferRequestId_transferRequest` value
	*      [add] `_yieldSyncV1Vault_transferRequestId_transferRequestPoll` value
	*      [push-into] `_yieldSyncV1Vault_openTransferRequestIds`
	*      [increment] `_transferRequestIdTracker`
	* @param yieldSyncV1Vault {address}
	* @param forERC20 {bool}
	* @param forERC721 {bool}
	* @param to {address}
	* @param token {address} Token contract
	* @param amount {uint256}
	* @param tokenId {uint256} ERC721 token id
	* Emits: `CreatedTransferRequest`
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestCreate(
		address yieldSyncV1Vault,
		bool forERC20,
		bool forERC721,
		address to,
		address token,
		uint256 amount,
		uint256 tokenId,
		uint256 voteCloseTimestamp
	)
		external
	;

	/**
	* @notice Delete transferRequest & all associated values
	* @dev [restriction] `YieldSyncV1Record` → member
	* @dev Utilized by `YieldSyncV1Vault`
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestDelete(
		address yieldSyncV1Vault,
		uint256 transferRequestId
	)
		external
	;

	/**
	* @notice Update a TransferRequestPoll
	* @dev [restriction] `YieldSyncV1Record` → admin
	* @dev [update] `_transferRequest`
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	* @param transferRequestPoll {TransferRequestPoll}
	* Emits: `UpdateTransferRequestPoll`
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestPollAdminUpdate(
		address yieldSyncV1Vault,
		uint256 transferRequestId,
		TransferRequestPoll memory transferRequestPoll
	)
		external
	;

	/**
	* @notice Vote on transferRequest
	* @dev [restriction] `YieldSyncV1Record` → member
	* @dev [update] `_transferRequest`
	* @param yieldSyncV1Vault {address}
	* @param transferRequestId {uint256}
	* @param vote {bool} true (approve) or false (deny)
	* Emits: `TransferRequestReadyToBeProcessed`
	* Emits: `MemberVoted`
	*/
	function yieldSyncV1Vault_transferRequestId_transferRequestPollVote(
		address yieldSyncV1Vault,
		uint256 transferRequestId,
		bool vote
	)
		external
	;

	/**
	* @notice Update
	* @dev [restriction] `YieldSyncV1Record` → admin
	* @dev [update] `_updateYieldSyncV1VaultProperty`
	* @param yieldSyncV1Vault {address}
	* @param yieldSyncV1VaultProperty {YieldSyncV1VaultProperty}
	* Emits: `UpdatedYieldSyncV1VaultYieldSyncV1VaultProperty`
	*/
	function yieldSyncV1Vault_yieldSyncV1VaultPropertyAdminUpdate(
		address yieldSyncV1Vault,
		YieldSyncV1VaultProperty memory yieldSyncV1VaultProperty
	)
		external
	;
}
