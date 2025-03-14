const fs = require('fs');
const https = require('https');

// The price ID for KBTC/BTC from the GetPyth contract
const priceId = '5dd5ede8b038c39f015746942820595ed69f30c00c3d3700f01d9ec55e027700';
const url = `https://hermes.pyth.network/api/latest_vaas?ids[]=${priceId}`;

console.log(`Fetching Pyth price data from: ${url}`);

https.get(url, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const pythData = JSON.parse(data);
      
      if (!pythData || !pythData.length) {
        console.error('No data returned from Pyth API');
        process.exit(1);
      }

      // The data is already in the format expected by the Pyth contract
      const vaa = pythData[0];
      
      // Save the VAA to a file that can be read by our Solidity script
      fs.writeFileSync('pyth-data.json', JSON.stringify({
        vaa: vaa,
        hex: Buffer.from(vaa, 'base64').toString('hex')
      }, null, 2));
      
      console.log('Pyth data saved to pyth-data.json');
      console.log('You can now run the Foundry script with real price data');
    } catch (error) {
      console.error('Error parsing Pyth API response:', error);
      process.exit(1);
    }
  });
}).on('error', (error) => {
  console.error('Error fetching Pyth data:', error);
  process.exit(1);
}); 