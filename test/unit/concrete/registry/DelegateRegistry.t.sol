// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { DelegateRegistry } from "src/protocol/registry/DelegateRegistry.sol";

contract DelegateRegistry_Unit_Concrete_Test is PRBTest, StdCheats {
    DelegateRegistry internal s_delegateRegistry;

    address internal s_deployer;
    address internal s_addr2;
    address internal s_addr3;
    address internal s_addr4;

    function setUp() public virtual {
        s_deployer = vm.addr(1);
        vm.label(s_deployer, "Address 1 (Deployer)");
        s_addr2 = vm.addr(2);
        vm.label(s_addr2, "Address 2");
        s_addr3 = vm.addr(3);
        vm.label(s_addr3, "Address 3");
        s_addr4 = vm.addr(4);
        vm.label(s_addr4, "Address 4");

        vm.prank(s_deployer);
        s_delegateRegistry = new DelegateRegistry();
    }
}
