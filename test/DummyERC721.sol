// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC721PermitEverywhere.sol";
import "solmate/tokens/ERC721.sol";

contract DummyERC721 is ERC721 {
    uint256 _lastTokenId;

    constructor() ERC721('DUMMY', 'DUM') {}

    function mint(address owner)
        external
        returns (uint256)
    {
        _mint(owner, ++_lastTokenId);
        return _lastTokenId;
    }

    function asIERC721() external view returns (IERC721) {
        return IERC721(address(this));
    }

    function tokenURI(uint256 tokenId) public override pure returns (string memory) {}
}
