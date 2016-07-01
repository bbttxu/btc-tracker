CoinbaseExchange = require('coinbase-exchange')

module.exports = (product = 'BTC-USD')->
  new CoinbaseExchange.WebsocketClient product
