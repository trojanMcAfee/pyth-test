// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "../src/KrakenBTC.sol";
import "../src/interfaces/IMorpho.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

contract CreateMorphoMarketScript is Script {
    // Event signature for CreateMarket event
    event CreateMarket(
        uint256 indexed id,
        address indexed loanToken,
        address indexed collateralToken,
        address oracle,
        address irm,
        uint256 lltv
    );

    function run() external {
        // Use the default private key from Anvil for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        // Given parameters
        address morphoAddress = 0x857f3EefE8cbda3Bc49367C996cd664A880d3042;
        address loanTokenAddress = 0x0200C29006150606B650577BBE7B6248F58470c1; // USDT0
        address irmAddress = 0x9515407b1512F53388ffE699524100e7270Ee57B;
        uint256 lltv = 945000000000000000; // 94.5% in 1e18 scale
        address oracleAddress = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // First, verify that the oracle is working properly
        console.log("Checking oracle price feed...");
        AggregatorV3Interface oracle = AggregatorV3Interface(oracleAddress);
        
        try oracle.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("Oracle is working - BTC Price:", answer);
            console.log("Oracle decimals:", oracle.decimals());
            console.log("Oracle description:", oracle.description());
        } catch Error(string memory reason) {
            console.log("Oracle query failed:", reason);
            vm.stopBroadcast();
            return;
        } catch (bytes memory) {
            console.log("Oracle query failed with unknown error");
            vm.stopBroadcast();
            return;
        }
        
        // Deploy KrakenBTC token (representing BTC)
        KrakenBTC kbtc = new KrakenBTC(100000);
        address kbtcAddress = address(kbtc);
        console.log("KrakenBTC deployed at:", kbtcAddress);
        
        // Print debug info
        console.log("Morpho Address:", morphoAddress);
        console.log("Loan Token Address:", loanTokenAddress);
        console.log("Oracle Address:", oracleAddress);
        console.log("IRM Address:", irmAddress);
        console.log("LLTV:", lltv);
        
        // Try creating the Morpho market
        console.log("Creating Morpho market...");
        IMorpho morpho = IMorpho(morphoAddress);
        
        // Let's try with a lower LLTV value to see if that helps
        // Morpho documentation mentions allowed values: [0%; 38.5%; 62.5%; 77.0%; 86.0%; 91.5%; 94.5%; 96.5%; 98%]
        // Let's try with 62.5% (625000000000000000)
        uint256 newLltv = 625000000000000000; // 62.5% in 1e18 scale
        console.log("Trying with lower LLTV:", newLltv);
        
        try morpho.createMarket(
            loanTokenAddress,
            kbtcAddress,
            oracleAddress,
            irmAddress,
            newLltv
        ) returns (uint256 id) {
            console.log("Morpho market created successfully with ID:", id);
            console.log("kBTC Address:", kbtcAddress);
        } catch Error(string memory reason) {
            console.log("Failed to create Morpho market:", reason);
            
            // If the first attempt fails, try with the original LLTV value
            console.log("Trying with original LLTV:", lltv);
            try morpho.createMarket(
                loanTokenAddress,
                kbtcAddress,
                oracleAddress,
                irmAddress,
                lltv
            ) returns (uint256 id) {
                console.log("Morpho market created successfully with ID:", id);
                console.log("kBTC Address:", kbtcAddress);
            } catch Error(string memory reason) {
                console.log("Second attempt failed:", reason);
            } catch (bytes memory) {
                console.log("Second attempt failed with unknown error");
            }
        } catch (bytes memory) {
            console.log("Failed to create Morpho market with unknown error");
        }
        
        vm.stopBroadcast();
    }
}