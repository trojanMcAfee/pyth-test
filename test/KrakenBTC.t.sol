// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {KrakenBTC} from "../src/KrakenBTC.sol";
import {IMorpho, MarketParams, Id} from "../src/interfaces/IMorpho.sol";
import {Vm} from "forge-std/Vm.sol";
import {IIrm} from "../src/interfaces/IIrm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPermit2} from "../src/interfaces/IPermit2.sol";
import {IChainAgnosticBundlerV2} from "../src/interfaces/IChainAgnosticBundlerV2.sol";
import {IAllowanceTransfer} from "../src/interfaces/IAllowanceTransfer.sol";
import {EIP712Signature} from "../src/EIP712/EIP712Signature.sol";

contract KrakenBTCTest is Test {
    // RPC URL and block number are set via Foundry's --fork-url and --fork-block-number flags
    // or directly in the test using createFork, createSelectFork
    
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
        // Deploy the KrakenBTC contract
        kbtc = new KrakenBTC();

        if (chainId == 1) {
            collateralToken = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf; //cbBTC
            loanToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT
            oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // Chainlink BTC/USD
            irm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
            blockNumber = 22061417;
            rpcUrl = vm.envString("RPC_URL");
        } else if (chainId == 57073) {
            collateralToken = address(kbtc);
            loanToken = 0x0200C29006150606B650577BBE7B6248F58470c1; //USDT0
            oracle = 0x13433B1949d9141Be52Ae13Ad7e7E4911228414e; // Redstone BTC/USD
            irm = 0x9515407b1512F53388ffE699524100e7270Ee57B;
            morpho = IMorpho(0x857f3EefE8cbda3Bc49367C996cd664A880d3042);
            rpcUrl = vm.envString("INK_RPC_URL");
            blockNumber = 8657564;
        } else if (chainId == 8453) {
            collateralToken = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf; //cbBTC
            loanToken = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; //USDC
            oracle = 0x663BECd10daE6C4A3Dcd89F1d76c1174199639B9; 
            irm = 0x46415998764C29aB2a25CbeA6254146D50D22687;
            morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
            lltv = 860000000000000000; //86%
            rpcUrl = vm.envString("BASE_RPC_URL");
            blockNumber = 22061417;

            cbBTC = IERC20(collateralToken);
            USDC = IERC20(loanToken);
            marketId = 0x9103c3b4e834476c9a62ea009ba2c884ee42e94e6e314a26f04d312434191836; //cbBTC/USDC
            
            permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);
            bundler = IChainAgnosticBundlerV2(0x23055618898e202386e6c13955a58D3C68200BFB);

            eip712Signature = new EIP712Signature();
        }

        vm.createSelectFork(rpcUrl, blockNumber);
        deal(collateralToken, deployer, 100 * 1e8);
    }
    
   
    function calculateNinety(uint256 tokenAmount) public pure returns (uint256) {
        return (tokenAmount * 90) / 100;
    }
    
    /**
     * @notice Helper function to log market information for a given market ID
     * @param marketId_ The ID of the market to retrieve information for
     */
    function logMarketInfo(bytes32 marketId_) public view {
        (
            uint128 totalSupplyAssets,
            uint128 totalSupplyShares,
            uint128 totalBorrowAssets,
            uint128 totalBorrowShares,
            uint128 lastUpdate,
            uint128 fee
        ) = morpho.market(Id.wrap(marketId_));

        console.log('totalSupplyAssets: ', totalSupplyAssets);
        console.log('totalSupplyShares: ', totalSupplyShares);
        console.log('totalBorrowAssets: ', totalBorrowAssets);
        console.log('totalBorrowShares: ', totalBorrowShares);
        console.log('lastUpdate: ', lastUpdate);
        console.log('fee: ', fee);
        console.log('');
        console.log('rate at target: ', IIrm(irm).rateAtTarget(Id.wrap(marketId_)));
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

    // function test_2supplyCbBTC() public returns(MarketParams memory cbBtcParams) {
    //     //Pre-conditions
    //     (uint256 supplyShares, uint128 borrowShares, uint128 collateral) = 
    //         morpho.position(marketId, deployer);

    //     assertEq(supplyShares, 0);
    //     assertEq(borrowShares, 0);
    //     assertEq(collateral, 0);

    //     cbBtcParams = MarketParams({
    //         loanToken: loanToken,
    //         collateralToken: collateralToken,
    //         oracle: oracle,
    //         irm: irm,
    //         lltv: lltv
    //     });
    //     uint amount = 100 * 1e8;

    //     bytes memory supplyData = abi.encodeWithSelector(
    //         IMorpho.supplyCollateral.selector, 
    //         cbBtcParams, amount, deployer, ''
    //     );
    //     console.logBytes4(IMorpho.supplyCollateral.selector);

    //     bytes[] memory data = new bytes[](1);
    //     data[0] = supplyData;

    //     //Actions
    //     vm.startPrank(deployer);
    //     cbBTC.approve(address(morpho), amount);
    //     // bundler.multicall(data);
    //     address(morpho).call(supplyData);
    //     vm.stopPrank();

    //     //Post-conditions
    //     (uint256 supplyShares_i, uint128 borrowShares_i, uint128 collateral_i) = 
    //         morpho.position(marketId, deployer);

    //     assertEq(supplyShares_i, 0);
    //     assertEq(borrowShares_i, 0);
    //     assertEq(collateral_i, amount);
            
    // }

    function test_supplyCbBTC() public returns(MarketParams memory cbBtcParams) {
        //Pre-conditions
        (uint256 supplyShares, uint128 borrowShares, uint128 collateral) = 
            morpho.position(marketId, deployer);

        assertEq(supplyShares, 0);
        assertEq(borrowShares, 0);
        assertEq(collateral, 0);

        cbBtcParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        });
        uint amount = 100 * 1e8;

        //Actions
        vm.startPrank(deployer);
        cbBTC.approve(address(morpho), amount);
        morpho.supplyCollateral(cbBtcParams, amount, deployer, '');
        vm.stopPrank();

        //Post-conditions
        (uint256 supplyShares_i, uint128 borrowShares_i, uint128 collateral_i) = 
            morpho.position(marketId, deployer);

        assertEq(supplyShares_i, 0);
        assertEq(borrowShares_i, 0);
        assertEq(collateral_i, amount);
            
    }

    function test_supplyAndBorrow() public returns(MarketParams memory cbBtcParams, uint256 amount) {
        //Pre-conditions
        cbBtcParams = test_supplyCbBTC();

        amount = 1000 * 1e6;

        //Actions
        vm.startPrank(deployer);
        (uint256 assetsBorrowed, uint256 sharesBorrowed) = 
            morpho.borrow(cbBtcParams, amount, 0, deployer, deployer);
        vm.stopPrank();

        //Post-condtions
        assertEq(assetsBorrowed, amount);
        assertGt(sharesBorrowed, 0);

        (,uint128 borrowShares,) = morpho.position(marketId, deployer);
        assertEq(sharesBorrowed, borrowShares);
    }

    function test_supplyBorrowAndPayback() public {
        //Pre-conditions
        (MarketParams memory cbBtcParams, uint256 amount) = test_supplyAndBorrow();

        //Actions
        vm.startPrank(deployer);
        USDC.approve(address(morpho), amount);
        (uint256 assetsRepaid,) = morpho.repay(cbBtcParams, amount, 0, deployer, '');
        vm.stopPrank();

        //Post-conditions
        assertEq(assetsRepaid, amount);
    }

    
    function _constructApprove2Data() internal returns (bytes memory) {
        IAllowanceTransfer.PermitDetails memory permitDetails = IAllowanceTransfer.PermitDetails({
            token: address(cbBTC),
            amount: type(uint160).max,
            expiration: uint48(block.timestamp + 1 days),
            nonce: 0
        });

        IAllowanceTransfer.PermitSingle memory permitSingle = IAllowanceTransfer.PermitSingle({
            details: permitDetails,
            spender: address(bundler),
            sigDeadline: block.timestamp + 1 days
        });

        bytes32 digest = eip712Signature.getPermitSingleDigest(permitSingle);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployer, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes memory approve2Data = abi.encodeWithSelector(
            bundler.approve2.selector, 
            permitSingle,
            signature,
            false
        );

        return approve2Data;
    }

    function _constructTransferFrom2Data(uint amount_) internal view returns(bytes memory) {
        return abi.encodeWithSelector(
            bundler.transferFrom2.selector,
            address(cbBTC),
            amount_
        );
    }

    function _constructSupplyData(uint amount, MarketParams memory cbBtcParams) internal view returns(bytes memory) {
        return abi.encodeWithSelector(
            bundler.morphoSupplyCollateral.selector,
            cbBtcParams,
            amount,
            deployer,
            ''
        );
    }


    function test_supplyBorrowPermit2() public {
        MarketParams memory cbBtcParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        });
        uint amount = 100 * 1e8;

        //Unlimited approval to Morpho's bundler
        vm.startPrank(deployer);
        // cbBTC.approve(address(permit2), type(uint256).max);
        // cbBTC.approve(address(morpho), type(uint256).max);
        cbBTC.approve(address(bundler), type(uint256).max);

        bytes memory supplyData = abi.encodeWithSelector(
            IMorpho.supplyCollateral.selector,
            cbBtcParams,
            amount,
            deployer,
            ''
        );

        bytes memory borrowData = abi.encodeWithSelector(
            IMorpho.borrow.selector,
            cbBtcParams,
            amount,
            0,
            deployer,
            deployer
        );

        bytes[] memory data = new bytes[](2);
        data[0] = supplyData;
        data[1] = borrowData;

        bundler.multicall(data);
        vm.stopPrank();
    }

    
} 