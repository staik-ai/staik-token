// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝


pragma solidity ^0.8.16;

interface IOffChainOracle {
    function getRateToEth(address srcToken, bool useSrcWrappers) external view returns (uint256);
}

contract TokenPrices {

    // gnosis
    address private constant offChainOracleAddress = 0x142DB045195CEcaBe415161e1dF1CF0337A4d02E;
    address private constant wethAddress = 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1;

    // arbitrum
    // address private constant offChainOracleAddress = 0x735247fb0a604c0adC6cab38ACE16D0DbA31295F;
    // address private constant wethAddress = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;


    struct TokenCurrent {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 price;
        uint256 timestamp;
        bool priceRise;
    }

    struct TokenLast {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 price;
        uint256 timestamp;
    }

    TokenCurrent[] public tokensCurrent;
    TokenLast[] public tokensLast;

    uint256 public lastUpdated;

    constructor() {

        // gnosis
        tokensCurrent.push(TokenCurrent('WETH', wethAddress, 18, 0, 0, false));
        tokensLast.push(TokenLast('WETH', wethAddress, 18, 0, 0));
        tokensCurrent.push(TokenCurrent('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0, false));
        tokensLast.push(TokenLast('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0));
        tokensCurrent.push(TokenCurrent('USDC', 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83, 6, 0, 0, false));
        tokensLast.push(TokenLast('USDC', 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83, 6, 0, 0));
        tokensCurrent.push(TokenCurrent('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0, false));
        tokensLast.push(TokenLast('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0));

        // arbitrum
        // tokensCurrent.push(TokenCurrent('WETH', wethAddress, 18, 0, 0, false));
        // tokensLast.push(TokenLast('WETH', wethAddress, 18, 0, 0));
        // tokensCurrent.push(TokenCurrent('WBTC', 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, 8, 0, 0, false));
        // tokensLast.push(TokenLast('WBTC', 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, 8, 0, 0));
        // tokensCurrent.push(TokenCurrent('USDC', 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 6, 0, 0, false));
        // tokensLast.push(TokenLast('USDC', 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, 6, 0, 0));
        // tokensCurrent.push(TokenCurrent('USDT', 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, 6, 0, 0, false));
        // tokensLast.push(TokenLast('USDT', 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, 6, 0, 0));

    }

    function updatePrices() public {
    IOffChainOracle offChainOracleContract = IOffChainOracle(offChainOracleAddress);

    for (uint256 i = 0; i < tokensCurrent.length; i++) {
        uint256 decodedRate = offChainOracleContract.getRateToEth(tokensCurrent[i].tokenAddress, true);
        uint256 numerator = 10**tokensCurrent[i].decimals;
        uint256 denominator = 10**18;
        uint256 price = decodedRate * numerator / denominator;
        tokensLast[i].price = tokensCurrent[i].price;
        tokensLast[i].timestamp = tokensCurrent[i].timestamp;
        tokensCurrent[i].price = price;
        tokensCurrent[i].timestamp = block.timestamp;

        // check for price rise since last call
        tokensCurrent[i].priceRise = tokensCurrent[i].price > tokensLast[i].price;
    }

    lastUpdated = block.timestamp;
    }

    function getPrices() public view returns (TokenCurrent[] memory) {
      return tokensCurrent;
    }

    function getWETH() public view returns (uint256) {
      return tokensCurrent[0].price;
    }

    function getWBTC() public view returns (uint256) {
      return tokensCurrent[1].price;
    }

    function getUSDC() public view returns (uint256) {
      return tokensCurrent[2].price;
    }

    function getUSDT() public view returns (uint256) {
      return tokensCurrent[3].price;
    }

}
