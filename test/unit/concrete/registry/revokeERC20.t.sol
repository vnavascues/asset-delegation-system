// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IDelegateRegistryWrite } from "src/interfaces/IDelegateRegistryWrite.sol";

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";
import { Errors } from "src/protocol/libraries/Errors.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

contract RevokeERC20_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
    address private s_delegator;
    address private s_delegatee;
    address private s_contract;
    bytes32 private s_privileges;
    uint256 private s_amount;
    bytes32 private s_delegationKey;

    function setUp() public virtual override {
        super.setUp();
        s_delegator = s_addr2;
        vm.label(s_delegator, "Delegator");
        s_delegatee = s_addr3;
        vm.label(s_delegatee, "Delegatee");
        s_contract = address(777);
        vm.label(s_contract, "Contract");

        // 1. delegate an ERC721
        s_privileges = keccak256(abi.encode("all"));
        s_amount = 1616;
        vm.prank(s_delegator);
        s_delegationKey = s_delegateRegistry.delegateERC20(s_delegatee, s_contract, s_privileges, s_amount);
    }

    function test_RevertWhen_DelegationDoesNotExist() external {
        address contract_ = address(888);
        bytes32 expectedDelegationKey = 0x7aacd5b67e203b82887c1287b3126fbd3a999850e7f2845e7206aa3cbf48a885;

        // it should revert
        vm.expectRevert(
            abi.encodeWithSelector(Errors.DelegateRegistry__DelegationDoesNotExist.selector, expectedDelegationKey)
        );
        vm.prank(s_delegator);
        s_delegateRegistry.revokeERC20(s_delegatee, contract_, s_privileges);
    }

    function test_WhenDelegationExists() external {
        // it should emit ERC721Revoked event
        vm.expectEmit(address(s_delegateRegistry));
        emit IDelegateRegistryWrite.ERC20Revoked(s_delegator, s_delegatee, s_contract, s_privileges);
        vm.prank(s_delegator);
        bool success = s_delegateRegistry.revokeERC20(s_delegatee, s_contract, s_privileges);

        // it should unmap delegationKey
        Delegation memory delegation = s_delegateRegistry.getDelegation(s_delegationKey);
        assertEq(uint8(delegation.delegationType), uint8(DelegationType.NONE), "delegation.delegationType");
        assertEq(delegation.delegator, address(0), "delegation.delegator");
        assertEq(delegation.delegatee, address(0), "delegation.delegatee");
        assertEq(delegation.contract_, address(0), "delegation.contract_");
        assertEq(delegation.tokenId, 0, "delegation.tokenId");
        assertEq(delegation.privileges, bytes32(0), "delegation.privileges");
        assertEq(delegation.amount, 0, "delegation.amount");

        // it should unmap delegator
        bytes32[] memory delegatorDelegationKeys = s_delegateRegistry.getDelegatorDelegationKeys(s_delegator);
        assertEq(delegatorDelegationKeys.length, 0);

        // it should unmap delegatee
        bytes32[] memory delegateeDelegationKeys = s_delegateRegistry.getDelegateeDelegationKeys(s_delegatee);
        assertEq(delegateeDelegationKeys.length, 0);

        // it should return true
        assertEq(success, true);
    }
}
