// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { DelegateRegistry } from "src/protocol/registry/DelegateRegistry.sol";

contract GetDelegationKey_Unit_Fuzz_Test is PRBTest, StdCheats {
    DelegateRegistry internal s_delegateRegistry;

    address internal s_deployer;

    function setUp() public virtual {
        s_deployer = vm.addr(1);
        vm.label(s_deployer, "Address 1 (Deployer)");
        s_delegateRegistry = new DelegateRegistry();
    }

    function testFuzz_getDelegationKeyERC20_hashCollisions_0(
        address delegator0,
        address delegator1,
        address delegatee0,
        address delegatee1,
        address contract0,
        address contract1,
        bytes32 privileges0,
        bytes32 privileges1
    )
        external
    {
        vm.assume(delegator0 != delegator1);

        bytes32 delegationKey0 =
            s_delegateRegistry.getDelegationKeyERC20(delegator0, delegatee0, contract0, privileges0);
        bytes32 delegationKey1 =
            s_delegateRegistry.getDelegationKeyERC20(delegator1, delegatee1, contract1, privileges1);

        assertTrue(delegationKey0 != delegationKey1);
    }

    function testFuzz_getDelegationKeyERC721_hashCollisions_0(
        address delegator0,
        address delegator1,
        address delegatee0,
        address delegatee1,
        address contract0,
        address contract1,
        uint256 tokenId0,
        uint256 tokenId1,
        bytes32 privileges0,
        bytes32 privileges1
    )
        external
    {
        vm.assume(delegator0 != delegator1);

        bytes32 delegationKey0 =
            s_delegateRegistry.getDelegationKeyERC721(delegator0, delegatee0, contract0, tokenId0, privileges0);
        bytes32 delegationKey1 =
            s_delegateRegistry.getDelegationKeyERC721(delegator1, delegatee1, contract1, tokenId1, privileges1);

        assertTrue(delegationKey0 != delegationKey1);
    }

    function testFuzz_getDelegationKey_hashCollisions_0(
        address delegator0,
        address delegator1,
        address delegatee0,
        address delegatee1,
        address contract0,
        address contract1,
        uint256 tokenId0,
        uint256 tokenId1,
        bytes32 privileges0,
        bytes32 privileges1
    )
        external
    {
        vm.assume(delegator0 != delegator1);

        bytes32[] memory delegationKeys = new bytes32[](4);
        delegationKeys[0] = s_delegateRegistry.getDelegationKeyERC20(delegator0, delegatee0, contract0, privileges0);
        delegationKeys[1] = s_delegateRegistry.getDelegationKeyERC20(delegator1, delegatee1, contract1, privileges1);
        delegationKeys[2] =
            s_delegateRegistry.getDelegationKeyERC721(delegator0, delegatee0, contract0, tokenId0, privileges0);
        delegationKeys[3] =
            s_delegateRegistry.getDelegationKeyERC721(delegator1, delegatee1, contract1, tokenId1, privileges1);

        for (uint256 i = 0; i < delegationKeys.length; i++) {
            for (uint256 j = 0; j < delegationKeys.length; j++) {
                if (j != i) assertTrue(delegationKeys[i] != delegationKeys[j]);
                else assertEq(delegationKeys[i], delegationKeys[j]);
            }
        }
    }
}
