# PermitEverywhere
PermitEverywhere is a set of contracts that enable permit style approvals for all ERC20 and ERC721 tokens, regardless of whether they implement EIP2612 or not.

Users simply need set an allowance on the `ERC20PermitEverywhere` contract (for ERC20 assets) or the `ERC721PermitEverywhere` contract (for ERC721 assets). Afterwards, protocols can accept a signed permit message from the user, which they can pass into a PermitEverywhere contract to securely transfer funds without an explicit allowance set on their own contracts.

## Addresses
- `ERC20PermitEverywhere` is deployed at `0xeee20efDe3b7222561CB29b03aa62d3f1368fba2` on Ethereum, Polygon, Optimism, Arbitrum, Rinkeby, and Ropsten.
- `ERC721PermitEverywhere` is deployed at `0xEEe721c6f50d0223D4c19CA30Cf9F448E5B17426` on Ethereum, Polygon, Optimism, Arbitrum, Rinkeby, and Ropsten.
- (ERC1155 coming soon).

## Permit Messages
Permit messages are implemented EIP712 so they can be signed in a human readable fashion through popular web3 wallets.

### ERC20PermitEverywhere Permit Spec

The `EIP712Domain` fields for `ERC20PermitEverywhere` messages are as follows:
```solidity
    EIP712Domain({
        name: 'ERC20PermitEverywhere',
        version: '1.0.0',
        chainId: TARGET_CHAIN_ID,
        verifyingContract: 0xeee20efDe3b7222561CB29b03aa62d3f1368fba2
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
}
```

### ERC721PermitEverywhere Permit Spec

The `EIP712Domain` fields for `ERC20PermitEverywhere` messages are as follows:
```solidity
    EIP712Domain({
        name: 'ERC721PermitEverywhere',
        version: '1.0.0',
        chainId: TARGET_CHAIN_ID,
        verifyingContract: 0xEEe721c6f50d0223D4c19CA30Cf9F448E5B17426
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
}
```

## Executing Permit Messages

For ERC20 permits, protocols can burn a user's permit message and execute an eligible transfer by calling `ERC20PermitEverywhere.executePermitTransferFrom()`, which is declared as follows:

```solidity
    function executePermitTransferFrom(
        address from,
        address to,
        uint256 amount,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external;
```

For ERC721 permits, protocols can burn a user's permit message and execute an eligible transfer by calling either `ERC721PermitEverywhere.executePermitTransferFrom()` or `ERC721PermitEverywhere.executePermitSafeTransferFrom()`, which are declared as follows:

```solidity
    function executePermitTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external
```

```solidity
    function executePermitSafeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data,
        PermitTransferFrom calldata permit,
        Signature calldata sig
    )
        external;
```
