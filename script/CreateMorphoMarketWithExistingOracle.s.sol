// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/KrakenBTC.sol";
import "../src/interfaces/IMorpho.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

contract CreateMorphoMarketWithExistingOracleScript is Script {
    // State variables to reduce stack depth
    address public morphoAddress = 0x857f3EefE8cbda3Bc49367C996cd664A880d3042;
    address public loanTokenAddress = 0x0200C29006150606B650577BBE7B6248F58470c1; // USDT0
    address public irmAddress = 0x9515407b1512F53388ffE699524100e7270Ee57B;
    address public oracleAddress = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e; // RedStone BTC oracle
    
    // Try multiple LLTV values from the list of allowed values
    uint256[] public lltvValues = [
        0,                  // 0%
        385000000000000000, // 38.5%
        625000000000000000, // 62.5%
        770000000000000000, // 77.0%
        860000000000000000, // 86.0%
        915000000000000000, // 91.5%
        945000000000000000, // 94.5%
        965000000000000000, // 96.5%
        980000000000000000  // 98.0%
    ];
    
    function run() external {
        // Use the default private key from Anvil for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Verify the RedStone BTC oracle to make sure it's functioning correctly
        verifyOracle();
        
        // Deploy KrakenBTC token
        KrakenBTC kbtc = new KrakenBTC(100000);
        address kbtcAddress = address(kbtc);
        console.log("KrakenBTC deployed at:", kbtcAddress);
        
        // Try to create markets with multiple LLTV values
        IMorpho morpho = IMorpho(morphoAddress);
        
        for (uint i = 0; i < lltvValues.length; i++) {
            uint256 lltv = lltvValues[i];
            console.log("Attempting to create market with LLTV:", lltv);
            
            try morpho.createMarket(
                loanTokenAddress,
                kbtcAddress,
                oracleAddress,
                irmAddress,
                lltv
            ) returns (uint256 id) {
                console.log("Market created successfully with ID:", id);
                console.log("kBTC Address:", kbtcAddress);
                console.log("Oracle Address:", oracleAddress);
                console.log("LLTV Value:", lltv);
                break; // Stop after the first successful creation
            } catch Error(string memory reason) {
                console.log("Market creation failed with LLTV", lltv, ":", reason);
            } catch (bytes memory) {
                console.log("Market creation failed with LLTV", lltv, "with unknown error");
            }
        }
        
        vm.stopBroadcast();
    }
    
    function verifyOracle() private {
        console.log("Verifying Oracle...");
        AggregatorV3Interface oracle = AggregatorV3Interface(oracleAddress);
        
        try oracle.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("Oracle Price:", answer);
            console.log("Oracle Decimals:", oracle.decimals());
            console.log("Oracle Description:", oracle.description());
        } catch Error(string memory reason) {
            console.log("Oracle Error:", reason);
            revert("Oracle Error");
        } catch (bytes memory) {
            console.log("Oracle Unknown Error");
            revert("Oracle Unknown Error");
        }
    }
} 