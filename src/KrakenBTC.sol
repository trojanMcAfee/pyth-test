// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KrakenBTC is ERC20 {
    constructor() ERC20("Kraken BTC", "kBTC") { 
        _mint(msg.sender, 1000000000000000000000000);
    }
}

