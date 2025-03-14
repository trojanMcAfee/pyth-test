// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ChainlinkPriceFeed.sol";

contract DeployChainlinkPriceFeedScript is Script {
    function run() external {
        // Use the default private key from Anvil for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        // The target Chainlink price feed address
        address priceFeedAddress = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the ChainlinkPriceFeed contract
        ChainlinkPriceFeed priceFeedContract = new ChainlinkPriceFeed(priceFeedAddress);
        console.log("ChainlinkPriceFeed deployed at:", address(priceFeedContract));
        
        // Call the function to fetch and print price data
        console.log("Fetching price data from Chainlink Oracle...");
        
        try priceFeedContract.fetchAndPrintPrice() {
            console.log("Price data successfully fetched and printed!");
            
            // Also fetch the raw data
            (
                uint80 roundId,
                int256 answer,
                uint256 startedAt,
                uint256 updatedAt,
                uint80 answeredInRound
            ) = priceFeedContract.getLatestPrice();
            
            console.log("Raw data - Round ID:", roundId);
            console.log("Raw data - Answer:", answer);
        } catch Error(string memory reason) {
            console.log("Error fetching price data:", reason);
        } catch (bytes memory) {
            console.log("Unknown error occurred while fetching price data");
        }
        
        vm.stopBroadcast();
    }
} 