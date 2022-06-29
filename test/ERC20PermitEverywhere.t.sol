// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";

import "forge-std/Test.sol";
import "./DummyERC20.sol";
import "./TestSpenderERC20.sol";

contract ERC20PermitEverywhereTest is Test {
    DummyERC20 dummyToken = new DummyERC20();
    NonstandardDummyERC20 nsDummyToken = new NonstandardDummyERC20();
    Nonstandard2DummyERC20 nsDummyToken2 = new Nonstandard2DummyERC20();
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
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            dummyToken,
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
            nsDummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            nsDummyToken,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        assertEq(nsDummyToken.balanceOf(receiver), 0.5e18);
    }

    function test_worksWithNonstandard2ERC20() public {
        address receiver = _randomAddress();
        nsDummyToken2.mint(owner, 1e18);
        vm.prank(owner);
        nsDummyToken2.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            nsDummyToken2,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            nsDummyToken2,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        assertEq(nsDummyToken2.balanceOf(receiver), 0.5e18);
    }

    function test_worksERC20Reverting() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        dummyToken.setSucceeds(false);
        vm.expectRevert('yikes');
        vm.prank(owner);
        spender.spend(
            dummyToken,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
    }

    function test_worksWithNonstandard2ERC20_returningFalse() public {
        address receiver = _randomAddress();
        nsDummyToken2.mint(owner, 1e18);
        vm.prank(owner);
        nsDummyToken2.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            nsDummyToken2,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        nsDummyToken2.setSucceeds(false);
        vm.expectRevert('ERC20_TRANSFER_FROM_FAILED');
        vm.prank(owner);
        spender.spend(
            nsDummyToken2,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
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
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('EXCEEDS_PERMIT_AMOUNT');
        vm.prank(owner);
        spender.spend(
            dummyToken,
            receiver,
            0.5e18 + 1,
            permit,
            permitSig
        );
    }

    function test_cannotSpendExpired() public {
        address receiver = _randomAddress();
        dummyToken.mint(owner, 1e18);
        vm.prank(owner);
        dummyToken.approve(address(testContract), type(uint256).max);
        (
            ERC20PermitEverywhere.PermitTransferFrom memory permit,
            ERC20PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        skip(1);
        vm.expectRevert('PERMIT_EXPIRED');
        vm.prank(owner);
        spender.spend(
            dummyToken,
            receiver,
            0.5e18,
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
            dummyToken,
            address(_randomAddress()),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('SPENDER_NOT_PERMITTED');
        vm.prank(owner);
        spender.spend(
            dummyToken,
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
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectRevert('INVALID_SIGNER');
        vm.prank(_randomAddress());
        spender.spend(
            dummyToken,
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
            dummyToken,
            address(spender),
            0.5e18,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            dummyToken,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
        vm.expectRevert('INVALID_SIGNER');
        vm.prank(owner);
        spender.spend(
            dummyToken,
            receiver,
            0.5e18,
            permit,
            permitSig
        );
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
