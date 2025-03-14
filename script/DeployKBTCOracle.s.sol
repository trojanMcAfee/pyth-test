// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/KrakenBTC.sol";
import "../src/interfaces/IMorphoOracleFactory.sol";
import "../src/interfaces/AggregatorV3Interface.sol";
import "../src/interfaces/IMorpho.sol";

contract DeployKBTCOracleScript is Script {
    // Move variables to state variables to reduce stack depth
    address public factoryAddress = 0x3FFFE273ee348b9E1ef89533025C7f165B17B439;
    address public redStoneBtcFeed = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e;
    address public morphoAddress = 0x857f3EefE8cbda3Bc49367C996cd664A880d3042;
    address public loanTokenAddress = 0x0200C29006150606B650577BBE7B6248F58470c1; // USDT0
    address public irmAddress = 0x9515407b1512F53388ffE699524100e7270Ee57B;
    
    // Try with a much more conservative LLTV value (38.5%)
    uint256 public lltv = 385000000000000000; // 38.5% in 1e18 scale
    
    function run() external {
        // Use the default private key from Anvil for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy kBTC token
        KrakenBTC kbtc = new KrakenBTC(100000);
        address kbtcAddress = address(kbtc);
        console.log("KrakenBTC deployed at:", kbtcAddress);
        
        // Verify RedStone BTC feed
        verifyBtcFeed();
        
        // Step 2: Create the oracle
        address oracleAddress = createKbtcOracle();
        
        if (oracleAddress != address(0)) {
            // Verify the new oracle works correctly
            verifyOracle(oracleAddress);
            
            // Step 3: Create the market
            createMarket(kbtcAddress, oracleAddress);
        }
        
        vm.stopBroadcast();
    }
    
    function verifyBtcFeed() private {
        console.log("Verifying RedStone BTC feed...");
        AggregatorV3Interface btcFeed = AggregatorV3Interface(redStoneBtcFeed);
        
        try btcFeed.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("BTC Feed Price:", answer);
            console.log("BTC Feed Decimals:", btcFeed.decimals());
            console.log("BTC Feed Description:", btcFeed.description());
        } catch Error(string memory reason) {
            console.log("BTC Feed Error:", reason);
            revert("BTC Feed Error");
        } catch (bytes memory) {
            console.log("BTC Feed Unknown Error");
            revert("BTC Feed Unknown Error");
        }
    }
    
    function createKbtcOracle() private returns (address) {
        // Step 2: Use the Factory to create a custom Oracle for kBTC
        IMorphoOracleFactory factory = IMorphoOracleFactory(factoryAddress);
        
        // Oracle parameters
        address baseVault = address(0); // Not using a vault for kBTC
        uint256 baseVaultConversionSample = 1; // Not using a vault conversion
        uint256 baseTokenDecimals = 18; // kBTC has 18 decimals
        uint256 quoteTokenDecimals = 6; // USD typically has 6 decimals
        
        console.log("Creating oracle for kBTC through factory...");
        
        try factory.createMorphoChainlinkOracleV2(
            baseVault,
            baseVaultConversionSample,
            redStoneBtcFeed, // baseFeed1
            address(0), // baseFeed2
            baseTokenDecimals,
            address(0), // quoteVault
            1, // quoteVaultConversionSample
            address(0), // quoteFeed1
            address(0), // quoteFeed2
            quoteTokenDecimals,
            bytes32(0) // salt
        ) returns (address oracleAddress) {
            console.log("Oracle created successfully at:", oracleAddress);
            return oracleAddress;
        } catch Error(string memory reason) {
            console.log("Oracle creation failed:", reason);
            return address(0);
        } catch (bytes memory) {
            console.log("Oracle creation failed with unknown error");
            return address(0);
        }
    }
    
    function verifyOracle(address oracleAddress) private {
        console.log("Verifying new oracle...");
        AggregatorV3Interface oracle = AggregatorV3Interface(oracleAddress);
        
        try oracle.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            console.log("New Oracle Price:", answer);
            
            try oracle.decimals() returns (uint8 decimals) {
                console.log("New Oracle Decimals:", decimals);
            } catch {
                console.log("Failed to get oracle decimals");
            }
            
            try oracle.description() returns (string memory desc) {
                console.log("New Oracle Description:", desc);
            } catch {
                console.log("Failed to get oracle description");
            }
        } catch Error(string memory reason) {
            console.log("New Oracle Error:", reason);
        } catch (bytes memory) {
            console.log("New Oracle Unknown Error");
        }
    }
    
    function createMarket(address kbtcAddress, address oracleAddress) private {
        console.log("Creating Morpho market with custom oracle...");
        console.log("LLTV used:", lltv);
        IMorpho morpho = IMorpho(morphoAddress);
        
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
        } catch Error(string memory reason) {
            console.log("Market creation failed:", reason);
            
            // If the lower LLTV fails, try with an even lower one (25%)
            uint256 veryLowLltv = 250000000000000000;
            console.log("Trying with even lower LLTV:", veryLowLltv);
            
            try morpho.createMarket(
                loanTokenAddress,
                kbtcAddress,
                oracleAddress,
                irmAddress,
                veryLowLltv
            ) returns (uint256 id) {
                console.log("Market created successfully with very low LLTV, ID:", id);
                console.log("kBTC Address:", kbtcAddress);
                console.log("Oracle Address:", oracleAddress);
            } catch Error(string memory reason) {
                console.log("Second attempt failed:", reason);
            } catch (bytes memory) {
                console.log("Second attempt failed with unknown error");
            }
        } catch (bytes memory) {
            console.log("Market creation failed with unknown error");
        }
    }
} 