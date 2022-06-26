// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";

contract TestSpender {
    ERC20PermitEverywhere public immutable PERMIT_EVERYWHERE;

    constructor(ERC20PermitEverywhere pe) {
        PERMIT_EVERYWHERE = pe;
    }

    function spend(
        IERC20 token,
        address to,
        uint256 amount,
        ERC20PermitEverywhere.PermitTransferFrom memory permit,
        ERC20PermitEverywhere.Signature memory permitSig
    )
        external
    {
        require(permit.token == token, 'WRONG_TOKEN');
        PERMIT_EVERYWHERE.executePermitTransferFrom(
            msg.sender,
            to,
            amount,
            permit,
            permitSig
        );
    }
}
