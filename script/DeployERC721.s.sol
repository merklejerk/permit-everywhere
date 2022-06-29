// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ERC721PermitEverywhere.sol";

contract ContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        ERC721PermitEverywhere pe = new ERC721PermitEverywhere();
        console.log('ERC721PermitEverywhere', address(pe));
    }
}
