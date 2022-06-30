// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

/// @title IERC20PermitEverywhere
/// @notice Interface for enabling permit-style approvals for all ERC20 tokens,
/// regardless of whether they implement EIP2612 or not.
interface IERC20PermitEverywhere {
    struct PermitTransferFrom {
        address token;
        address spender;
        uint256 maxAmount;
        uint256 deadline;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
  
    function executePermitTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external;
}
