// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";

contract GetDelegationKeyERC721_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
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

    function test_ShouldReturnDelegationKey() external {
        uint256 tokenId = 777;
        bytes32 privileges = keccak256(abi.encode("all"));

        bytes32 delegationKey =
            s_delegateRegistry.getDelegationKeyERC721(s_delegator, s_delegatee, s_contract, tokenId, privileges);

        // it should return delegationKey
        assertEq(delegationKey, 0x0198e337c1daa015fdde1330bb97362c0e063f28054bf790db7bb97091edd3f9);
    }
}
