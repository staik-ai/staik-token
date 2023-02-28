// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝

pragma solidity ^0.8.18;
pragma abicoder v2;

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function balanceOf(address owner) external view returns (uint);
    function nonces(address owner) external view returns (uint);
}

contract DEXV2PoolInfo {

// Address of USDC/ETH pair on UniswapV2 on Ethereum Mainnet
address public pairAddress = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

// returns token 0 address     
    function getToken0Address() public view returns (address) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        address token0Address = pair.token0();
        return token0Address;
    }

// returns token 1 address     
    function getToken1Address() public view returns (address) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        address token1Address = pair.token1();
        return token1Address;
    }

// returns token 0 amount in the pool    
    function token0Amount() public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint112 reserve0, , ) = pair.getReserves();
        return reserve0;
    }

// returns token 1 amount in the pool     
    function token1Amount() public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (, uint112 reserve1, ) = pair.getReserves();
        return reserve1;
    }

// returns the percentage ownership of the pool    
    function getLPPercentage(address _wallet) public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint totalSupply = pair.totalSupply();
        uint balance = pair.balanceOf(_wallet);
        return balance * 100 / totalSupply;
    }

// returns the percentage ownership of the caller    
    function getLPPercentageOfCaller() public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint totalSupply = pair.totalSupply();
        uint balance = pair.balanceOf(msg.sender);
        return balance * 100 / totalSupply;
    }

    // returns the total tokens for the pool    
    function getLPTotalSupply() public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint totalSupply = pair.totalSupply();
        return totalSupply;
    }

    // returns the nonce of a wallet address    
    function getPoolNonce(address _address) public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint nonce = pair.nonces(_address);
        return nonce;
    }

    // returns the nonce of the caller   
    function getPoolNonceOfCaller() public view returns (uint) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint nonce = pair.nonces(msg.sender);
        return nonce;
    }

    // returns the percentage ownership of the pool    
    function updatePairAddress(address _address) public {
        pairAddress = _address;
    }

}
