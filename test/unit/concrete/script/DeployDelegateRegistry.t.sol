// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { DelegateRegistry } from "src/protocol/registry/DelegateRegistry.sol";
import { DeployDelegateRegistry } from "script/DeployDelegateRegistry.s.sol";

contract DeployDelegateRegistry_Unit_Concrete_Test is PRBTest, StdCheats {
    DeployDelegateRegistry internal s_deployDelegateRegistry;

    address internal s_deployer;

    function setUp() public virtual {
        s_deployer = vm.addr(1);
        vm.label(s_deployer, "Address 1 (Deployer)");

        vm.prank(s_deployer);
        s_deployDelegateRegistry = new DeployDelegateRegistry();
    }

    function test_WhenDelegateRegistryDoesNotExist() external {
        vm.setEnv("ETH_FROM", "0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf");
        vm.setEnv("SALT_DEPLOY_DELEGATE_REGISTRY", "0x72616e646f6d5f73616c74000000000000000000000000000000000000000000");

        DelegateRegistry delegateRegistry = s_deployDelegateRegistry.run();
        address delegeteRegistryAddr = address(delegateRegistry);

        // it should deploy
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(delegeteRegistryAddr)
        }
        assertTrue(codeSize > 0);

        // it should return address
        assertTrue(delegeteRegistryAddr != address(0));
    }

    function test_RevertWhen_DelegateRegistryExists() external {
        vm.setEnv("ETH_FROM", "0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf");
        vm.setEnv("SALT_DEPLOY_DELEGATE_REGISTRY", "0x72616e646f6d5f73616c74000000000000000000000000000000000000000000");

        s_deployDelegateRegistry.run();

        // it should revert
        vm.expectRevert();
        s_deployDelegateRegistry.run();
    }
}
