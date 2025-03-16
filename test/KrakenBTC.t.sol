// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {IMorpho, MarketParams} from "../src/interfaces/IMorpho.sol";
import {Vm} from "forge-std/Vm.sol";

contract KrakenBTCTest is Test {
    // RPC URL and block number are set via Foundry's --fork-url and --fork-block-number flags
    // or directly in the test using createFork, createSelectFork
    
    KrakenBTC public kbtc;
    IMorpho public morpho;

    uint public chainId = 1; //ink: 57073

    address public deployer = address(this);
    address public loanToken; //USDT for mainnet, USDT0 for ink
    address public collateralToken; //kBTC
    address public oracle;
    address public irm;
    uint256 public lltv = 945000000000000000; // 94.5%

    // struct Log {
    //     bytes32[] topics;
    //     bytes data;
    //     address emitter;
    // }
    
    function setUp() public {
        // Create and select a fork of Ethereum mainnet at the specified block
        vm.createSelectFork(vm.envString("RPC_URL"), 22061417);
        
        // Deploy the KrakenBTC contract
        kbtc = new KrakenBTC();
        collateralToken = address(kbtc);

        if (chainId == 1) {
            loanToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // Chainlink BTC/USD
            irm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
        } else if (chainId == 57073) {
            // loanToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            // oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // Redstone BTC/USD
            // irm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
            // morpho = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;
        }
    }
    
    function testDeployerBalance() public view {
        // Get the deployer's balance
        uint256 deployerBalance = kbtc.balanceOf(deployer);
        
        // Log the balance to the console
        console.log("Deployer's kBTC balance:", deployerBalance);
        
        // Assert the balance is as expected (1,000,000 tokens with 18 decimals)
        assertEq(deployerBalance, 1_000_000 * 10**18);
    }


    function test_deployMorphoMarket() public {
        vm.recordLogs();

        morpho.createMarket(MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        }));

        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.logBytes32(entries[0].topics[1]);
    }
} 