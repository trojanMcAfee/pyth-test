// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IIrm
/// @notice Interface for Morpho Interest Rate Model
interface IIrm {
    /// @notice Calculates the interest rate for a loan
    /// @param utilization The utilization rate of the loan market
    /// @return The interest rate in ray (10^27)
    function borrowRate(uint256 utilization) external view returns (uint256);
} 