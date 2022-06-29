// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ERC20PermitEverywhere.sol";
import "../test/TestUni2Router.sol";

contract ContractScript is Script {
    IUniswapV2Router constant UNI_ROUTER =
        IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        ERC20PermitEverywhere pe = new ERC20PermitEverywhere();
        console.log('ERC20PermitEverywhere', address(pe));
        TestUni2Router router = new TestUni2Router(UNI_ROUTER, pe);
        console.log('TestUni2Router', address(router));
    }
}
