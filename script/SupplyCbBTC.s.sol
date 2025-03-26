// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMorpho, MarketParams, Id} from "../src/interfaces/IMorpho.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {IPermit2} from "../src/interfaces/IPermit2.sol";
import {IChainAgnosticBundlerV2} from "../src/interfaces/IChainAgnosticBundlerV2.sol";
import {EIP712Signature} from "../src/EIP712/EIP712Signature.sol";

/**
 * @title SupplyCbBTC
 * @notice Script to supply cbBTC as collateral to the cbBTC/USDC market on Base
 */
contract SupplyCbBTC is Script {
    KrakenBTC public kbtc;
    IMorpho public morpho;

    uint public chainId = 8453; //ink: 57073 - base: 8453

    address public deployer = makeAddr("deployer");
    // address public deployer = address(this);
    address public loanToken; 
    address public collateralToken; //kBTC
    address public oracle;
    address public irm;
    uint256 public lltv = 945000000000000000; // 94.5%
    uint public blockNumber;
    string public rpcUrl;

    IERC20 public cbBTC;
    IERC20 public USDC;
    bytes32 public marketId;

    IPermit2 public permit2;
    IChainAgnosticBundlerV2 public bundler;
    EIP712Signature public eip712Signature;
    
    function setUp() public {

        if (chainId == 1) {
            collateralToken = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf; //cbBTC
            loanToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
            oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // Chainlink BTC/USD
            irm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
        } else if (chainId == 57073) {
            collateralToken = address(kbtc);
            loanToken = 0x0200C29006150606B650577BBE7B6248F58470c1; //USDT0
            oracle = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e; // Redstone BTC/USD
            irm = 0x9515407b1512F53388ffE699524100e7270Ee57B;
            morpho = IMorpho(0x857f3EefE8cbda3Bc49367C996cd664A880d3042);
        } else if (chainId == 8453) {
            collateralToken = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf; //cbBTC
            loanToken = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; //USDC
            oracle = 0x663BECd10daE6C4A3Dcd89F1d76c1174199639B9; 
            irm = 0x46415998764C29aB2a25CbeA6254146D50D22687;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
            lltv = 860000000000000000; //86%

            cbBTC = IERC20(collateralToken);
            USDC = IERC20(loanToken);

            // Market ID for on Base
            marketId = 0x9103c3b4e834476c9a62ea009ba2c884ee42e94e6e314a26f04d312434191836; //cbBTC/USDC
            marketId = 0x8793cf302b8ffd655ab97bd1c695dbd967807e8367a65cb2f4edaf1380ba1bda; //wETH/USDC
            
            permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);
            bundler = IChainAgnosticBundlerV2(0x23055618898e202386e6c13955a58D3C68200BFB);

            eip712Signature = new EIP712Signature();
        }
    }
    
    function run() public {
        // Load private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Create market params struct
        MarketParams memory cbBtcParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        });
        
        // Amount to supply (100 cbBTC with 8 decimals)
        uint256 amount = 100 * 1e8;
        
        // Since we're on a fork, use the deal cheatcode to give the deployer cbBTC tokens
        vm.startPrank(deployer);
        // Use deal to give tokens to deployer
        vm.deal(deployer, 1 ether); // Give some ETH for gas
        vm.stopPrank();
        
        // Deal cbBTC to deployer
        // vm.deal(collateralToken, deployer, amount);
        
        // Check initial position
        (uint256 supplySharesBefore, uint128 borrowSharesBefore, uint128 collateralBefore) = 
            morpho.position(marketId, deployer);
            
        console.log("Initial position:");
        console.log("Supply shares:", supplySharesBefore);
        console.log("Borrow shares:", borrowSharesBefore);
        console.log("Collateral:", collateralBefore);
        
        // Check current cbBTC balance
        uint256 initialBalance = cbBTC.balanceOf(deployer);
        console.log("Initial cbBTC balance:", initialBalance);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Approve Morpho to spend cbBTC
        cbBTC.approve(address(morpho), amount);
        
        // Supply collateral
        morpho.supplyCollateral(cbBtcParams, amount, deployer, "");
        
        vm.stopBroadcast();
        
        // Check final position after supply
        (uint256 supplySharesAfter, uint128 borrowSharesAfter, uint128 collateralAfter) = 
            morpho.position(marketId, deployer);
            
        console.log("Final position:");
        console.log("Supply shares:", supplySharesAfter);
        console.log("Borrow shares:", borrowSharesAfter);
        console.log("Collateral:", collateralAfter);
        
        // Calculate collateral difference
        uint256 collateralSupplied = collateralAfter - collateralBefore;
        console.log("Collateral supplied:", collateralSupplied);
        
        // Check final balance
        uint256 finalBalance = cbBTC.balanceOf(deployer);
        console.log("Final cbBTC balance:", finalBalance);
        console.log("cbBTC spent:", initialBalance - finalBalance);
    }
    
    /**
     * @notice Helper function to log market information for a given market ID
     */
    function logMarketInfo() public view {
        (
            uint128 totalSupplyAssets,
            uint128 totalSupplyShares,
            uint128 totalBorrowAssets,
            uint128 totalBorrowShares,
            uint128 lastUpdate,
            uint128 fee
        ) = morpho.market(Id.wrap(marketId));

        console.log("Market info:");
        console.log("totalSupplyAssets:", totalSupplyAssets);
        console.log("totalSupplyShares:", totalSupplyShares);
        console.log("totalBorrowAssets:", totalBorrowAssets);
        console.log("totalBorrowShares:", totalBorrowShares);
        console.log("lastUpdate:", lastUpdate);
        console.log("fee:", fee);
    }
} 