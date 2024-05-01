// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IDelegateRegistry } from "src/interfaces/IDelegateRegistry.sol";
import { IDelegateRegistryRead } from "src/interfaces/IDelegateRegistryRead.sol";
import { IDelegateRegistryWrite } from "src/interfaces/IDelegateRegistryWrite.sol";
import { ITypeAndVersion } from "src/interfaces/ITypeAndVersion.sol";
import { Errors } from "src/protocol/libraries/Errors.sol";
import { DelegationKeysLibrary } from "src/protocol/libraries/internal/DelegationKeysLibrary.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

/**
 * @title DelegateRegistry
 * @author vnavascues
 * @notice A permissionless asset delegation system that stores delegation data from a Delegator to a Delegatee for a
 * certain kind of asset (e.g. ERC20, ERC721).
 */
contract DelegateRegistry is IDelegateRegistry, ITypeAndVersion {
    using DelegationKeysLibrary for DelegationKeysLibrary.Map;

    uint256 private constant DELEGATED_ERC20_TOKEN_ID = 0;
    uint256 private constant DELEGATED_ERC721_AMOUNT = 1;

    /// @dev Maps a key (made from unique `Delegation` data) to a `Delegation` struct.
    mapping(bytes32 delegationKey => Delegation delegation) internal s_delegationKeyToDelegation;

    /// @dev Maps a Delegator address to an iterable mapping that contains an up-to-date array of `delegationKey` set by
    /// the Delegator address.
    mapping(address delegator => DelegationKeysLibrary.Map delegationKeys) internal s_delegatorToDelegationKeys;

    /// @dev Maps a Delegatee address to an iterable mapping that contains an up-to-date array of `delegationKey` set to
    /// the Delegatee address.
    mapping(address delegatee => DelegationKeysLibrary.Map delegationKeys) internal s_delegateeToDelegationKeys;

    /* ========== EXTERNAL FUNCTIONS ========== */

    /// @inheritdoc IDelegateRegistryWrite
    function delegateERC20(
        address delegatee,
        address contract_,
        bytes32 privileges,
        uint256 amount
    )
        external
        returns (bytes32)
    {
        bytes32 delegationKey = _getDelegationKey(
            msg.sender, delegatee, contract_, DelegationType.ERC20, DELEGATED_ERC20_TOKEN_ID, privileges
        );

        if (
            s_delegationKeyToDelegation[delegationKey].delegator == msg.sender
                && s_delegationKeyToDelegation[delegationKey].amount == amount
        ) {
            revert Errors.DelegateRegistry__DelegationExists(delegationKey, amount);
        }

        Delegation memory delegation;
        delegation.delegationType = DelegationType.ERC20;
        delegation.delegator = msg.sender;
        delegation.delegatee = delegatee;
        delegation.contract_ = contract_;
        delegation.privileges = privileges;
        delegation.amount = amount;
        s_delegationKeyToDelegation[delegationKey] = delegation;
        s_delegatorToDelegationKeys[msg.sender].set(delegationKey);
        s_delegateeToDelegationKeys[delegatee].set(delegationKey);

        emit ERC20Delegated(msg.sender, delegatee, contract_, privileges, amount);

        return delegationKey;
    }

    /// @inheritdoc IDelegateRegistryWrite
    function revokeERC20(address delegatee, address contract_, bytes32 privileges) external returns (bool) {
        bytes32 delegationKey = _getDelegationKey(
            msg.sender, delegatee, contract_, DelegationType.ERC20, DELEGATED_ERC20_TOKEN_ID, privileges
        );

        if (s_delegationKeyToDelegation[delegationKey].delegator != msg.sender) {
            revert Errors.DelegateRegistry__DelegationDoesNotExist(delegationKey);
        }

        delete s_delegationKeyToDelegation[delegationKey];
        s_delegatorToDelegationKeys[msg.sender].remove(delegationKey);
        s_delegateeToDelegationKeys[delegatee].remove(delegationKey);

        emit ERC20Revoked(msg.sender, delegatee, contract_, privileges);

        return true;
    }

    /// @inheritdoc IDelegateRegistryWrite
    function delegateERC721(
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        returns (bytes32)
    {
        bytes32 delegationKey =
            _getDelegationKey(msg.sender, delegatee, contract_, DelegationType.ERC721, tokenId, privileges);

        if (s_delegationKeyToDelegation[delegationKey].delegator == msg.sender) {
            revert Errors.DelegateRegistry__DelegationExists(delegationKey, DELEGATED_ERC721_AMOUNT);
        }

        Delegation memory delegation;
        delegation.delegationType = DelegationType.ERC721;
        delegation.delegator = msg.sender;
        delegation.delegatee = delegatee;
        delegation.contract_ = contract_;
        delegation.tokenId = tokenId;
        delegation.privileges = privileges;
        delegation.amount = DELEGATED_ERC721_AMOUNT;
        s_delegationKeyToDelegation[delegationKey] = delegation;
        s_delegatorToDelegationKeys[msg.sender].set(delegationKey);
        s_delegateeToDelegationKeys[delegatee].set(delegationKey);

        emit ERC721Delegated(msg.sender, delegatee, contract_, tokenId, privileges);

        return delegationKey;
    }

    /// @inheritdoc IDelegateRegistryWrite
    function revokeERC721(
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        returns (bool)
    {
        bytes32 delegationKey =
            _getDelegationKey(msg.sender, delegatee, contract_, DelegationType.ERC721, tokenId, privileges);

        if (s_delegationKeyToDelegation[delegationKey].delegator != msg.sender) {
            revert Errors.DelegateRegistry__DelegationDoesNotExist(delegationKey);
        }

        delete s_delegationKeyToDelegation[delegationKey];
        s_delegatorToDelegationKeys[msg.sender].remove(delegationKey);
        s_delegateeToDelegationKeys[delegatee].remove(delegationKey);

        emit ERC721Revoked(msg.sender, delegatee, contract_, tokenId, privileges);

        return true;
    }

    /* ========== EXTERNAL VIEW FUNCTIONS ========== */

    /// @inheritdoc IDelegateRegistryRead
    function getDelegatedERC20(
        address delegator,
        address delegatee,
        address contract_,
        bytes32 privileges
    )
        external
        view
        returns (uint256)
    {
        bytes32 delegationKey = _getDelegationKey(delegator, delegatee, contract_, DelegationType.ERC20, 0, privileges);

        return s_delegationKeyToDelegation[delegationKey].amount;
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegatedERC721(
        address delegator,
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        view
        returns (uint256)
    {
        bytes32 delegationKey =
            _getDelegationKey(delegator, delegatee, contract_, DelegationType.ERC721, tokenId, privileges);

        return s_delegationKeyToDelegation[delegationKey].amount;
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegation(bytes32 delegationKey) external view returns (Delegation memory) {
        return s_delegationKeyToDelegation[delegationKey];
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegations(bytes32[] calldata delegationKeys) external view returns (Delegation[] memory) {
        uint256 delegationKeysLength = delegationKeys.length;
        Delegation[] memory delegations = new Delegation[](delegationKeysLength);
        for (uint256 i = 0; i < delegationKeysLength; ++i) {
            delegations[i] = s_delegationKeyToDelegation[delegationKeys[i]];
        }
        return delegations;
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegatorDelegationKeys(address delegator) external view returns (bytes32[] memory) {
        return s_delegatorToDelegationKeys[delegator].delegationKeys;
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegateeDelegationKeys(address delegatee) external view returns (bytes32[] memory) {
        return s_delegateeToDelegationKeys[delegatee].delegationKeys;
    }

    /// @inheritdoc ITypeAndVersion
    function typeAndVersion() external pure returns (string memory) {
        return "DelegateRegistry 1.0.0";
    }

    /* ========== EXTERNAL PURE FUNCTIONS ========== */

    /// @inheritdoc IDelegateRegistryRead
    function getDelegationKeyERC20(
        address delegator,
        address delegatee,
        address contract_,
        bytes32 privileges
    )
        external
        pure
        returns (bytes32)
    {
        return _getDelegationKey(delegator, delegatee, contract_, DelegationType.ERC20, 0, privileges);
    }

    /// @inheritdoc IDelegateRegistryRead
    function getDelegationKeyERC721(
        address delegator,
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        pure
        returns (bytes32)
    {
        return _getDelegationKey(delegator, delegatee, contract_, DelegationType.ERC721, tokenId, privileges);
    }

    /* ========== INTERNAL PURE FUNCTIONS ========== */

    function _getDelegationKey(
        address delegator,
        address delegatee,
        address contract_,
        DelegationType delegationType,
        uint256 tokenId,
        bytes32 privileges
    )
        internal
        pure
        returns (bytes32)
    {
        if (delegationType == DelegationType.ERC20) {
            return keccak256(abi.encodePacked(delegator, delegatee, contract_, delegationType, privileges));
        }
        if (delegationType == DelegationType.ERC721) {
            return keccak256(abi.encodePacked(delegator, delegatee, contract_, delegationType, tokenId, privileges));
        }

        revert Errors.DelegateRegistry__UnsupportedDelegationType(delegationType);
    }
}
