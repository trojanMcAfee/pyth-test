// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/GetPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract GetPythPriceScript is Script {
    function run() external {
        // Use the private key from the Anvil instance (account 0)
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(privateKey);
        
        // Deploy our contract that interacts with Pyth
        GetPyth getPythContract = new GetPyth();
        console.log("GetPyth deployed at:", address(getPythContract));
        
        // Read the real price update data from the file that our Node.js script created
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/pyth-data.json");
        string memory json = vm.readFile(path);
        
        bytes memory vaaHex = vm.parseJsonBytes(json, ".hex");
        bytes[] memory updateData = new bytes[](1);
        
        // Convert hex string to bytes
        updateData[0] = abi.encodePacked(hex"", vaaHex);
        
        console.log("Using real Pyth price update data");
        console.log("Calling getKbtcBtcPrice...");
        
        // We need to attach some ETH to pay for the Pyth update fee
        // The getUpdateFee function will tell us how much we need, but for this demo
        // we'll just send 0.1 ETH which should be more than enough
        try getPythContract.getKbtcBtcPrice{value: 0.1 ether}(updateData, 100000) returns (PythStructs.Price memory price) {
            // Log the price details
            console.log("KBTC/BTC Price Result:");
            console.log("Price:", price.price);
            console.log("Conf:", price.conf);
            console.log("Expo:", price.expo);
            console.log("Publish Time:", price.publishTime);
            
            // Calculate and display the actual price with proper decimal places
            int256 actualPrice = price.price;
            int32 exponent = price.expo;
            
            if (exponent < 0) {
                // If expo is negative (e.g., -8), we divide by 10^abs(expo)
                // For example, if price is 1234567800 and expo is -8, actual price is 12345.678
                uint256 divisor = 10 ** uint256(int256(-exponent));
                if (actualPrice < 0) {
                    console.log("Actual Price: -", uint256(-actualPrice) / divisor);
                } else {
                    console.log("Actual Price: ", uint256(actualPrice) / divisor);
                }
            } else {
                // If expo is positive (e.g., 2), we multiply by 10^expo
                uint256 multiplier = 10 ** uint256(int256(exponent));
                if (actualPrice < 0) {
                    console.log("Actual Price: -", uint256(-actualPrice) * multiplier);
                } else {
                    console.log("Actual Price: ", uint256(actualPrice) * multiplier);
                }
            }
        } catch Error(string memory reason) {
            console.log("Error calling getKbtcBtcPrice:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("Unknown error calling getKbtcBtcPrice");
            
            if (lowLevelData.length > 0) {
                console.log("Low level error data length:", lowLevelData.length);
                // If we had a more sophisticated error handling, we might try to decode the error
            }
        }
        
        vm.stopBroadcast();
    }
} 