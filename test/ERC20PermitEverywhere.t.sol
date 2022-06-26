// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";

import "forge-std/Test.sol";
import "./DummyERC20.sol";
import "./TestSpenderERC20.sol";

contract ERC20PermitEverywhereTest is Test {
    DummyERC20 dummyToken = new DummyERC20();
    NonstandardDummyERC20 nsDummyToken = new NonstandardDummyERC20();
    ERC20PermitEverywhere testContract = new ERC20PermitEverywhere();
    TestSpenderERC20 spender = new TestSpenderERC20(testContract);
    bytes32 ownerKey;
    address owner;

    function setUp() public {
        ownerKey = _randomBytes32();
        owner = vm.addr(uint256(ownerKey));
    }

    function test_works() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(dummyToken)),
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        assertEq(dummyToken.balanceOf(receiver), 0.5e18);
    }

    function test_worksWithNonstandardERC20() public {
        address receiver = _randomAddress();
        nsDummyToken.mint(owner, 1e18);
        vm.prank(owner);
        nsDummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(nsDummyToken)),
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            IERC20(address(nsDummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        assertEq(nsDummyToken.balanceOf(receiver), 0.5e18);
    }

    function test_cannotSpendMoreThanPermit() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(dummyToken)),
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('EXCEEDS_PERMIT_AMOUNT');
        vm.prank(owner);
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18 + 1,
            permit,
            permitSig
        );
    }

    function test_cannotSpendWrongSpender() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(dummyToken)),
            address(_randomAddress()),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('SPENDER_NOT_PERMITTED');
        vm.prank(owner);
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
    }

    function test_cannotSpendWrongOwner() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(dummyToken)),
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('INVALID_SIGNER');
        vm.prank(_randomAddress());
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
    }

    function test_cannotExecuteTwice() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            IERC20(address(dummyToken)),
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        vm.expectRevert('INVALID_SIGNER');
        vm.prank(owner);
        spender.spend(
            IERC20(address(dummyToken)),
            receiver,
            0.5e18,
            permit,
            permitSig
        );
    }

    function _createSignedPermit(
        IERC20 token,
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
        permit.token = token;
        permit.spender = spender_;
        permit.maxAmount = maxAmount;
        permit.deadline = deadline;
        bytes32 h = testContract.hashPermit(permit, nonce);
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
