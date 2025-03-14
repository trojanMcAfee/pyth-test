# Pyth Price Oracle Demo

This project demonstrates how to use Pyth Network's price oracles with Foundry. It includes scripts to fetch real-time price data for KBTC/BTC and interact with it through a Solidity contract.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- [Node.js](https://nodejs.org/) installed
- An Anvil instance running locally

## Getting Started

1. Start by running an Anvil instance in a separate terminal:

```bash
anvil
```

2. Fetch the real price data from Pyth Network using the provided Node.js script:

```bash
node js-scripts/fetch-pyth-data.js
```

This will create a `pyth-data.json` file with the latest price data for KBTC/BTC.

3. Run the Foundry script to deploy the contract and query the price:

```bash
forge script script/GetPythPrice.s.sol:GetPythPriceScript --rpc-url http://localhost:8545 --broadcast -vv
```

## How It Works

1. The Node.js script (`js-scripts/fetch-pyth-data.js`) fetches the latest price feed data from Pyth's API for KBTC/BTC.
2. The data is saved to a JSON file.
3. The Foundry script (`GetPythPrice.s.sol`) reads this data and uses it to:
   - Deploy the `GetPyth` contract
   - Call the `getKbtcBtcPrice` function with the real price data
   - Display the price information in a human-readable format

## Understanding Pyth Price Data

Pyth prices include:
- **price**: The actual price value in integer format
- **conf**: The confidence interval (indicating the price accuracy)
- **expo**: An exponent to determine the actual decimal places
- **publishTime**: When the price was published

The script automatically converts these values to display a human-readable price.

## Files

- **src/GetPyth.sol**: The Solidity contract that interacts with Pyth oracle
- **js-scripts/fetch-pyth-data.js**: Node.js script to fetch real-time price data
- **script/GetPythPrice.s.sol**: Foundry script to deploy and test the contract 