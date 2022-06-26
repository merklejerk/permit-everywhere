// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.15;

/// @title ERC20PermitEverywhere
/// @notice Enables permit-style approvals for all ERC20 tokens, 
/// regardless of whether they implement EIP2612 or not.
contract ERC20PermitEverywhere {
    bytes32 private immutable DOMAIN_SEPARATOR;
    bytes32 private immutable TRANSFER_PERMIT_TYPEHASH;

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

    /// @dev Owner -> current nonce.
    mapping(address => uint256) public currentNonce;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
            keccak256(bytes('ERC20PermitEverywhere')),
            keccak256('1.0.0'),
            block.chainid,
            address(this)
        ));

        TRANSFER_PERMIT_TYPEHASH =
            keccak256('PermitTransferFrom(address token,address spender,uint256 maxAmount,uint256 deadline,uint256 nonce)');
    }

    function executePermitTransferFrom(
        address from,
        address to,
        uint256 amount,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external
    {
        require(msg.sender == permit.spender, 'SPENDER_NOT_PERMITTED');
        require(permit.deadline >= block.timestamp, 'PERMIT_EXPIRED');
        require(permit.maxAmount >= amount, 'EXCEEDS_PERMIT_AMOUNT');

        // Unchecked because the only math done is incrementing
        // the nonce which cannot realistically overflow.
        unchecked {
            require(from == getSigner(hashPermit(permit, currentNonce[from]++), sig), 'INVALID_SIGNER');
        }

        _transferFrom(permit.token, from, to, amount);
    }

    function hashPermit(PermitTransferFrom calldata permit, uint256 nonce)
        public
        view
        returns (bytes32 h)
    {
        bytes32 dh = DOMAIN_SEPARATOR;
        bytes32 th = TRANSFER_PERMIT_TYPEHASH;
        assembly {
            if lt(permit, 0x20)  {
                invalid()
            }
            let c1 := mload(sub(permit, 0x20))
            let c2 := mload(add(permit, 0x80))
            mstore(sub(permit, 0x20), th)
            mstore(add(permit, 0x80), nonce)
            let ph := keccak256(sub(permit, 0x20), 0xC0)
            mstore(sub(permit, 0x20), c1)
            mstore(add(permit, 0x80), c2)
            let p:= mload(0x40)
            mstore(p, 0x1901000000000000000000000000000000000000000000000000000000000000)
            mstore(add(p, 0x02), dh)
            mstore(add(p, 0x22), ph)
            h := keccak256(p, 0x42)
        }
    }

    function getSigner(bytes32 hash, Signature calldata sig) private pure returns (address signer) {
        signer = ecrecover(hash, sig.v, sig.r, sig.s);
        require(signer != address(0), 'INVALID_SIGNATURE');
    }

    function _transferFrom(address token, address from, address to, uint256 amount) private {
        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0x00, 0x23b872dd)
            mstore(0x20, from) // Append the "from" argument.
            mstore(0x40, to) // Append the "to" argument.
            mstore(0x60, amount) // Append the "amount" argument.

            if iszero(
                and(
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    // We use 0x64 because that's the total length of our calldata (0x04 + 0x20 * 3)
                    // Counterintuitively, this call() must be positioned after the or() in the
                    // surrounding and() because and() evaluates its arguments from right to left.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, hex"08c379a0") // Function selector of the error method.
                mstore(0x04, 0x20) // Offset of the error string.
                mstore(0x24, 20) // Length of the error string.
                mstore(0x44, "TRANSFER_FROM_FAILED") // The error string.
                revert(0x00, 0x64) // Revert with (offset, size).
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }
    }
}
