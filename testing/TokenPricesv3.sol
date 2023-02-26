// SPDX-License-Identifier: UNLICENSED

//     ███████╗████████╗ █████╗ ██╗██╗  ██╗    █████╗ ██╗
//     ██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝   ██╔══██╗██║
//     ███████╗   ██║   ███████║██║█████╔╝    ███████║██║
//     ╚════██║   ██║   ██╔══██║██║██╔═██╗    ██╔══██║██║
//     ███████║   ██║   ██║  ██║██║██║  ██╗██╗██║  ██║██║
//     ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝


pragma solidity ^0.8.17;

interface IOffChainOracle {
    function getRate(address srcToken, address dstToken, bool useWrappers) external view returns (uint256);
    function getRateToEth(address srcToken, bool useSrcWrappers) external view returns (uint256);
    // The memory keyword in returns (address[] memory) indicates that the array will be stored in memory instead of storage
    function oracles() external view returns (address[] memory);
}

contract TokenPrices {

    uint256 public bpl;
    uint256 public spr;

    // gnosis
    address public constant offChainOracleAddress = 0x142DB045195CEcaBe415161e1dF1CF0337A4d02E;
    address public constant wethAddress = 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1;
    address public constant usdcAddress = 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83;

    // arbitrum
//    address public constant offChainOracleAddress = 0x735247fb0a604c0adC6cab38ACE16D0DbA31295F;
//    address public constant wethAddress = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
//    address public constant usdcAddress = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;

// structs to store data in contract
    struct TokenCurrent {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 price;
        uint256 timestamp;
        uint256 callCount;
        bool priceRise;
        
    }

    struct TokenLast {
        string name;
        address tokenAddress;
        uint256 decimals;
        uint256 price;
        uint256 timestamp;
        uint256 callCount;
    }

    TokenCurrent[] public tokensCurrent;
    TokenLast[] public tokensLast;

    uint256 public lastUpdated;

    constructor() {

        // gnosis
        tokensCurrent.push(TokenCurrent('WETH', wethAddress, 18, 0, 0, 0, false));
        tokensLast.push(TokenLast('WETH', wethAddress, 18, 0, 0, 0));
        tokensCurrent.push(TokenCurrent('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0, 0, false));
        tokensLast.push(TokenLast('WBTC', 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252, 8, 0, 0, 0));
        tokensCurrent.push(TokenCurrent('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0, 0, false));
        tokensLast.push(TokenLast('USDT', 0x4ECaBa5870353805a9F068101A40E0f32ed605C6, 6, 0, 0, 0));

        // arbitrum
//         tokensCurrent.push(TokenCurrent('WETH', wethAddress, 18, 0, 0, false));
//         tokensLast.push(TokenLast('WETH', wethAddress, 18, 0, 0));
//         tokensCurrent.push(TokenCurrent('WBTC', 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, 8, 0, 0, 0, false));
//         tokensLast.push(TokenLast('WBTC', 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, 8, 0, 0, 0));
//         tokensCurrent.push(TokenCurrent('USDT', 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, 6, 0, 0, 0, false));
//         tokensLast.push(TokenLast('USDT', 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, 6, 0, 0, 0));

    }


    function updateDollarPrices() public {
    for (uint256 i = 0; i < tokensCurrent.length; i++) {
        address oracle = offChainOracleAddress;
        uint decodedRate = IOffChainOracle(oracle).getRate(tokensCurrent[i].tokenAddress, usdcAddress, true);
        uint256 numerator = 10**tokensCurrent[i].decimals;
        uint256 denominator = 10**6;
        uint256 price = decodedRate * numerator / denominator;
        tokensLast[i].price = tokensCurrent[i].price;
        tokensLast[i].timestamp = tokensCurrent[i].timestamp;
        tokensLast[i].callCount = tokensCurrent[i].callCount;
        tokensCurrent[i].price = price;
        tokensCurrent[i].timestamp = block.timestamp;
        tokensCurrent[i].callCount = tokensCurrent[i].callCount +1;

        // check for price rise since last call
        tokensCurrent[i].priceRise = tokensCurrent[i].price > tokensLast[i].price;
    }

    // update BPL value based on ETH & BTC prices
    if(tokensCurrent[0].priceRise == true && tokensCurrent[1].priceRise == true) {
        bpl = bpl + 100;
    } else if(tokensCurrent[0].priceRise == false && tokensCurrent[1].priceRise == false) {
          if(bpl != 0) {
              bpl = bpl - 100;
          }
    }
    // update SPR value based on ETH & BTC prices
    if(tokensCurrent[0].priceRise == false && tokensCurrent[1].priceRise == false) {
        spr = spr + 100;
    } else if(tokensCurrent[0].priceRise == true && tokensCurrent[1].priceRise == true) {
          if(spr != 0) {
              spr = spr - 100;
          }
    }

    // update timestamp
    lastUpdated = block.timestamp;

    }


// functions to check contract prices stored in this contract

    function getPrices() public view returns (TokenCurrent[] memory) {
        return tokensCurrent;
    }

    function getWETH() public view returns (uint256) {
        return tokensCurrent[0].price;
    }

    function getWBTC() public view returns (uint256) {
        return tokensCurrent[1].price;
    }

    function getUSDT() public view returns (uint256) {
        return tokensCurrent[2].price;
    }

// functions to check pricing and info directly from the oracle itself

    function getRateDollar(address _src, bool _wrappers) external view returns (uint) {
        address oracle = offChainOracleAddress;
        return IOffChainOracle(oracle).getRate(_src, usdcAddress, _wrappers);
    }

    function getRateEth(address _src, bool _wrappers) external view returns (uint) {
        address oracle = offChainOracleAddress;
        return IOffChainOracle(oracle).getRateToEth(_src, _wrappers);
    }

    // additional function to accommodate Gnosis Chain
    function getGnosisRateEth(address _src, bool _wrappers) external view returns (uint) {
        address oracle = offChainOracleAddress;
                return IOffChainOracle(oracle).getRate(_src, wethAddress, _wrappers);
    }


    // retrieve list of oracles called
    function oracleList() external view returns (address[] memory) {
        address oracle = offChainOracleAddress;
        return IOffChainOracle(oracle).oracles();
    }

}
