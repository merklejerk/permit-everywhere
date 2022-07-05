// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

/// @title IERC721PermitEverywhere
/// @notice Interface for enabling permit-style approvals for all ERC721 tokens,
/// regardless of whether they implement EIP4494 or not.
interface IERC721PermitEverywhere {
    struct PermitTransferFrom {
        address token;
        address spender;
        uint256 tokenId;
        bool allowAnyTokenId;
        uint256 deadline;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
  
    function executePermitSafeTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        bytes calldata data,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external;
}
