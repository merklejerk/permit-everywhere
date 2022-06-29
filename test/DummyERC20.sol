// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";
import "solmate/tokens/ERC20.sol";

contract DummyERC20 is ERC20 {
    bool internal succeeds = true;

    constructor() ERC20('DUMMY', 'DUM', 18) {}

    function setSucceeds(bool s) external {
        succeeds = s;
    }

    function mint(address owner, uint256 amount)
        external
    {
        _mint(owner, amount);
    }

    function transferFrom(address owner, address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        super.transferFrom(owner, to, amount);
        if (!succeeds) {
            revert('yikes');
        }
        return true;
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

contract Nonstandard2DummyERC20 is DummyERC20 {
    function transferFrom(address owner, address to, uint256 amount)
       public
       virtual
       override
       returns (bool)
   {
       ERC20.transferFrom(owner, to, amount);
       return succeeds;
  }
}
