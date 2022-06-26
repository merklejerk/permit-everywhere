# PermitEverywhere
PermitEverywhere is a set of contracts that enable permit style approvals for all ERC20 and ERC721 tokens, regardless of whether they implement EIP2612 or not.

Users simply need set an allowance on the `ERC20PermitEverywhere` contract (for ERC20 assets) or the `ERC721PermitEverywhere` contract (for ERC721 assets). Afterwards, protocols can accept a signed permit message from the user, which they can pass into a PermitEverywhere contract to securely transfer funds without an explicit allowance set on their own contracts.

## Addresses
- `ERC20PermitEverywhere` is deployed at `0xE20eD896FB1abd07D3B1a16aD9Ecf7D26B6a7f6d` on Polygon, Optimism, and Ethereum (in a bit).
- `ERC721PermitEverywhere` is deployed at `0xE721A26F16C0e90EBe92Da92F8687f89c3168552` on Polygon, Optimism, and Ethereum (in a bit).

## Permit Messages
Permit messages are implemented EIP712 so they can be signed in a human readable fashion through popular web3 wallets.

### ERC20PermitEverywhere Permit Spec

The `EIP712Domain` fields for `ERC20PermitEverywhere` messages are as follows:
```solidity
    EIP712Domain({
        name: 'ERC20PermitEverywhere',
        version: '1.0.0',
        chainId: TARGET_CHAIN_ID,
        verifyingContract: 0xA1120d72519d9b84Be621f33A390D2ef2C9DBDE9
    })
```

The permit message itself is defined as:
```solidity
struct PermitTransferFrom {
    // The token to transfer.
    address token;
    // Who can execute this permit.
    address spender;
    // Maximum amount of tokens to move.
    uint256 maxAmount;
    // Timestamp after which this permit is no longer valid.
    uint256 deadline;
    // The nonce for the signer of this permit.
    // The current nonce can be retrieved through ERC20PermitEverywhere.currentNonce().
    uint256 nonce;
}
```

### ERC721PermitEverywhere Permit Spec

The `EIP712Domain` fields for `ERC20PermitEverywhere` messages are as follows:
```solidity
    EIP712Domain({
        name: 'ERC721PermitEverywhere',
        version: '1.0.0',
        chainId: TARGET_CHAIN_ID,
        verifyingContract: 0xa11721AF97db14F1c45db155e13b5a6824EE46DA
    })
```

The permit message itself is defined as:
```solidity
struct PermitTransferFrom {
    // The token to transfer.
    address token;
    // Who can execute this permit.
    address spender;
    // The NFT token ID that can be moved. Ignored if allowAnyTokenId is true.
    uint256 tokenId;
    // If true, any token ID can be moved by spender.
    bool allowAnyTokenId;
    // Timestamp after which this permit is no longer valid.
    uint256 deadline;
    // The nonce for the signer of this permit.
    // The current nonce can be retrieved through ERC721PermitEverywhere.currentNonce().
    uint256 nonce;
}
```

## Executing Permit Messages

For ERC20 permits, protocols can burn a user's permit message and execute an eligible transfer by calling `ERC20PermitEverywhere.executePermitTransferFrom()`, which is declared as follows:

```solidity
    function executePermitTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        PermitTransferFrom memory permit,
        Signature memory sig
    )
        external;
```

For ERC721 permits, protocols can burn a user's permit message and execute an eligible transfer by calling either `ERC721PermitEverywhere.executePermitTransferFrom()` or `ERC721PermitEverywhere.executePermitSafeTransferFrom()`, which are declared as follows:

```solidity
    function executePermitSafeTransferFrom(
        address owner,
        address to,
        uint256 tokenId,
        bytes memory data,
        PermitTransferFrom memory permit,
        Signature memory sig
    )
        external;
```
