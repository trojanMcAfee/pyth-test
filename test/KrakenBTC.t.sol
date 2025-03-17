// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {IMorpho, MarketParams, Id} from "../src/interfaces/IMorpho.sol";
import {Vm} from "forge-std/Vm.sol";
import {IIrm} from "../src/interfaces/IIrm.sol";

contract KrakenBTCTest is Test {
    // RPC URL and block number are set via Foundry's --fork-url and --fork-block-number flags
    // or directly in the test using createFork, createSelectFork
    
    KrakenBTC public kbtc;
    IMorpho public morpho;

    uint public chainId = 57073; //ink: 57073

    address public deployer = address(this);
    address public loanToken; 
    address public collateralToken; //kBTC
    address public oracle;
    address public irm;
    uint256 public lltv = 945000000000000000; // 94.5%
    uint public blockNumber;
    string public rpcUrl;
    
    function setUp() public {        
        // Deploy the KrakenBTC contract
        kbtc = new KrakenBTC();
        collateralToken = address(kbtc);

        if (chainId == 1) {
            loanToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
            oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // Chainlink BTC/USD
            irm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
            blockNumber = 22061417;
            rpcUrl = vm.envString("RPC_URL");
        } else if (chainId == 57073) {
            loanToken = 0x0200C29006150606B650577BBE7B6248F58470c1; //USDT0
            oracle = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e; // Redstone BTC/USD
            irm = 0x9515407b1512F53388ffE699524100e7270Ee57B;
            morpho = IMorpho(0x857f3EefE8cbda3Bc49367C996cd664A880d3042);
            rpcUrl = vm.envString("INK_RPC_URL");
            blockNumber = 8657564;
        }

        vm.createSelectFork(rpcUrl, blockNumber);
    }
    
    function testDeployerBalance() public view {
        // Get the deployer's balance
        uint256 deployerBalance = kbtc.balanceOf(deployer);
        
        // Log the balance to the console
        console.log("Deployer's kBTC balance:", deployerBalance);
        
        // Assert the balance is as expected (1,000,000 tokens with 18 decimals)
        assertEq(deployerBalance, 1_000_000 * 10**18);
    }

    function test_redStoneBTCPrice() public view {
        int256 btcPrice = kbtc.getBTCPrice();
        console.log('btcPrice: ', btcPrice);
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
        bytes32 marketId = entries[0].topics[1];
        console.logBytes32(marketId);
        console.log('market ID ^');

        (address loanToken_i, address collateralToken_i, address oracle_i, address irm_i, uint256 lltv_i) = morpho.idToMarketParams(Id.wrap(marketId));
        console.log("loanToken:", loanToken_i);
        console.log("collateralToken:", collateralToken_i);
        console.log("oracle:", oracle_i);
        console.log("irm:", irm_i);
        console.log("lltv:", lltv_i);
        
        console.log('');
        console.log('rate at target: ', IIrm(irm).rateAtTarget(Id.wrap(marketId)));
        (
            uint128 totalSupplyAssets,
            uint128 totalSupplyShares,
            uint128 totalBorrowAssets,
            uint128 totalBorrowShares,
            uint128 lastUpdate,
            uint128 fee
        ) = morpho.market(Id.wrap(marketId));

        console.log('totalSupplyAssets: ', totalSupplyAssets);
        console.log('totalSupplyShares: ', totalSupplyShares);
        console.log('totalBorrowAssets: ', totalBorrowAssets);
        console.log('totalBorrowShares: ', totalBorrowShares);
        console.log('lastUpdate: ', lastUpdate);
        console.log('fee: ', fee);

        console.log('');
        console.log('isIrmEnabled: ', morpho.isIrmEnabled(irm));
        console.log('isLltvEnabled: ', morpho.isLltvEnabled(lltv));

        // bytes memory supplyCollateralBytes = abi.encodeWithSignature(
        //     morpho.supplyCollateral.selector,
        //     MarketParams({
        //         loanToken: loanToken,
        //         collateralToken: collateralToken,
        //         oracle: oracle,
        //         irm: irm,
        //         lltv: lltv
        //     }),
        //     1000000000000000000,
        //     deployer,
        //     ''
        // );
        
        
    }
} 