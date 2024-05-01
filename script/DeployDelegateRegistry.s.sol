// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { DelegateRegistry } from "src/protocol/registry/DelegateRegistry.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployDelegateRegistry is BaseScript {
    function run() public broadcast returns (DelegateRegistry) {
        bytes32 salt = vm.envBytes32("SALT_DEPLOY_DELEGATE_REGISTRY");

        DelegateRegistry delegateRegistry = new DelegateRegistry{ salt: salt }();

        return delegateRegistry;
    }
}
