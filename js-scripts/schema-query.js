require('dotenv').config();

async function querySchema() {
  const API_KEY = process.env.GRAPH_API_KEY;
  const SUBGRAPH_ID = "71ZTy1veF9twER9CLMnPWeLQ7GZcwKsjmygejrgKirqs";
  const QUERY_URL = `https://gateway.thegraph.com/api/${API_KEY}/subgraphs/id/${SUBGRAPH_ID}`;
  
  const query = `
    {
      __schema {
        types {
          name
          kind
          fields {
            name
            type {
              name
              kind
              ofType {
                name
                kind
              }
            }
          }
        }
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
    
    // Find the Market type definition
    const marketType = data.data.__schema.types.find(type => type.name === 'Market');
    
    if (marketType && marketType.fields) {
      console.log('Available fields for Market:');
      marketType.fields.forEach(field => {
        console.log(`- ${field.name}`);
      });
    } else {
      console.log('Market type not found or has no fields');
    }
  } catch (error) {
    console.error('Error fetching schema:', error);
  }
}

querySchema(); 