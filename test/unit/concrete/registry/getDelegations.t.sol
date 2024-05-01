// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";
import { Delegation, DelegationType } from "src/protocol/libraries/DataTypes.sol";

contract GetDelegations_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
    address private s_delegator;
    address private s_delegatee;
    address private s_contract;
    uint256[] private s_tokenIds;
    bytes32[] private s_privilegesArray;
    bytes32[] private s_delegationKeys;

    function setUp() public virtual override {
        super.setUp();
        s_delegator = s_addr2;
        vm.label(s_delegator, "Delegator");
        s_delegatee = s_addr3;
        vm.label(s_delegatee, "Delegatee");
        s_contract = address(777);
        vm.label(s_contract, "Contract");

        // 1. delegate two ERC721
        uint256 tokenId0 = 1;
        bytes32 privileges0 = keccak256(abi.encode("mint"));
        vm.prank(s_delegator);
        bytes32 delegationKey0 = s_delegateRegistry.delegateERC721(s_delegatee, s_contract, tokenId0, privileges0);
        s_tokenIds.push(tokenId0);
        s_privilegesArray.push(privileges0);
        s_delegationKeys.push(delegationKey0);

        uint256 tokenId1 = 2;
        bytes32 privileges1 = keccak256(abi.encode("burn"));
        vm.prank(s_delegator);
        bytes32 delegationKey1 = s_delegateRegistry.delegateERC721(s_delegatee, s_contract, tokenId1, privileges1);
        s_tokenIds.push(tokenId1);
        s_privilegesArray.push(privileges1);
        s_delegationKeys.push(delegationKey1);
    }

    function test_WhenDelegationKeysIsEmpty() external {
        bytes32[] memory delegationKeys;

        Delegation[] memory delegations = s_delegateRegistry.getDelegations(delegationKeys);

        // it should return empty array
        assertEq(delegations.length, 0);
    }

    function test_WhenDelegationKeysIsNotEmpty() external {
        bytes32[] memory delegationKeys = new bytes32[](4);
        delegationKeys[0] = s_delegationKeys[0];
        delegationKeys[1] = s_delegationKeys[0] | bytes32(uint256(1)); // NB: does not exist
        delegationKeys[2] = s_delegationKeys[0]; // NB: repeated
        delegationKeys[3] = s_delegationKeys[1];

        Delegation[] memory delegations = s_delegateRegistry.getDelegations(delegationKeys);

        // it should return array of delegation
        assertEq(delegations.length, 4);

        // Delegation at position 0
        Delegation memory delegation0 = delegations[0];
        assertEq(uint8(delegation0.delegationType), uint8(DelegationType.ERC721), "delegation0.delegationType");
        assertEq(delegation0.delegator, s_delegator, "delegation0.delegator");
        assertEq(delegation0.delegatee, s_delegatee, "delegation0.delegatee");
        assertEq(delegation0.contract_, s_contract, "delegation0.contract_");
        assertEq(delegation0.tokenId, s_tokenIds[0], "delegation0.tokenId");
        assertEq(delegation0.privileges, s_privilegesArray[0], "delegation0.privileges");
        assertEq(delegation0.amount, 1, "delegation0.amount");

        // Delegation at position 1
        Delegation memory delegation1 = delegations[1];
        assertEq(uint8(delegation1.delegationType), uint8(DelegationType.NONE), "delegation1.delegationType");
        assertEq(delegation1.delegator, address(0), "delegation1.delegator");
        assertEq(delegation1.delegatee, address(0), "delegation1.delegatee");
        assertEq(delegation1.contract_, address(0), "delegation1.contract_");
        assertEq(delegation1.tokenId, 0, "delegation1.tokenId");
        assertEq(delegation1.privileges, bytes32(0), "delegation1.privileges");
        assertEq(delegation1.amount, 0, "delegation1.amount");

        // Delegation at position 2
        Delegation memory delegation2 = delegations[2];
        assertEq(uint8(delegation2.delegationType), uint8(delegation0.delegationType), "delegation2.delegationType");
        assertEq(delegation0.delegator, delegation0.delegator, "delegation2.delegator");
        assertEq(delegation0.delegatee, delegation0.delegatee, "delegation2.delegatee");
        assertEq(delegation0.contract_, delegation0.contract_, "delegation2.contract_");
        assertEq(delegation0.tokenId, delegation0.tokenId, "delegation2.tokenId");
        assertEq(delegation0.privileges, delegation0.privileges, "delegation2.privileges");
        assertEq(delegation0.amount, delegation0.amount, "delegation2.amount");

        // Delegation at position 3
        Delegation memory delegation3 = delegations[3];
        assertEq(uint8(delegation3.delegationType), uint8(delegation0.delegationType), "delegation3.delegationType");
        assertEq(delegation3.delegator, s_delegator, "delegation3.delegator");
        assertEq(delegation3.delegatee, s_delegatee, "delegation3.delegatee");
        assertEq(delegation3.contract_, s_contract, "delegation3.contract_");
        assertEq(delegation3.tokenId, s_tokenIds[1], "delegation3.tokenId");
        assertEq(delegation3.privileges, s_privilegesArray[1], "delegation3.privileges");
        assertEq(delegation3.amount, 1, "delegation3.amount");
    }
}
