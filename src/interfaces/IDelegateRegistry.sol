// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { IDelegateRegistryRead } from "./IDelegateRegistryRead.sol";
import { IDelegateRegistryWrite } from "./IDelegateRegistryWrite.sol";

/**
 * @title IDelegateRegistryRead
 * @author vnavascues
 * @notice A permissionless asset delegation system that stores delegation data from a Delegator to a Delegatee for a
 * certain kind of asset (e.g. ERC20, ERC721).
 * @dev Merges `IDelegateRegistryRead` and `IDelegateRegistryWrite`.
 */
interface IDelegateRegistry is IDelegateRegistryRead, IDelegateRegistryWrite { }
