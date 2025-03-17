// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MarketParams, Market, Id} from "./IMorpho.sol";

/// @title IIrm
/// @notice Interface for Morpho Interest Rate Model
interface IIrm {
    /// @notice Returns the borrow rate per second (scaled by WAD) of the market `marketParams`.
    /// @dev Assumes that `market` corresponds to `marketParams`.
    function borrowRate(MarketParams memory marketParams, Market memory market) external returns (uint256);

    /// @notice Returns the borrow rate per second (scaled by WAD) of the market `marketParams` without modifying any
    /// storage.
    /// @dev Assumes that `market` corresponds to `marketParams`.
    function borrowRateView(MarketParams memory marketParams, Market memory market) external view returns (uint256);

    /// @notice Rate at target utilization.
    /// @dev Tells the height of the curve.
    function rateAtTarget(Id id) external view returns (int256);
}