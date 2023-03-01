// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

   

contract LPTokenCalculator {

/*  The function uses the square root of the product of the deposit 
    amount and the two reserve values, divided by the square root of the sum of the 
    first reserve and the deposit amount, divided by the square root of the sum of 
    the second reserve and the deposit amount. This is the calculation used by 
    Uniswap V2 to determine the amount of LP tokens to mint for a given deposit. 
*/ 

    function calculateLPtokens(address pairAddress, uint depositAmount) public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint reserve0, uint reserve1, ) = pair.getReserves();
        uint lpAmount = sqrt(depositAmount * reserve0 * reserve1) / sqrt(reserve0 + depositAmount) / sqrt(reserve1);
        return lpAmount;
    }
    
    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
