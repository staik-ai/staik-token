// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝


pragma solidity ^0.8.16;


interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

contract DEXLiquidityChecker {
    address public liquidityPair;

    constructor(address _liquidityPair) {
        liquidityPair = _liquidityPair;
    }

    function checkTotalSupply() external view returns (uint) {
        address pair = liquidityPair;
        return IUniswapV2Pair(pair).totalSupply();
    }

    function checkToken0Price() external view returns (uint) {
        address pair = liquidityPair;
        return IUniswapV2Pair(pair).price0CumulativeLast();
    }

    function checkToken1Price() external view returns (uint) {
        address pair = liquidityPair;
        return IUniswapV2Pair(pair).price1CumulativeLast();
    }

    function checkBalanceOf(address _wallet) external view returns (uint) {
        address pair = liquidityPair;
        return IUniswapV2Pair(pair).balanceOf(_wallet);
    }

}
