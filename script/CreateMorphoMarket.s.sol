// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import {KrakenBTC} from "../src/KrakenBTC.sol";
// import {DirectOracle} from "../src/DirectOracle.sol";
// import {IMorpho} from "../src/interfaces/IMorpho.sol";

// /**
//  * @title CreateMorphoMarket
//  * @notice Script to create a Morpho market with kBTC as collateral and DirectOracle for price feeds
//  */
// contract CreateMorphoMarket is Script {
//     // Ethereum Mainnet addresses
//     address public constant MORPHO_ADDRESS = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;
//     address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC on Ethereum
//     address public constant IRM_ADDRESS = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC; // Morpho IRM

//     // Base Mainnet addresses (uncomment to use Base instead)
//     // address public constant MORPHO_ADDRESS = 0x64c7044050Ba0431252df24fEd4d9635a275CB41;
//     // address public constant USDC_ADDRESS = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // USDC on Base
//     // address public constant IRM_ADDRESS = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC; // Morpho IRM

//     // Common LLTV values to try
//     uint256[] public lltvValues = [
//         0,                  // 0%
//         385000000000000000, // 38.5%
//         625000000000000000, // 62.5%
//         770000000000000000, // 77.0%
//         860000000000000000, // 86.0%
//         915000000000000000, // 91.5%
//         945000000000000000, // 94.5%
//         965000000000000000, // 96.5%
//         980000000000000000  // 98.0%
//     ];

//     function run() public {
//         // Load private key from environment
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         // Deploy KrakenBTC token with initial supply of 1000
//         KrakenBTC kbtc = new KrakenBTC(); //KrakenBTC kbtc = new KrakenBTC(1000);
//         console.log("KrakenBTC deployed at:", address(kbtc));

//         // Deploy DirectOracle with default price of $50,000
//         DirectOracle directOracle = new DirectOracle();
//         console.log("DirectOracle deployed at:", address(directOracle));

//         // Verify the oracle is working
//         (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         ) = directOracle.latestRoundData();
        
//         console.log("Oracle price:", uint256(answer));
//         console.log("Oracle updated at:", updatedAt);

//         // Try to create a market with multiple LLTV values
//         IMorpho morpho = IMorpho(MORPHO_ADDRESS);
        
//         for (uint i = 0; i < lltvValues.length; i++) {
//             uint256 lltv = lltvValues[i];
//             console.log("Attempting to create market with LLTV:", lltv);
            
//             try morpho.createMarket(
//                 USDC_ADDRESS,
//                 address(kbtc),
//                 address(directOracle),
//                 IRM_ADDRESS,
//                 lltv
//             ) returns (uint256 id) {
//                 console.log("Market created successfully with ID:", id);
//                 console.log("kBTC Address:", address(kbtc));
//                 console.log("Oracle Address:", address(directOracle));
//                 console.log("LLTV Value:", lltv);
//                 break; // Stop after the first successful creation
//             } catch Error(string memory reason) {
//                 console.log("Market creation failed with LLTV", lltv, ":", reason);
//             } catch (bytes memory) {
//                 console.log("Market creation failed with LLTV", lltv, "with unknown error");
//             }
//         }
        
//         vm.stopBroadcast();
//     }
// } 