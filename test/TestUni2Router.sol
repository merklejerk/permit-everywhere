// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../src/ERC20PermitEverywhere.sol";

interface IUniswapV2Router {
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
}

contract TestUni2Router {
    IUniswapV2Router public immutable ROUTER;
    ERC20PermitEverywhere public immutable PERMIT_EVERYWHERE;

    constructor(IUniswapV2Router router, ERC20PermitEverywhere pe) {
        ROUTER = router;
        PERMIT_EVERYWHERE = pe;
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address payable to,
        uint256 deadline,
        ERC20PermitEverywhere.PermitTransferFrom memory permit,
        ERC20PermitEverywhere.Signature memory permitSig
    )
        external
        returns (uint256[] memory amounts)
    {
        require(path[0] == address(permit.token), 'WRONG_PERMIT_TOKEN');
        PERMIT_EVERYWHERE.executePermitTransferFrom(
            msg.sender,
            address(this),
            amountIn,
            permit,
            permitSig
        );
        permit.token.approve(address(ROUTER), type(uint256).max);
        amounts = ROUTER.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }
}
