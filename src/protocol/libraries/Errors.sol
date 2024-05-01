// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegationType } from "./DataTypes.sol";

library Errors {
    /* ========== DelegationKeysLibrary ========== */

    error DelegationKeysLibrary__DelegationKeyIsNotInserted(bytes32 delegationKey);

    /* ========== DelegateRegistry ========== */

    error DelegateRegistry__DelegationExists(bytes32 delegationKey, uint256 amount);
    error DelegateRegistry__DelegationDoesNotExist(bytes32 delegationKey);
    error DelegateRegistry__UnsupportedDelegationType(DelegationType delegationType);
}
