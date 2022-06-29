// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "solmate/tokens/ERC20.sol";

import "../src/ERC20PermitEverywhere.sol";
import "./TestUni2Router.sol";

import "forge-std/Test.sol";

contract Uni2RouterForkedTest is Test {
    address TOKEN_WHALE = 0xBF72Da2Bd84c5170618Fbe5914B0ECA9638d5eb5;
    ERC20 WBTC = ERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    ERC20 WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20PermitEverywhere pe = new ERC20PermitEverywhere();
    IUniswapV2Router UNI_ROUTER = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    TestUni2Router router = new TestUni2Router(UNI_ROUTER, pe);
    bytes32 ownerKey;
    address owner;

    function setUp() onlyForked public {
        ownerKey = _randomBytes32();
        owner = vm.addr(uint256(ownerKey));
        uint256 bal = WBTC.balanceOf(TOKEN_WHALE);
        vm.prank(TOKEN_WHALE);
        WBTC.transfer(owner, bal);
        vm.prank(owner);
        WBTC.approve(address(pe), type(uint256).max);
    }

    modifier onlyForked() {
        if (block.number > 1e6) {
            _;
        }
    }

    function testFork_works() onlyForked public {
        address[] memory path = new address[](2);
        path[0] = address(WBTC);
        path[1] = address(WETH);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory signature
        ) = _createSignedPermit(
            WBTC,
            address(router),
            type(uint256).max,
            block.timestamp,
            pe.currentNonce(owner)
        );
        vm.prank(owner);
        (uint256[] memory amounts) = router.swapExactTokensForETH(
            1e8,
            0,
            path,
            payable(owner),
            block.timestamp,
            permit,
            signature
        );
        assertTrue(owner.balance == amounts[1]);
    }

    function _createSignedPermit(
        ERC20 token,
        address spender_,
        uint256 maxAmount,
        uint256 deadline,
        uint256 nonce
    )
        private
        returns (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory sig
        )
    {
        permit.token = address(token);
        permit.spender = spender_;
        permit.maxAmount = maxAmount;
        permit.deadline = deadline;
        bytes32 h = pe.hashPermit(permit, nonce);
        (sig.v, sig.r, sig.s) = vm.sign(uint256(ownerKey), h);
    }

    function _randomBytes32()
        private
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(gasleft(), address(this), block.timestamp));
    }

    function _randomAddress()
        private
        view
        returns (address payable a)
    {
        return payable(address(uint160(uint256(_randomBytes32()))));
    }
}
