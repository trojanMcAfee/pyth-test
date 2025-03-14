// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {SimpleKBTCOracle} from "../src/SimpleKBTCOracle.sol";
import {IMorpho} from "../src/interfaces/IMorpho.sol";
import {IIrm} from "../src/interfaces/IIrm.sol";
import {AggregatorV3Interface} from "../src/interfaces/AggregatorV3Interface.sol";

contract CreateMorphoMarketWithSimpleOracleScript is Script {
    address public immutable morphoAddress = 0x64c7044050Ba0431252df24fEd4d9635a275CB41;
    address public immutable loanTokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC on mainnet
    address public immutable irmAddress = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC; // Morpho IRM
    address public immutable redStoneBTCOracle = 0xD702DD976Fb76Fffc2D3963D037dfDae5b04E593; // RedStone BTC oracle

    uint256[] public lltvs = [
        0,                     // 0%
        385000000000000000,    // 38.5%
        625000000000000000,    // 62.5%
        770000000000000000,    // 77%
        860000000000000000,    // 86%
        915000000000000000,    // 91.5%
        945000000000000000,    // 94.5%
        965000000000000000,    // 96.5%
        980000000000000000     // 98%
    ];

    function run() public {
        // Use anvil's default first private key
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);

        // Deploy KrakenBTC token with initial supply of 1000
        KrakenBTC kbtc = new KrakenBTC(1000);
        console.log("KrakenBTC deployed at:", address(kbtc));

        // Deploy SimpleKBTCOracle
        SimpleKBTCOracle simpleOracle = new SimpleKBTCOracle(redStoneBTCOracle);
        console.log("SimpleKBTCOracle deployed at:", address(simpleOracle));

        // Verify the oracle
        verifyOracle(address(simpleOracle));

        // Create market with multiple LLTV values
        IMorpho morpho = IMorpho(morphoAddress);
        for (uint256 i = 0; i < lltvs.length; i++) {
            try morpho.createMarket(
                loanTokenAddress,
                address(kbtc),
                address(simpleOracle),
                irmAddress,
                lltvs[i]
            ) {
                console.log("Market created successfully with LLTV:", lltvs[i]);
            } catch Error(string memory reason) {
                console.log("Failed to create market with LLTV:", lltvs[i]);
                console.log("Error:", reason);
            } catch (bytes memory) {
                console.log("Failed to create market with LLTV:", lltvs[i]);
                console.log("Unknown error");
            }
        }

        vm.stopBroadcast();
    }

    function verifyOracle(address oracle) public view {
        AggregatorV3Interface oracleContract = AggregatorV3Interface(oracle);
        
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
            console.log("Oracle Price: Failed to get price, using fallback");
        }
        
        // Get oracle decimals
        try oracleContract.decimals() returns (uint8 decimals) {
            console.log("Oracle Decimals:", decimals);
        } catch {
            console.log("Oracle Decimals: Failed to get decimals, using fallback");
        }
        
        // Get oracle description
        try oracleContract.description() returns (string memory description) {
            console.log("Oracle Description:", description);
        } catch {
            console.log("Oracle Description: Failed to get description, using fallback");
        }
    }
} 