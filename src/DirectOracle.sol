// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";

/**
 * @title DirectOracle
 * @dev A simple price oracle that returns a configurable BTC price
 */
contract DirectOracle is AggregatorV3Interface {
    uint80 private constant ROUND_ID = 1;
    uint8 private constant DECIMALS_VALUE = 8;
    string private constant DESCRIPTION_TEXT = "kBTC/USD Direct Oracle";
    uint256 private constant VERSION_NUMBER = 1;
    
    // Default price: $50,000 with 8 decimals
    int256 private _price = 50000 * 10**8;
    uint256 private _updatedAt;
    
    /**
     * Constructor for the DirectOracle
     * Initializes the price to 50000e18 ($50,000)
     */
    constructor() {
        _updatedAt = block.timestamp;
    }
    
    /**
     * @dev Set a new price (for testing purposes)
     * @param newPrice The new price to set (with 8 decimals)
     */
    function setPrice(int256 newPrice) external {
        _price = newPrice;
        _updatedAt = block.timestamp;
    }
    
    /**
     * @dev Returns the current price data
     */
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (ROUND_ID, _price, _updatedAt, _updatedAt, ROUND_ID);
    }
    
    /**
     * @dev Returns data for a specific round ID (always returns the current price)
     */
    function getRoundData(uint80) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (ROUND_ID, _price, _updatedAt, _updatedAt, ROUND_ID);
    }
    
    /**
     * @dev Returns the number of decimals
     */
    function decimals() external pure override returns (uint8) {
        return DECIMALS_VALUE;
    }
    
    /**
     * @dev Returns the description
     */
    function description() external pure override returns (string memory) {
        return DESCRIPTION_TEXT;
    }
    
    /**
     * @dev Returns the version
     */
    function version() external pure override returns (uint256) {
        return VERSION_NUMBER;
    }
    
    /**
     * @dev For compatibility with Morpho Oracle interface
     */
    function price() external view returns (uint256) {
        return uint256(_price);
    }
} 