// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ERC20PermitEverywhere.sol";

contract ContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        ERC20PermitEverywhere pe = new ERC20PermitEverywhere();
        console.log('ERC20PermitEverywhere', address(pe));
    }
}
