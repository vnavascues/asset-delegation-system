// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IDelegateRegistryWrite } from "src/interfaces/IDelegateRegistryWrite.sol";
import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";
import { Errors } from "src/protocol/libraries/Errors.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

contract DelegateERC721_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
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
        uint256 tokenId = 1;
        bytes32 privileges = keccak256(abi.encode("all"));

        vm.prank(s_delegator);
        bytes32 delegationKey = s_delegateRegistry.delegateERC721(s_delegatee, s_contract, tokenId, privileges);

        // it should revert
        vm.expectRevert(abi.encodeWithSelector(Errors.DelegateRegistry__DelegationExists.selector, delegationKey, 1));
        vm.prank(s_delegator);
        s_delegateRegistry.delegateERC721(s_delegatee, s_contract, tokenId, privileges);
    }

    function test_WhenDelegationDoesNotExist() external {
        uint256 tokenId = 1;
        bytes32 privileges = keccak256(abi.encode("all"));
        bytes32 expectedDelegationKey = 0x2c2ebc313f8a2cc2775c1111f0d0e54a852bf8e673b0ed16e17e02ad0a870b0e;

        // it should emit ERC721Delegated event
        vm.expectEmit(address(s_delegateRegistry));
        emit IDelegateRegistryWrite.ERC721Delegated(s_delegator, s_delegatee, s_contract, tokenId, privileges);
        vm.prank(s_delegator);
        bytes32 delegationKey = s_delegateRegistry.delegateERC721(s_delegatee, s_contract, tokenId, privileges);

        // it should map delegationKey
        Delegation memory delegation = s_delegateRegistry.getDelegation(delegationKey);
        assertEq(uint8(delegation.delegationType), uint8(DelegationType.ERC721), "delegation.delegationType");
        assertEq(delegation.delegator, s_delegator, "delegation.delegator");
        assertEq(delegation.delegatee, s_delegatee, "delegation.delegatee");
        assertEq(delegation.contract_, s_contract, "delegation.contract_");
        assertEq(delegation.tokenId, tokenId, "delegation.tokenId");
        assertEq(delegation.privileges, privileges, "delegation.privileges");
        assertEq(delegation.amount, 1, "delegation.amount");

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
