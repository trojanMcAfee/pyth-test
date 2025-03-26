// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "./IAllowanceTransfer.sol";

interface IChainAgnosticBundlerV2 {
    function multicall(bytes[] memory data) external;

    function approve2(IAllowanceTransfer.PermitSingle calldata permitSingle, bytes calldata signature, bool skipRevert)
        external
        payable;

}





