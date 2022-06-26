// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";
import "solmate/tokens/ERC20.sol";

contract DummyERC20 is ERC20 {
    constructor() ERC20('DUMMY', 'DUM', 18) {}

    function mint(address owner, uint256 amount)
        external
    {
        _mint(owner, amount);
    }
}

contract NonstandardDummyERC20 is DummyERC20 {
    function transferFrom(address owner, address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        super.transferFrom(owner, to, amount);
        assembly { return(0, 0) }
    }
}
