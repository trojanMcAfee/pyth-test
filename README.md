# Morpho Market Creation

This project demonstrates how to create a market on the Morpho protocol using a custom collateral token (KrakenBTC) and a price oracle.

## Project Structure

- `src/KrakenBTC.sol`: A simple ERC20 token representing BTC on Kraken
- `src/DirectOracle.sol`: A configurable price oracle that implements the Chainlink AggregatorV3Interface
- `src/interfaces/`: Contains the necessary interfaces for interacting with Morpho
- `script/CreateMorphoMarket.s.sol`: Script to create a Morpho market with kBTC as collateral

## Setup

1. Clone the repository
2. Install dependencies: `forge install`
3. Create a `.env` file with your private key and RPC URL:

```
PRIVATE_KEY=your_private_key_here
ETHEREUM_RPC_URL=your_ethereum_rpc_url_here
BASE_RPC_URL=your_base_rpc_url_here
```

## Usage

### Creating a Market on Ethereum

```bash
forge script script/CreateMorphoMarket.s.sol --rpc-url $ETHEREUM_RPC_URL --broadcast
```

### Creating a Market on Base

To use Base instead of Ethereum, modify the script to uncomment the Base addresses and comment out the Ethereum addresses.

## Contracts

### KrakenBTC

A simple ERC20 token with 18 decimals that can be used as collateral in Morpho markets.

### DirectOracle

A price oracle that implements the Chainlink AggregatorV3Interface and provides a configurable price for the KrakenBTC token. The price can be updated using the `setPrice` function.

## Notes

- The script attempts to create a market with multiple LLTV (Loan-to-Value) values, starting from 0% and increasing to 98%.
- Market creation may fail if the parameters are not pre-approved by the Morpho protocol.
- Make sure you have enough ETH in your wallet to pay for gas fees. 