// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;


import "forge-std/Test.sol";

contract TestUtils is Test {
    function _randomBytes32()
        internal
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(gasleft(), address(this), block.timestamp));
    }

    function _randomAddress()
        internal
        view
        returns (address payable a)
    {
        return payable(address(uint160(uint256(_randomBytes32()))));
    }

}
