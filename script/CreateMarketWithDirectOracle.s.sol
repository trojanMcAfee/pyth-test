// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {DirectOracle} from "../src/DirectOracle.sol";
import {IMorpho} from "../src/interfaces/IMorpho.sol";
import {IIrm} from "../src/interfaces/IIrm.sol";
import {AggregatorV3Interface} from "../src/interfaces/AggregatorV3Interface.sol";

contract CreateMarketWithDirectOracleScript is Script {
    address public immutable morphoAddress = 0x64c7044050Ba0431252df24fEd4d9635a275CB41;
    address public immutable loanTokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC on mainnet
    address public immutable irmAddress = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC; // Morpho IRM

    function run() public {
        // Use anvil's default first private key
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);

        // Deploy KrakenBTC token with initial supply of 1000
        KrakenBTC kbtc = new KrakenBTC(1000);
        console.log("KrakenBTC deployed at:", address(kbtc));

        // Deploy DirectOracle
        DirectOracle directOracle = new DirectOracle();
        console.log("DirectOracle deployed at:", address(directOracle));

        // Verify the oracle
        verifyOracle(address(directOracle));

        // Try to create a market with a single LLTV value
        IMorpho morpho = IMorpho(morphoAddress);
        uint256 lltv = 0; // 0% LLTV is the safest option

        console.log("----------------------------------------------");
        console.log("Attempting to create market with the following parameters:");
        console.log("Loan Token:", loanTokenAddress);
        console.log("Collateral Token:", address(kbtc));
        console.log("Oracle:", address(directOracle));
        console.log("IRM:", irmAddress);
        console.log("LLTV:", lltv);
        console.log("----------------------------------------------");

        try morpho.createMarket(
            loanTokenAddress,
            address(kbtc),
            address(directOracle),
            irmAddress,
            lltv
        ) returns (uint256 id) {
            console.log("Market created successfully with ID:", id);
        } catch Error(string memory reason) {
            console.log("Failed to create market. Error:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Failed to create market. Unknown error with data length:", lowLevelData.length);
            if (lowLevelData.length > 0) {
                bytes4 selector;
                assembly {
                    selector := mload(add(lowLevelData, 0x20))
                }
                console.log("Error selector:", uint32(selector));
            }
        }

        vm.stopBroadcast();
    }

    function verifyOracle(address oracle) public view {
        AggregatorV3Interface oracleContract = AggregatorV3Interface(oracle);
        
        console.log("----------------------------------------------");
        console.log("Oracle verification:");
        
        // Get oracle price
        try oracleContract.latestRoundData() returns (
            uint80,
            int256 price,
            uint256,
            uint256,
            uint80
        ) {
            console.log("Oracle Price:", uint256(price));
        } catch {
            console.log("Oracle Price: Failed to get price");
        }
        
        // Get oracle decimals
        try oracleContract.decimals() returns (uint8 decimals) {
            console.log("Oracle Decimals:", decimals);
        } catch {
            console.log("Oracle Decimals: Failed to get decimals");
        }
        
        // Get oracle description
        try oracleContract.description() returns (string memory description) {
            console.log("Oracle Description:", description);
        } catch {
            console.log("Oracle Description: Failed to get description");
        }
        
        // Test the price() function specifically
        try DirectOracle(oracle).price() returns (uint256 _price) {
            console.log("Oracle price() function result:", _price);
        } catch {
            console.log("Oracle price() function: Failed to get price");
        }
        console.log("----------------------------------------------");
    }
} 