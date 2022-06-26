// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC721PermitEverywhere.sol";

import "./TestUtils.sol";
import "./DummyERC721.sol";
import "./TestSpenderERC721.sol";

contract ERC721PermitEverywhereTest is TestUtils {
    event ERC721ReceiverReceived(bytes data);

    DummyERC721 dummyToken = new DummyERC721();
    ERC721PermitEverywhere testContract = new ERC721PermitEverywhere();
    TestSpenderERC721 spender = new TestSpenderERC721(testContract);
    bytes32 ownerKey;
    address owner;

    function setUp() public {
        ownerKey = _randomBytes32();
        owner = vm.addr(uint256(ownerKey));
    }

    function test_transferFromWorks() public {
        address receiver = _randomAddress();
        uint256 tokenId = dummyToken.mint(owner);
        vm.prank(owner);
        dummyToken.setApprovalForAll(address(testContract), true);
        (
            ERC721PermitEverywhere.PermitTransferFrom memory permit,
            ERC721PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            dummyToken.asIERC721(),
            address(spender),
            tokenId,
            false,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.prank(owner);
        spender.spend(
            dummyToken.asIERC721(),
            receiver,
            tokenId,
            permit,
            permitSig
        );
        assertEq(dummyToken.ownerOf(tokenId), receiver);
    }

    function test_safeTransferFromWorks() public {
        address receiver = address(new ERC721Receiver());
        uint256 tokenId = dummyToken.mint(owner);
        vm.prank(owner);
        dummyToken.setApprovalForAll(address(testContract), true);
        (
            ERC721PermitEverywhere.PermitTransferFrom memory permit,
            ERC721PermitEverywhere.Signature memory permitSig
        ) = _createSignedPermit(
            dummyToken.asIERC721(),
            address(spender),
            tokenId,
            false,
            block.timestamp,
            testContract.currentNonce(owner)
        );
        vm.expectEmit(false, false, false, true);
        emit ERC721ReceiverReceived(bytes('ayyyy'));
        vm.prank(owner);
        spender.spendSafe(
            dummyToken.asIERC721(),
            receiver,
            tokenId,
            permit,
            permitSig
        );
        assertEq(dummyToken.ownerOf(tokenId), receiver);
    }
    //
    // function test_worksWithNonstandardERC20() public {
    //     address receiver = _randomAddress();
    //     nsDummyToken.mint(owner, 1e18);
    //     vm.prank(owner);
    //     nsDummyToken.approve(address(testContract), type(uint256).max);
    //     (
    //         ERC721PermitEverywhere.PermitTransferFrom memory permit,
    //         ERC721PermitEverywhere.Signature memory permitSig
    //     ) = _createSignedPermit(
    //         IERC20(address(nsDummyToken)),
    //         address(spender),
    //         0.5e18,
    //         block.timestamp,
    //         testContract.currentNonce(owner)
    //     );
    //     vm.prank(owner);
    //     spender.spend(
    //         IERC20(address(nsDummyToken)),
    //         receiver,
    //         0.5e18,
    //         permit,
    //         permitSig
    //     );
    //     assertEq(nsDummyToken.balanceOf(receiver), 0.5e18);
    // }
    //
    // function test_cannotSpendMoreThanPermit() public {
    //     address receiver = _randomAddress();
    //     dummyToken.mint(owner, 1e18);
    //     vm.prank(owner);
    //     dummyToken.approve(address(testContract), type(uint256).max);
    //     (
    //         ERC721PermitEverywhere.PermitTransferFrom memory permit,
    //         ERC721PermitEverywhere.Signature memory permitSig
    //     ) = _createSignedPermit(
    //         dummyToken.asIERC721(),
    //         address(spender),
    //         0.5e18,
    //         block.timestamp,
    //         testContract.currentNonce(owner)
    //     );
    //     vm.expectRevert('EXCEEDS_PERMIT_AMOUNT');
    //     vm.prank(owner);
    //     spender.spend(
    //         dummyToken.asIERC721(),
    //         receiver,
    //         0.5e18 + 1,
    //         permit,
    //         permitSig
    //     );
    // }
    //
    // function test_cannotSpendWrongSpender() public {
    //     address receiver = _randomAddress();
    //     dummyToken.mint(owner, 1e18);
    //     vm.prank(owner);
    //     dummyToken.approve(address(testContract), type(uint256).max);
    //     (
    //         ERC721PermitEverywhere.PermitTransferFrom memory permit,
    //         ERC721PermitEverywhere.Signature memory permitSig
    //     ) = _createSignedPermit(
    //         dummyToken.asIERC721(),
    //         address(_randomAddress()),
    //         0.5e18,
    //         block.timestamp,
    //         testContract.currentNonce(owner)
    //     );
    //     vm.expectRevert('SPENDER_NOT_PERMITTED');
    //     vm.prank(owner);
    //     spender.spend(
    //         dummyToken.asIERC721(),
    //         receiver,
    //         0.5e18,
    //         permit,
    //         permitSig
    //     );
    // }
    //
    // function test_cannotSpendWrongOwner() public {
    //     address receiver = _randomAddress();
    //     dummyToken.mint(owner, 1e18);
    //     vm.prank(owner);
    //     dummyToken.approve(address(testContract), type(uint256).max);
    //     (
    //         ERC721PermitEverywhere.PermitTransferFrom memory permit,
    //         ERC721PermitEverywhere.Signature memory permitSig
    //     ) = _createSignedPermit(
    //         dummyToken.asIERC721(),
    //         address(spender),
    //         0.5e18,
    //         block.timestamp,
    //         testContract.currentNonce(owner)
    //     );
    //     vm.expectRevert('INVALID_SIGNER');
    //     vm.prank(_randomAddress());
    //     spender.spend(
    //         dummyToken.asIERC721(),
    //         receiver,
    //         0.5e18,
    //         permit,
    //         permitSig
    //     );
    // }
    //
    // function test_cannotExecuteTwice() public {
    //     address receiver = _randomAddress();
    //     dummyToken.mint(owner, 1e18);
    //     vm.prank(owner);
    //     dummyToken.approve(address(testContract), type(uint256).max);
    //     (
    //         ERC721PermitEverywhere.PermitTransferFrom memory permit,
    //         ERC721PermitEverywhere.Signature memory permitSig
    //     ) = _createSignedPermit(
    //         dummyToken.asIERC721(),
    //         address(spender),
    //         0.5e18,
    //         block.timestamp,
    //         testContract.currentNonce(owner)
    //     );
    //     vm.prank(owner);
    //     spender.spend(
    //         dummyToken.asIERC721(),
    //         receiver,
    //         0.5e18,
    //         permit,
    //         permitSig
    //     );
    //     vm.expectRevert('INVALID_SIGNER');
    //     vm.prank(owner);
    //     spender.spend(
    //         dummyToken.asIERC721(),
    //         receiver,
    //         0.5e18,
    //         permit,
    //         permitSig
    //     );
    // }

    function _createSignedPermit(
        IERC721 token,
        address spender_,
        uint256 tokenId,
        bool allowAnyTokenId,
        uint256 deadline,
        uint256 nonce
    )
        private
        returns (
            ERC721PermitEverywhere.PermitTransferFrom memory permit,
            ERC721PermitEverywhere.Signature memory sig
        )
    {
        permit.token = token;
        permit.spender = spender_;
        permit.allowAnyTokenId = allowAnyTokenId;
        permit.tokenId = tokenId;
        permit.deadline = deadline;
        bytes32 h = testContract.hashPermit(permit, nonce);
        (sig.v, sig.r, sig.s) = vm.sign(uint256(ownerKey), h);
    }
}

contract ERC721Receiver {
    event ERC721ReceiverReceived(bytes data);

    function onERC721Received(address, address, uint256, bytes memory data)
        external
        returns (bytes4)
    {
        emit ERC721ReceiverReceived(data);
        return this.onERC721Received.selector;
    }
}
