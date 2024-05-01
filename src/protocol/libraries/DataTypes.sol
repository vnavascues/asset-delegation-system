// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

enum DelegationType {
    NONE,
    ERC20,
    ERC721
}

struct Delegation {
    DelegationType delegationType;
    address delegator;
    address delegatee;
    address contract_;
    uint256 tokenId;
    bytes32 privileges;
    uint256 amount;
}
