// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";

/**
 * @title SimpleKBTCOracle
 * @dev A simple price oracle that adapts the RedStone BTC price feed for use with kBTC
 */
contract SimpleKBTCOracle is AggregatorV3Interface {
    AggregatorV3Interface public immutable btcPriceFeed;
    
    // Fallback data in case the oracle call fails
    uint80 private constant FALLBACK_ROUND_ID = 1;
    int256 private constant FALLBACK_PRICE = 65000 * 10**8; // $65,000 with 8 decimals
    uint256 private constant FALLBACK_TIMESTAMP = 1716518400; // May 24, 2024
    uint8 private constant FALLBACK_DECIMALS = 8;
    string private constant FALLBACK_DESCRIPTION = "kBTC/USD Fallback Oracle";
    
    constructor(address _btcPriceFeed) {
        btcPriceFeed = AggregatorV3Interface(_btcPriceFeed);
    }
    
    /**
     * @dev Returns the latest price of BTC from the RedStone feed
     */
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        try btcPriceFeed.latestRoundData() returns (
            uint80 _roundId,
            int256 _answer,
            uint256 _startedAt,
            uint256 _updatedAt,
            uint80 _answeredInRound
        ) {
            return (_roundId, _answer, _startedAt, _updatedAt, _answeredInRound);
        } catch {
            // If the oracle call fails, return fallback data
            return (FALLBACK_ROUND_ID, FALLBACK_PRICE, FALLBACK_TIMESTAMP, FALLBACK_TIMESTAMP, FALLBACK_ROUND_ID);
        }
    }
    
    /**
     * @dev Returns data for a specific round ID
     */
    function getRoundData(uint80 _roundId) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        try btcPriceFeed.getRoundData(_roundId) returns (
            uint80 _roundIdResult,
            int256 _answer,
            uint256 _startedAt,
            uint256 _updatedAt,
            uint80 _answeredInRound
        ) {
            return (_roundIdResult, _answer, _startedAt, _updatedAt, _answeredInRound);
        } catch {
            // If the oracle call fails, return fallback data
            return (FALLBACK_ROUND_ID, FALLBACK_PRICE, FALLBACK_TIMESTAMP, FALLBACK_TIMESTAMP, FALLBACK_ROUND_ID);
        }
    }
    
    /**
     * @dev Returns the number of decimals used in the price feed
     */
    function decimals() external view override returns (uint8) {
        try btcPriceFeed.decimals() returns (uint8 _decimals) {
            return _decimals;
        } catch {
            return FALLBACK_DECIMALS;
        }
    }
    
    /**
     * @dev Returns a description of the price feed
     */
    function description() external pure override returns (string memory) {
        return FALLBACK_DESCRIPTION;
    }
    
    /**
     * @dev Returns the version of the price feed
     */
    function version() external view override returns (uint256) {
        try btcPriceFeed.version() returns (uint256 _version) {
            return _version;
        } catch {
            return 1;
        }
    }
    
    /**
     * @dev For compatibility with Morpho Oracle interface
     */
    function price() external view returns (uint256) {
        try btcPriceFeed.latestRoundData() returns (
            uint80,
            int256 _answer,
            uint256,
            uint256,
            uint80
        ) {
            if (_answer < 0) {
                return uint256(FALLBACK_PRICE);
            }
            return uint256(_answer);
        } catch {
            return uint256(FALLBACK_PRICE);
        }
    }
} 