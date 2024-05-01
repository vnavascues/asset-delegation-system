// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IDelegateRegistry } from "src/interfaces/IDelegateRegistry.sol";
import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

contract GetDelegation_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
    address private s_delegator;
    address private s_delegatee;
    address private s_contract;
    uint256 private s_tokenId;
    bytes32 private s_privileges;
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
        s_tokenId = 1;
        s_privileges = keccak256(abi.encode("all"));
        vm.prank(s_delegator);
        s_delegationKey = s_delegateRegistry.delegateERC721(s_delegatee, s_contract, s_tokenId, s_privileges);
    }

    function test_WhenDelegationDoesNotExist() external {
        bytes32 delegationKey = s_delegationKey | bytes32(uint256(1));
        Delegation memory delegation = s_delegateRegistry.getDelegation(delegationKey);

        // it should return default delegation
        assertEq(uint8(delegation.delegationType), uint8(DelegationType.NONE), "delegation.delegationType");
        assertEq(delegation.delegator, address(0), "delegation.delegator");
        assertEq(delegation.delegatee, address(0), "delegation.delegatee");
        assertEq(delegation.contract_, address(0), "delegation.contract_");
        assertEq(delegation.tokenId, 0, "delegation.tokenId");
        assertEq(delegation.privileges, bytes32(0), "delegation.privileges");
        assertEq(delegation.amount, 0, "delegation.amount");
    }

    function test_WhenDelegationExists() external {
        Delegation memory delegation = s_delegateRegistry.getDelegation(s_delegationKey);

        // it should return one delegated amount
        assertEq(uint8(delegation.delegationType), uint8(DelegationType.ERC721), "delegation.delegationType");
        assertEq(delegation.delegator, s_delegator, "delegation.delegator");
        assertEq(delegation.delegatee, s_delegatee, "delegation.delegatee");
        assertEq(delegation.contract_, s_contract, "delegation.contract_");
        assertEq(delegation.tokenId, s_tokenId, "delegation.tokenId");
        assertEq(delegation.privileges, s_privileges, "delegation.privileges");
        assertEq(delegation.amount, 1, "delegation.amount");
    }
}
