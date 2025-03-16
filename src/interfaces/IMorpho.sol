// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct MarketParams {
    address loanToken;
    address collateralToken;
    address oracle;
    address irm;
    uint256 lltv;
}

type Id is bytes32;

interface IMorpho {
   
    // event CreateMarket(
    //     uint256 indexed id,
    //     address indexed loanToken,
    //     address indexed collateralToken,
    //     address oracle,
    //     address irm,
    //     uint256 lltv
    // );

    // /// @notice Creates a market.
    // /// @param loanToken The address of the loan token of the market to create.
    // /// @param collateralToken The address of the collateral token of the market to create.
    // /// @param oracle The address of the oracle of the market to create.
    // /// @param irm The address of the IRM of the market to create.
    // /// @param lltv The LLTV of the market to create. Should be in units of 1e18. For example, a 90% LLTV would be
    // /// represented as 0.9e18.
    // /// @return id The id of the created market.
    // function createMarket(
    //     address loanToken,
    //     address collateralToken,
    //     address oracle,
    //     address irm,
    //     uint256 lltv
    // ) external returns (uint256 id);

    event CreateMarket(Id indexed id, MarketParams marketParams);

    function createMarket(MarketParams memory marketParams) external;

    function idToMarketParams(Id id)
        external
        view
        returns (address loanToken, address collateralToken, address oracle, address irm, uint256 lltv);
} 