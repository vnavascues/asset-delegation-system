// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { DelegateRegistry_Unit_Concrete_Test } from "./DelegateRegistry.t.sol";

contract GetDelegatedERC20_Unit_Concrete_Test is DelegateRegistry_Unit_Concrete_Test {
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

        // 1. delegate an ERC20
        s_privileges = keccak256(abi.encode("all"));
        s_amount = 1616;
        vm.prank(s_delegator);
        s_delegationKey = s_delegateRegistry.delegateERC20(s_delegatee, s_contract, s_privileges, s_amount);
    }

    function test_WhenDelegationDoesNotExist() external {
        address contract_ = address(888);

        uint256 amount = s_delegateRegistry.getDelegatedERC20(s_delegator, s_delegatee, contract_, s_privileges);

        // it should return zero delegated amount
        assertEq(amount, 0);
    }

    function test_WhenDelegationExists() external {
        uint256 amount = s_delegateRegistry.getDelegatedERC20(s_delegator, s_delegatee, s_contract, s_privileges);

        // it should return one delegated amount
        assertEq(amount, s_amount);
    }
}
