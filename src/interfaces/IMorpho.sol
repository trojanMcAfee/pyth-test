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

    event CreateMarket(Id indexed id, MarketParams marketParams);

    function createMarket(MarketParams memory marketParams) external;

    function idToMarketParams(Id id)
        external
        view
        returns (address loanToken, address collateralToken, address oracle, address irm, uint256 lltv);
} 