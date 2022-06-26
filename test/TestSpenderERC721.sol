// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC721PermitEverywhere.sol";

contract TestSpenderERC721 {
    ERC721PermitEverywhere public immutable PERMIT_EVERYWHERE;

    constructor(ERC721PermitEverywhere pe) {
        PERMIT_EVERYWHERE = pe;
    }

    function spend(
        IERC721 token,
        address to,
        uint256 tokenId,
        ERC721PermitEverywhere.PermitTransferFrom memory permit,
        ERC721PermitEverywhere.Signature memory permitSig
    )
        external
    {
        require(permit.token == token && permit.tokenId == tokenId, 'WRONG_TOKEN');
        PERMIT_EVERYWHERE.executePermitTransferFrom(
            msg.sender,
            to,
            tokenId,
            permit,
            permitSig
        );
    }

    function spendSafe(
        IERC721 token,
        address to,
        uint256 tokenId,
        ERC721PermitEverywhere.PermitTransferFrom memory permit,
        ERC721PermitEverywhere.Signature memory permitSig
    )
        external
    {
        require(permit.token == token && permit.tokenId == tokenId, 'WRONG_TOKEN');
        PERMIT_EVERYWHERE.executePermitSafeTransferFrom(
            msg.sender,
            to,
            tokenId,
            bytes("ayyyy"),
            permit,
            permitSig
        );
    }
}
