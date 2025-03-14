# Morpho Blue Base Subgraph Query Tool

This script queries the Morpho Blue lending protocol subgraph on Base network to get information about the top 5 markets.

## Prerequisites

- Node.js installed on your machine
- An API key from The Graph's Subgraph Studio

## Getting an API key

1. Go to [Subgraph Studio](https://thegraph.com/studio/)
2. Connect your wallet to sign in
3. Click on the **API Keys** tab in the navigation menu
4. Click the button to create a new API key
5. Name your API key (e.g., "Morpho-Query")
6. Your new API key will be created and displayed in the API keys table

## Setup and Usage

1. Replace `YOUR_API_KEY` in the `query-morpho.js` file with your actual API key
2. Open a terminal and navigate to this directory
3. Run the script with Node.js:

```bash
node query-morpho.js
```

## Expected Output

The script will output the following information for each of the top 5 markets:
- Market identifier
- Collateral token symbol
- Loan token symbol
- Total supplied amount
- Total borrowed amount
- Total value locked (in USD)
- Utilization rate
- Supply APY
- Borrow APY
