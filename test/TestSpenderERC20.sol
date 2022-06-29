// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "solmate/tokens/ERC20.sol";

import "../src/ERC20PermitEverywhere.sol";

contract TestSpenderERC20 {
    ERC20PermitEverywhere public immutable PERMIT_EVERYWHERE;

    constructor(ERC20PermitEverywhere pe) {
        PERMIT_EVERYWHERE = pe;
    }

    function spend(
        ERC20 token,
        address to,
        uint256 amount,
        ERC20PermitEverywhere.PermitTransferFrom memory permit,
        ERC20PermitEverywhere.Signature memory permitSig
    )
        external
    {
        require(permit.token == address(token), 'WRONG_TOKEN');
        PERMIT_EVERYWHERE.executePermitTransferFrom(
            msg.sender,
            to,
            amount,
            permit,
            permitSig
        );
    }
}
