// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";
import "forge-std/console.sol";

contract ChainlinkPriceFeed {
    address public immutable priceFeed;
    
    constructor(address _priceFeed) {
        priceFeed = _priceFeed;
    }
    
    function getLatestPrice() public view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return AggregatorV3Interface(priceFeed).latestRoundData();
    }
    
    function fetchAndPrintPrice() public view {
        (
            uint80 roundId,
            int answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        ) = AggregatorV3Interface(priceFeed).latestRoundData();
        
        console.log("Round ID:", roundId);
        console.log("Answer:", answer);
        console.log("Started at:", startedAt);
        console.log("Updated at:", updatedAt);
        console.log("Answered in round:", answeredInRound);
        
        // Get the number of decimals to properly format the price
        uint8 decimals = AggregatorV3Interface(priceFeed).decimals();
        console.log("Decimals:", decimals);
        
        // Calculate the actual price with proper decimal places
        if (decimals > 0) {
            int256 priceWithDecimals = answer;
            console.log("Price with decimals:", priceWithDecimals);
        }
        
        // Get additional information from the price feed
        string memory description = AggregatorV3Interface(priceFeed).description();
        console.log("Description:", description);
    }
} 