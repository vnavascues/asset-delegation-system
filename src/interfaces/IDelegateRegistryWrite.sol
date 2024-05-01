// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title IDelegateRegistryWrite
 * @author vnavascues
 * @notice A permissionless asset delegation system that stores delegation data from a Delegator to a Delegatee for a
 * certain kind of asset (e.g. ERC20, ERC721).
 * @dev Declares functions that change the DelegateRegistry state.
 */
interface IDelegateRegistryWrite {
    /// @notice Emitted when an ERC20 delegation is set.
    event ERC20Delegated(
        address indexed delegator,
        address indexed delegatee,
        address indexed contract_,
        bytes32 privileges,
        uint256 amount
    );

    /// @notice Emitted when an ERC20 delegation is revoked.
    event ERC20Revoked(
        address indexed delegator, address indexed delegatee, address indexed contract_, bytes32 privileges
    );

    /// @notice Emitted when an ERC721 delegation is set.
    event ERC721Delegated(
        address indexed delegator,
        address indexed delegatee,
        address indexed contract_,
        uint256 tokenId,
        bytes32 privileges
    );

    /// @notice Emitted when an ERC721 delegation is revoked.
    event ERC721Revoked(
        address indexed delegator,
        address indexed delegatee,
        address indexed contract_,
        uint256 tokenId,
        bytes32 privileges
    );

    /**
     * @notice Allow a Delegator (`msg.sender`) to delegate an amount of token to a Delegatee with specific privileges.
     * @dev Reverts with {Errors.DelegateRegistry__DelegationExists} if the delegation to be set already exists.
     * @dev Emits an {ERC20Delegated} event.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC20 contract.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @param amount The TKN amount to be delegated.
     * @return delegationKey The identifier of the Delegation data.
     */
    function delegateERC20(
        address delegatee,
        address contract_,
        bytes32 privileges,
        uint256 amount
    )
        external
        returns (bytes32);

    /**
     * @notice Allow a Delegator (`msg.sender`) to revoke a previously set delegation for an ERC20.
     * @dev Reverts with {Errors.DelegateRegistry__DelegationDoesNotExist} if the delegation to be revoked does not
     * exist.
     * @dev Emits an {ERC20Revoked} event.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC20 contract.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return success A `true` boolean indicating the operation was a success (otherwise it reverts).
     */
    function revokeERC20(address delegatee, address contract_, bytes32 privileges) external returns (bool);

    /**
     * @notice Allow a Delegator (`msg.sender`) to delegate a NFT token to a Delegatee with specific privileges.
     * @dev Reverts with {Errors.DelegateRegistry__DelegationExists} if the delegation to be set already exists.
     * @dev Emits an {ERC721Delegated} event.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC721 contract.
     * @param tokenId The identifier of the NFT token be delegated.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return delegationKey The identifier of the Delegation data.
     */
    function delegateERC721(
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        returns (bytes32);

    /**
     * @notice Allow a Delegator (`msg.sender`) to revoke a previously set delegation for an ERC721.
     * @dev Reverts with {Errors.DelegateRegistry__DelegationDoesNotExist} if the delegation to be revoked does not
     * exist.
     * @dev Emits an {ERC721Revoked} event.
     * @param delegatee The address that benefits from the delegation.
     * @param contract_ The address of the ERC721 contract.
     * @param tokenId The identifier of the NFT token be delegated.
     * @param privileges The permission (or a set of them) to be attached to the delegation.
     * @return success A `true` boolean indicating the operation was a success (otherwise it reverts).
     */
    function revokeERC721(
        address delegatee,
        address contract_,
        uint256 tokenId,
        bytes32 privileges
    )
        external
        returns (bool);
}
