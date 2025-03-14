// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";

/**
 * @title DirectOracle
 * @dev A minimal price oracle that always returns a fixed BTC price
 */
contract DirectOracle is AggregatorV3Interface {
    uint80 private constant ROUND_ID = 1;
    int256 private constant PRICE = 65000 * 10**8; // $65,000 with 8 decimals
    uint256 private constant TIMESTAMP = 1716518400; // May 24, 2024
    uint8 private constant DECIMALS_VALUE = 8;
    string private constant DESCRIPTION_TEXT = "kBTC/USD Direct Oracle";
    uint256 private constant VERSION_NUMBER = 1;
    
    /**
     * @dev Returns a fixed price data
     */
    function latestRoundData() external pure override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (ROUND_ID, PRICE, TIMESTAMP, TIMESTAMP, ROUND_ID);
    }
    
    /**
     * @dev Returns data for a specific round ID (always returns the same fixed data)
     */
    function getRoundData(uint80) external pure override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (ROUND_ID, PRICE, TIMESTAMP, TIMESTAMP, ROUND_ID);
    }
    
    /**
     * @dev Returns a fixed number of decimals
     */
    function decimals() external pure override returns (uint8) {
        return DECIMALS_VALUE;
    }
    
    /**
     * @dev Returns a fixed description
     */
    function description() external pure override returns (string memory) {
        return DESCRIPTION_TEXT;
    }
    
    /**
     * @dev Returns a fixed version
     */
    function version() external pure override returns (uint256) {
        return VERSION_NUMBER;
    }
    
    /**
     * @dev For compatibility with Morpho Oracle interface
     */
    function price() external pure returns (uint256) {
        return uint256(PRICE);
    }
} 