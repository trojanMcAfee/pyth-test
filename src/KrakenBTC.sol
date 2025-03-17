// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";

contract KrakenBTC is ERC20 {

    AggregatorV3Interface btcUsdRedStone = AggregatorV3Interface(0x13433B1949d9141Be52Ae13Ad7e7E4911228414e);

    constructor() ERC20("Kraken BTC", "kBTC") { 
        _mint(msg.sender, 1000000000000000000000000);
    }

    function getBTCPrice() public view returns (int256) {
        (,int answer,,,) = btcUsdRedStone.latestRoundData();
        return answer;
    }
}

