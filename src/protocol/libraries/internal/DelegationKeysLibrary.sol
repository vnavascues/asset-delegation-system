// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Errors } from "../Errors.sol";

library DelegationKeysLibrary {
    struct Map {
        bytes32[] delegationKeys;
        mapping(bytes32 => uint256) indexOf;
        mapping(bytes32 => bool) isInserted;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function set(Map storage self, bytes32 delegationKey) internal {
        if (self.isInserted[delegationKey]) return;
        self.isInserted[delegationKey] = true;
        self.indexOf[delegationKey] = self.delegationKeys.length;
        self.delegationKeys.push(delegationKey);
    }

    function remove(Map storage self, bytes32 delegationKey) internal {
        if (!self.isInserted[delegationKey]) {
            revert Errors.DelegationKeysLibrary__DelegationKeyIsNotInserted(delegationKey);
        }

        delete self.isInserted[delegationKey];

        uint256 index = self.indexOf[delegationKey];
        uint256 lastIndex = self.delegationKeys.length - 1;
        bytes32 lastDelegationKey = self.delegationKeys[lastIndex];

        self.indexOf[lastDelegationKey] = index;
        delete self.indexOf[delegationKey];

        self.delegationKeys[index] = lastDelegationKey;
        self.delegationKeys.pop();
    }

    /* ========== INTERNAL VIEW FUNCTIONS ========== */

    function getDelegationKeyAtIndex(Map storage self, uint256 index) internal view returns (bytes32) {
        return self.delegationKeys[index];
    }

    function size(Map storage self) internal view returns (uint256) {
        return self.delegationKeys.length;
    }
}
