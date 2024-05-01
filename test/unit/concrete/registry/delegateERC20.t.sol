// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IDelegateRegistryWrite } from "src/interfaces/IDelegateRegistryWrite.sol";
import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";
import { Errors } from "src/protocol/libraries/Errors.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

contract DelegateERC20_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
    address private s_delegator;
    address private s_delegatee;
    address private s_contract;

    function setUp() public virtual override {
        super.setUp();
        s_delegator = s_addr2;
        vm.label(s_delegator, "Delegator");
        s_delegatee = s_addr3;
        vm.label(s_delegatee, "Delegatee");
        s_contract = address(777);
        vm.label(s_contract, "Contract");
    }

    function test_RevertWhen_DelegationExists() external {
        bytes32 privileges = keccak256(abi.encode("all"));
        uint256 amount = 1616;

        vm.prank(s_delegator);
        bytes32 delegationKey = s_delegateRegistry.delegateERC20(s_delegatee, s_contract, privileges, amount);

        // it should revert
        vm.expectRevert(
            abi.encodeWithSelector(Errors.DelegateRegistry__DelegationExists.selector, delegationKey, amount)
        );
        vm.prank(s_delegator);
        s_delegateRegistry.delegateERC20(s_delegatee, s_contract, privileges, amount);
    }

    function test_WhenDelegationDoesNotExist() external {
        bytes32 privileges = keccak256(abi.encode("all"));
        uint256 amount = 1616;
        bytes32 expectedDelegationKey = 0xb552a0a87207012d117353876842bcf6daa414601336f3d3a41b38a80f3c2d64;

        // it should emit ERC20Delegated event
        vm.expectEmit(address(s_delegateRegistry));
        emit IDelegateRegistryWrite.ERC20Delegated(s_delegator, s_delegatee, s_contract, privileges, amount);
        vm.prank(s_delegator);
        bytes32 delegationKey = s_delegateRegistry.delegateERC20(s_delegatee, s_contract, privileges, amount);

        // it should map delegationKey
        Delegation memory delegation = s_delegateRegistry.getDelegation(delegationKey);
        assertEq(uint8(delegation.delegationType), uint8(DelegationType.ERC20), "delegation.delegationType");
        assertEq(delegation.delegator, s_delegator, "delegation.delegator");
        assertEq(delegation.delegatee, s_delegatee, "delegation.delegatee");
        assertEq(delegation.contract_, s_contract, "delegation.contract_");
        assertEq(delegation.tokenId, 0, "delegation.tokenId");
        assertEq(delegation.privileges, privileges, "delegation.privileges");
        assertEq(delegation.amount, amount, "delegation.amount");

        // it should map delegator
        bytes32[] memory delegatorDelegationKeys = s_delegateRegistry.getDelegatorDelegationKeys(s_delegator);
        assertEq(delegatorDelegationKeys.length, 1);
        assertEq(delegatorDelegationKeys[0], expectedDelegationKey);

        // it should setmap delegatee
        bytes32[] memory delegateeDelegationKeys = s_delegateRegistry.getDelegateeDelegationKeys(s_delegatee);
        assertEq(delegateeDelegationKeys.length, 1);
        assertEq(delegateeDelegationKeys[0], expectedDelegationKey);

        // it should return delegationKey
        assertEq(delegationKey, expectedDelegationKey, "delegationKey");
    }
}
