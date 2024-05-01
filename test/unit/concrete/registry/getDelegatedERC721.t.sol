// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";

contract GetDelegatedERC721_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
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
        uint256 tokenId = s_tokenId + 1;

        uint256 amount =
            s_delegateRegistry.getDelegatedERC721(s_delegator, s_delegatee, s_contract, tokenId, s_privileges);

        // it should return zero delegated amount
        assertEq(amount, 0);
    }

    function test_WhenDelegationExists() external {
        uint256 amount =
            s_delegateRegistry.getDelegatedERC721(s_delegator, s_delegatee, s_contract, s_tokenId, s_privileges);

        // it should return one delegated amount
        assertEq(amount, 1);
    }
}
