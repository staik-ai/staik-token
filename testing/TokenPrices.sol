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
    address private constant offChainOracleAddress = 0x142DB045195CEcaBe415161e1dF1CF0337A4d02E;
    address private constant wethAddress = 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1;

    struct TokenCurrent {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 ethPrice;
        uint256 dollarPrice;
        uint256 timestamp;
    }

    struct TokenLast {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 ethPrice;
        uint256 dollarPrice;
        uint256 timestamp;
    }

    TokenCurrent[] public tokensCurrent;
    TokenLast[] public tokensLast;

    uint256 public lastUpdated;

    constructor() {
        tokensCurrent.push(TokenCurrent('WETH', wethAddress, 18, 0, 0, 0));
        tokensLast.push(TokenLast('WETH', wethAddress, 18, 0, 0, 0));
        tokensCurrent.push(TokenCurrent('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0, 0));
        tokensLast.push(TokenLast('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0, 0));
        tokensCurrent.push(TokenCurrent('USDC', 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83, 6, 0, 0, 0));
        tokensLast.push(TokenLast('USDC', 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83, 6, 0, 0, 0));
        tokensCurrent.push(TokenCurrent('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0, 0));
        tokensLast.push(TokenLast('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0, 0));
    }

function updatePrices() public {
    IOffChainOracle offChainOracleContract = IOffChainOracle(offChainOracleAddress);

    for (uint256 i = 0; i < tokensCurrent.length; i++) {
        uint256 decodedRate = offChainOracleContract.getRateToEth(tokensCurrent[i].tokenAddress, true);
        uint256 numerator = 10**tokensCurrent[i].decimals;
        uint256 denominator = 10**18;
        uint256 price = decodedRate * numerator / denominator;
        tokensLast[i].ethPrice = tokensCurrent[i].ethPrice;
        tokensLast[i].timestamp = tokensCurrent[i].timestamp;
        tokensCurrent[i].ethPrice = price;
        tokensCurrent[i].timestamp = block.timestamp;
    }

    uint256 ethDollarValue = 1 ether / tokensCurrent[2].ethPrice;

    for (uint256 i = 0; i < tokensCurrent.length; i++) {
        tokensLast[i].dollarPrice = tokensCurrent[i].dollarPrice;
        uint256 dollarPrice = ethDollarValue / tokensCurrent[i].ethPrice;
        tokensCurrent[i].dollarPrice = dollarPrice;
    }

    lastUpdated = block.timestamp;
}

    function getPrices() public view returns (TokenCurrent[] memory) {
        return tokensCurrent;
    }

    function getWETH() public view returns (uint256) {
        return tokensCurrent[0].ethPrice;
    }

    function getWBTC() public view returns (uint256) {
        return tokensCurrent[1].ethPrice;
    }

    function getUSDC() public view returns (uint256) {
        return tokensCurrent[2].ethPrice;
    }

    function getUSDT() public view returns (uint256) {
        return tokensCurrent[3].ethPrice;
    }
}
