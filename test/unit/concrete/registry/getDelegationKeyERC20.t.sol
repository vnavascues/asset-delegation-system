// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";

contract GetDelegationKeyERC20_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
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
        bytes32 privileges = keccak256(abi.encode("all"));

        bytes32 delegationKey =
            s_delegateRegistry.getDelegationKeyERC20(s_delegator, s_delegatee, s_contract, privileges);

        // it should return delegationKey
        assertEq(delegationKey, 0xb552a0a87207012d117353876842bcf6daa414601336f3d3a41b38a80f3c2d64);
    }
}
