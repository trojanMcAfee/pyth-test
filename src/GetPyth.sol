// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract GetPyth {
    IPyth pyth;

    constructor() {
        pyth = IPyth(0x2880aB155794e7179c9eE2e38200202908C17B43);
    }

    function getKbtcBtcPrice(
        bytes[] calldata priceUpdateData,
        uint maxAgeSeconds
    ) public payable returns (PythStructs.Price memory) {
        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);

        bytes32 priceID = 0x5dd5ede8b038c39f015746942820595ed69f30c00c3d3700f01d9ec55e027700;
        return pyth.getPriceNoOlderThan(priceID, maxAgeSeconds);
    }
}