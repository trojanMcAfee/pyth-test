// Script to query Morpho Blue Base subgraph and get top 5 markets
require('dotenv').config();

async function queryMorphoMarkets() {
  // Get API key from .env file
  const API_KEY = process.env.GRAPH_API_KEY;
  
  // The subgraph ID from the URL
  const SUBGRAPH_ID = "71ZTy1veF9twER9CLMnPWeLQ7GZcwKsjmygejrgKirqs";
  
  // Full query URL
  const QUERY_URL = `https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/${SUBGRAPH_ID}`;
  
  // GraphQL query - getting top 5 markets ordered by totalValueLockedUSD
  const query = `
    {
      markets(first: 5, orderBy: totalValueLockedUSD, orderDirection: desc) {
        id
        name
        inputToken {
          id
          name
          symbol
          decimals
        }
        borrowedToken {
          id
          name
          symbol
          decimals
        }
        totalSupply
        totalBorrow
        totalValueLockedUSD
        supplyIndex
        borrowIndex
        rates {
          id
          side
          rate
        }
        lastUpdate
        oracle
        lltv
      }
    }
  `;
  
  try {
    const response = await fetch(QUERY_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query }),
    });
    
    const data = await response.json();
    
    if (data.errors) {
      console.error('Error fetching data:', data.errors);
      return;
    }
    
    // Format and display the results
    console.log('Top 5 Morpho Blue Markets on Base:');
    console.log('-----------------------------------');
    
    data.data.markets.forEach((market, index) => {
      console.log(`#${index + 1} Market: ${market.name || market.id}`);
      console.log(`Input Token (Collateral): ${market.inputToken.symbol}`);
      console.log(`Borrowed Token: ${market.borrowedToken.symbol}`);
      console.log(`Total Supply: ${formatTokenAmount(market.totalSupply, market.inputToken.decimals)} ${market.inputToken.symbol}`);
      console.log(`Total Borrow: ${formatTokenAmount(market.totalBorrow, market.borrowedToken.decimals)} ${market.borrowedToken.symbol}`);
      console.log(`Total Value Locked: $${formatUSD(market.totalValueLockedUSD)}`);
      
      // Find supply and borrow rates
      const supplyRate = market.rates.find(r => r.side === "LENDER");
      const borrowRate = market.rates.find(r => r.side === "BORROWER");
      
      if (supplyRate) {
        console.log(`Supply APY: ${(parseFloat(supplyRate.rate) * 100).toFixed(2)}%`);
      }
      
      if (borrowRate) {
        console.log(`Borrow APY: ${(parseFloat(borrowRate.rate) * 100).toFixed(2)}%`);
      }
      
      // Calculate utilization rate
      const utilizationRate = parseFloat(market.totalBorrow) / parseFloat(market.totalSupply);
      if (!isNaN(utilizationRate)) {
        console.log(`Utilization Rate: ${(utilizationRate * 100).toFixed(2)}%`);
      } else {
        console.log(`Utilization Rate: 0.00%`);
      }
      
      console.log(`Max LTV: ${(parseFloat(market.lltv) / 1e18 * 100).toFixed(2)}%`);
      console.log(`Last Update: ${new Date(parseInt(market.lastUpdate) * 1000).toLocaleString()}`);
      console.log('-----------------------------------');
    });
  } catch (error) {
    console.error('Error querying the subgraph:', error);
  }
}

// Helper function to format token amounts (from wei to human-readable)
function formatTokenAmount(amount, decimals) {
  return (parseFloat(amount) / (10 ** parseFloat(decimals))).toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 6
  });
}

// Helper function to format USD values
function formatUSD(value) {
  return parseFloat(value).toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

// Run the query
queryMorphoMarkets(); 