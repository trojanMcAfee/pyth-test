// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPermit2 {
    function approve(
        address owner,
        address spender,
        uint256 value
    ) external;
}