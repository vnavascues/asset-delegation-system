// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";

contract GetDelegateeDelegationKeys_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
    address private s_delegator;
    address private s_delegatee0;
    address private s_delegatee1;
    address private s_contract;
    bytes32[] private s_delegatee0delegationKeys;
    bytes32[] private s_delegatee1delegationKeys;

    function setUp() public virtual override {
        super.setUp();
        s_delegator = s_addr2;
        vm.label(s_delegator, "Delegator");
        s_delegatee0 = s_addr3;
        vm.label(s_delegatee0, "Delegatee 0");
        s_delegatee1 = s_addr4;
        vm.label(s_delegatee1, "Delegatee 1");
        s_contract = address(777);
        vm.label(s_contract, "Contract");

        // 1. delegator delegates two ERC721 to delegatee0
        uint256 tokenId0 = 1;
        bytes32 privileges0 = keccak256(abi.encode("mint"));
        vm.prank(s_delegator);
        bytes32 delegationKey0 = s_delegateRegistry.delegateERC721(s_delegatee0, s_contract, tokenId0, privileges0);
        s_delegatee0delegationKeys.push(delegationKey0);

        uint256 tokenId1 = 2;
        bytes32 privileges1 = keccak256(abi.encode("burn"));
        vm.prank(s_delegator);
        bytes32 delegationKey1 = s_delegateRegistry.delegateERC721(s_delegatee0, s_contract, tokenId1, privileges1);
        s_delegatee0delegationKeys.push(delegationKey1);

        // 2. delegator delegates an ERC721 and an ERC20 to delegatee1
        uint256 tokenId2 = 2;
        bytes32 privileges2 = keccak256(abi.encode("all"));
        vm.prank(s_delegator);
        bytes32 delegationKey2 = s_delegateRegistry.delegateERC721(s_delegatee1, s_contract, tokenId2, privileges2);
        s_delegatee1delegationKeys.push(delegationKey2);

        uint256 amount = 1616;
        vm.prank(s_delegator);
        bytes32 delegationKey3 = s_delegateRegistry.delegateERC20(s_delegatee1, s_contract, privileges2, amount);
        s_delegatee1delegationKeys.push(delegationKey3);
    }

    function test_WhenDelegationsDoNotExist() external {
        address delegatee = address(5);

        bytes32[] memory delegationKeys = s_delegateRegistry.getDelegateeDelegationKeys(delegatee);

        // it should return empty array
        assertEq(delegationKeys.length, 0);
    }

    function test_WhenDelegationsExist() external {
        bytes32[] memory delegationKeys = s_delegateRegistry.getDelegateeDelegationKeys(s_delegatee1);

        // it should return array of delegationKey
        assertEq(delegationKeys.length, 2);
        assertEq(delegationKeys[0], s_delegatee1delegationKeys[0]);
        assertEq(delegationKeys[1], s_delegatee1delegationKeys[1]);
    }
}
