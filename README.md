# Pyth Price Oracle Demo

This project demonstrates how to use Pyth Network's price oracles with Foundry. It includes scripts to fetch real-time price data for KBTC/BTC and interact with it through a Solidity contract.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- [Node.js](https://nodejs.org/) installed
- An Anvil instance running locally

## Environment Setup

Create a `.env` file in the root directory with the following values:

```
RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY
INK_RPC_URL=https://ink-mainnet.g.alchemy.com/v2/YOUR_INK_ALCHEMY_API_KEY
PRIVATE_KEY=YOUR_PRIVATE_KEY
```

Note: For local testing with Anvil, you can use this default private key:
```
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## Getting Started

1. Start an Anvil instance as a fork of Ink mainnet in a separate terminal. This is necessary because our contract interacts with the Pyth contract that's deployed on Ink mainnet:

```bash
source .env
anvil --fork-url $INK_RPC_URL --fork-block-number 8442000
```

The block number can be adjusted as needed, but using a specific block number ensures consistent behavior across tests.

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