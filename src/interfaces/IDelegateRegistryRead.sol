// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Delegation } from "src/protocol/libraries/DataTypes.sol";

/**
 * @title IDelegateRegistryRead
 * @author vnavascues
 * @notice A permissionless asset delegation system that stores delegation data from a Delegator to a Delegatee for a
 * certain kind of asset (e.g. ERC20, ERC721).
 * @dev Declares DelegateRegistry getters and helper methods to be used on-chain and/or off-chain.
 */
interface IDelegateRegistryRead {
    /**
     * @notice Returns the TKN amount that has been delegated from a Delegator to a Delegatee with specific privileges.
     * @param delegator The address that set the delegation.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC20 contract.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return amount The delegated amount (0 if ther isn't a delegation, N otherwise).
     */
    function getDelegatedERC20(
        address delegator,
        address delegatee,
        address contract_,
        bytes32 privileges
    )
        external
        view
        returns (uint256);

    /**
     * @notice Get whether a NFT token has been delegated from a Delegator to a Delegatee with specific privileges.
     * @param delegator The address that set the delegation.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC721 contract.
     * @param tokenId The identifier of the NFT token be delegated.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return amount The delegated amount (0 if ther isn't a delegation, 1 otherwise).
     */
    function getDelegatedERC721(
        address delegator,
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        view
        returns (uint256);

    /**
     * @notice Get the whole delegation data of any asset by key.
     * @dev A non-existent `delegationKey` will return a default `Delegation` (a struct with all its members defaulted).
     * Devs should check that `Delegation.delegator` is not the zero address.
     * @param delegationKey The Delegation identifier.
     * @return Delegation The struct that contains all the delegation data.
     */
    function getDelegation(bytes32 delegationKey) external view returns (Delegation memory);

    /**
     * @notice Get an array of whole delegation data of any asset by keys.
     * @dev The `delegationKeys` array can contain repeated and/or non-existent items.
     * @dev A non-existent `delegationKey` will return a default `Delegation` (a struct with all its members defaulted).
     * Devs should check that any `Delegation.delegator` is not the zero address.
     * @param delegationKeys The Delegation identifiers.
     * @return Delegations The array of structs that contains all the delegation data.
     */
    function getDelegations(bytes32[] calldata delegationKeys) external view returns (Delegation[] memory);

    /**
     * @notice Calculate the delegation key for an ERC20 delegation.
     * @param delegator The address that set the delegation.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC20 contract.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return delegationKey The Delegation identifier.
     */
    function getDelegationKeyERC20(
        address delegator,
        address delegatee,
        address contract_,
        bytes32 privileges
    )
        external
        pure
        returns (bytes32);

    /**
     * @notice Calculate the delegation key for an ERC721 delegation.
     * @param delegator The address that set the delegation.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC721 contract.
     * @param tokenId The identifier of the NFT token be delegated.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return delegationKey The Delegation identifier.
     */
    function getDelegationKeyERC721(
        address delegator,
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        pure
        returns (bytes32);

    /**
     * @notice Get an array of the current delegation keys for the given Delegator.
     * @param delegator The address that set the delegation.
     * @return delegationKeys The array of delegation keys.
     */
    function getDelegatorDelegationKeys(address delegator) external view returns (bytes32[] memory);

    /**
     * @notice Get an array of the current delegation keys for the given Delegatee.
     * @param delegatee The address that benefits from the delegation.
     * @return delegationKeys The array of delegation keys.
     */
    function getDelegateeDelegationKeys(address delegatee) external view returns (bytes32[] memory);
}
